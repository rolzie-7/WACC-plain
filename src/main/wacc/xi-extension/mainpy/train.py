import os
import torch as t
from torch import nn, optim
from typing import Dict, Any, List
import tqdm
from vector2arm import ArmResult

from dataset import WACCDataset
from world_model import WorldModel
from arm_config import REG_INSTR_NO, EMBEDDING_DIM, DEVICE, TRAIN_EPOCHS

# Added helper function to debug tensor devices
def debug_tensor_devices(generated: 'ArmResult', target: 'ArmResult') -> str:
    """
    Helper function to debug tensor device mismatches between ArmResult objects.
    Returns a detailed string showing the device of each tensor.
    """
    debug_info = []
    
    # Check main tensors and their devices
    for obj_name, obj in [("generated", generated), ("target", target)]:
        debug_info.append(f"{obj_name} ArmResult tensor devices:")
        
        for attr_name in dir(obj):
            attr = getattr(obj, attr_name)
            if isinstance(attr, t.Tensor):
                debug_info.append(f"  - {attr_name}: {attr.device}")
            elif isinstance(attr, list) and all(isinstance(item, t.Tensor) for item in attr):
                devices = [item.device for item in attr]
                debug_info.append(f"  - {attr_name}: {devices}")
    
    return "\n".join(debug_info)

def compare_arm_results(generated: 'ArmResult', target: 'ArmResult') -> t.Tensor:
    """
    Compare two ArmResult objects and return a loss tensor.
    Uses masked loss to handle default values intelligently.
    Respects one-hot encoding of tensors.
    """
    # Move both objects to the same device if needed
    if hasattr(generated, 'to_device'):
        generated.to_device(DEVICE)
    if hasattr(target, 'to_device'):
        target.to_device(DEVICE)
        
    loss = t.tensor(0.0, device=DEVICE)
    
    # For instruction type (always count this)
    # Both are one-hot encoded, use KL divergence
    loss += nn.functional.kl_div(
        t.log_softmax(generated.instruction_type, dim=-1),
        target.instruction_type,
        reduction='batchmean'
    )
    
    # For registers (always count these)
    # Process each register position separately
    for i in range(REG_INSTR_NO):
        # Check if this register position has a non-default value
        has_real_reg = (target.registers[i].argmax() > 0)
        
        # Apply KL divergence with weighting
        reg_loss = nn.functional.kl_div(
            t.log_softmax(generated.registers[i], dim=-1),
            target.registers[i],
            reduction='batchmean'
        )
        
        if has_real_reg:
            loss += reg_loss  # Full weight for real registers
        else:
            loss += 0.3 * reg_loss  # Less weight for "none" registers
    
    # For addressing mode (always count this)
    loss += nn.functional.kl_div(
        t.log_softmax(generated.addressing_mode, dim=-1),
        target.addressing_mode,
        reduction='batchmean'
    )
    
    # For shift type (conditional weighting)
    has_shift = (target.shift_type.argmax() > 0)  # Check if not the default
    shift_loss = nn.functional.kl_div(
        t.log_softmax(generated.shift_type, dim=-1),
        target.shift_type,
        reduction='batchmean'
    )
    
    if has_shift:
        loss += shift_loss  # More weight for real shift operations
    else:
        loss += 0.5 * shift_loss  # Less weight for correctly predicting "no shift"
    
    # For extend type (conditional weighting)
    has_extend = (target.extend_type.argmax() > 0)  # Check if not the default
    extend_loss = nn.functional.kl_div(
        t.log_softmax(generated.extend_type, dim=-1),
        target.extend_type,
        reduction='batchmean'
    )
    
    if has_extend:
        loss += extend_loss  # More weight for real extend operations
    else:
        loss += 0.5 * extend_loss  # Less weight for correctly predicting "no extend"
    
    # For condition (conditional weighting)
    has_condition = (target.condition.argmax() > 0)  # Check if not the default
    condition_loss = nn.functional.kl_div(
        t.log_softmax(generated.condition, dim=-1),
        target.condition,
        reduction='batchmean'
    )
    
    if has_condition:
        loss += 1.5 * condition_loss  # More weight for real conditions
    else:
        loss += condition_loss  # Less weight for correctly predicting default
    
    # For has_label (binary classification with conditional weighting)
    has_label_value = target.has_label.item() > 0.5
    if has_label_value:
        # More weight when there's a label
        loss += 1.5 * nn.functional.binary_cross_entropy(generated.has_label, target.has_label)
    else:
        # Very little weight for correctly predicting "no label"
        loss += nn.functional.binary_cross_entropy(generated.has_label, target.has_label)
    
    # For literal (only include in loss if it's relevant)
    has_literal = target.has_literal.item() > 0.0
    
    has_literal_loss = nn.functional.mse_loss(generated.has_literal, target.has_literal)
    loss += has_literal_loss
    # Typically literals only matter for certain instructions or when has_label is true
    if has_literal:
        # Round generated literal to nearest int
        generated_literal = generated.literal.squeeze()
        
        # First, a small MSE to guide learning toward the right region
        literal_loss = nn.functional.mse_loss(generated_literal, 
                                            t.tensor(float(target.literal), device=DEVICE))
        literal_loss += (generated_literal - target.literal).abs() ** 2
        
        # Second, an exact match bonus/penalty based on integer comparison
        loss += literal_loss
    
    # For label_id (only count if has_label is true)
    if has_label_value:
        # Convert label_id to integer
        target_label_id_int = int(target.label_id)
        # Round generated label_id to nearest int
        generated_label_id = generated.label_id.squeeze()
        generated_label_id_rounded = t.round(generated_label_id).int()
        
        # First, a small MSE to guide learning toward the right region
        label_id_mse = nn.functional.mse_loss(generated_label_id, 
                                             t.tensor(float(target_label_id_int), device=DEVICE))
        
        # Second, an exact match bonus/penalty based on integer comparison
        label_id_match = (generated_label_id_rounded == target_label_id_int)
        label_id_match_loss = -2.0 if label_id_match else 0.0  # Reward for exact match, penalty for mismatch
        
        loss += label_id_mse + 0.05 * label_id_match_loss
    
    return loss

def calculate_accuracy(generated: 'ArmResult', target: 'ArmResult') -> Dict[str, float]:
    """
    Calculate accuracy metrics for a given ArmResult pair.
    Returns a dictionary with accuracy metrics for each component.
    """
    accuracy = {}
    
    # For instruction type (always count this)
    accuracy['instruction_type'] = float(generated.instruction_type.argmax().item() == target.instruction_type.argmax().item())
    
    # For registers (always count these)
    # Process each register position separately
    reg_matches = 0
    for i in range(REG_INSTR_NO):
        gen_reg = generated.registers[i].argmax().item()
        target_reg = target.registers[i].argmax().item()
        reg_matches += float(gen_reg == target_reg)
    accuracy['registers'] = reg_matches / REG_INSTR_NO  # Normalize to [0,1]
    
    # For addressing mode (always count this)
    accuracy['addressing_mode'] = float(generated.addressing_mode.argmax().item() == target.addressing_mode.argmax().item())
    
    # For shift type
    accuracy['shift_type'] = float(generated.shift_type.argmax().item() == target.shift_type.argmax().item())
    
    # For extend type
    accuracy['extend_type'] = float(generated.extend_type.argmax().item() == target.extend_type.argmax().item())
    
    # For condition
    accuracy['condition'] = float(generated.condition.argmax().item() == target.condition.argmax().item())
    
    # For has_label (binary classification)
    gen_has_label = generated.has_label.item() > 0.5
    target_has_label = target.has_label.item() > 0.5
    accuracy['has_label'] = float(gen_has_label == target_has_label)
    
    # For literal (only if relevant)
    has_label_value = target.has_label.item() > 0.5
    has_literal = target.has_literal.item() > 0.0

    gen_has_literal = generated.has_literal.item() > 0.0
    accuracy['has_literal'] = float(gen_has_literal == has_literal)
    # print("Has literal: ", has_literal)
    
    if has_literal:
        target_literal_int = int(target.literal)
        generated_literal_rounded = t.round(generated.literal.squeeze()).int().item()
        accuracy['literal'] = float(generated_literal_rounded == target_literal_int)
    else:
        # If literal is not used in this instance, count it as correct
        accuracy['literal'] = 1.0
    
    # For label_id (only if has_label is true)
    if has_label_value:
        target_label_id_int = int(target.label_id)
        generated_label_id_rounded = t.round(generated.label_id.squeeze()).int().item()
        accuracy['label_id'] = float(generated_label_id_rounded == target_label_id_int)
    else:
        # If label_id is not used in this instance, count it as correct
        accuracy['label_id'] = 1.0
    
    # Calculate overall accuracy as the weighted average of all metrics
    # Focus on the ones that are actually being used in this sample
    used_keys = ['instruction_type', 'registers', 'addressing_mode']
    
    if has_label_value:
        used_keys.extend(['has_label', 'label_id'])
    
    # Only include shift_type, extend_type, condition if they're actually used
    if target.shift_type.argmax().item() > 0:
        used_keys.append('shift_type')
    
    if target.extend_type.argmax().item() > 0:
        used_keys.append('extend_type')
    
    if target.condition.argmax().item() > 0:
        used_keys.append('condition')
    
    if has_literal:
        used_keys.append('literal')
    
    # Calculate overall accuracy only on the used fields
    overall_acc = sum(accuracy[key] for key in used_keys) / len(used_keys)
    accuracy['overall'] = overall_acc
    
    return accuracy

def train(
    model: WorldModel,
    dataset: WACCDataset,
    epochs: int = TRAIN_EPOCHS,
    lr: float = 1e-4,
    batch_size: int = 1,
    # Use the device from arm_config
    device: str = DEVICE,
) -> None:
    """Basic training loop for the WorldModel with train-test split."""
    print(f"Training on device: {device}")
    model = model.to(device)
    optimizer = optim.Adam(model.parameters(), lr=lr)
    
    # Create 50/50 train-test split
    dataset_size = len(dataset)
    train_size = dataset_size // 2
    test_size = dataset_size - train_size
    
    # Create indices for train and test sets
    all_indices = list(range(dataset_size))
    import random
    random.shuffle(all_indices)
    train_indices = all_indices[:train_size]
    test_indices = all_indices[train_size:]
    
    print(f"Dataset split: {train_size} training samples, {test_size} test samples")
    
    # Track instruction type distribution
    instruction_distribution = {}
    
    for epoch in range(epochs):
        total_loss = 0.0
        total_accuracy = 0.0  # Track overall accuracy
        valid_samples = 0
        
        # Accuracy tracking
        accuracy_totals = {
            'instruction_type': 0.0,
            'registers': 0.0,
            'addressing_mode': 0.0,
            'shift_type': 0.0,
            'extend_type': 0.0,
            'condition': 0.0,
            'has_label': 0.0,
            'literal': 0.0,
            'label_id': 0.0,
            'has_literal': 0.0,
            'overall': 0.0
        }
        accuracy_counts = {key: 0 for key in accuracy_totals.keys()}
        
        # Track field usage (how many samples actually use each field)
        field_usage = {
            'shift_type': 0,
            'extend_type': 0,
            'condition': 0,
            'has_label': 0,
            'literal': 0,
            'label_id': 0,
        }
        
        model.train()
        
        # Using tqdm for progress tracking - ONLY on training set
        progress_bar = tqdm.tqdm(train_indices, desc=f"Epoch {epoch+1}/{epochs}")
        
        for idx in progress_bar:
            try:
                # Get a data pair
                json_data, armresult_data = dataset[idx]
                
                # Move data to device if needed
                if isinstance(json_data, t.Tensor):
                    json_data = json_data.to(device)
                
                # Ensure armresult_data is a list with at least one element
                if not isinstance(armresult_data, list) or len(armresult_data) == 0:
                    continue
                
                # Get the first ArmResult as target
                target_arm_result = armresult_data[0]
                
                # Move target ArmResult to device if needed
                if hasattr(target_arm_result, 'to_device'):
                    target_arm_result.to_device(device)
                
                # Get instruction type and track distribution
                instr_idx = target_arm_result.instruction_type.argmax().item()
                if instr_idx not in instruction_distribution:
                    instruction_distribution[instr_idx] = 0
                instruction_distribution[instr_idx] += 1
                
                # Check if shift is used
                has_shift = (target_arm_result.shift_type.argmax().item() > 0)
                if has_shift:
                    field_usage['shift_type'] += 1
                
                # Check if extend is used
                has_extend = (target_arm_result.extend_type.argmax().item() > 0)
                if has_extend:
                    field_usage['extend_type'] += 1
                
                # Check if condition is used
                has_condition = (target_arm_result.condition.argmax().item() > 0)
                if has_condition:
                    field_usage['condition'] += 1
                
                # Check if label is used
                has_label_value = target_arm_result.has_label.item() > 0.5
                if has_label_value:
                    field_usage['has_label'] += 1
                    field_usage['label_id'] += 1
                
                # Check if literal is used - EXACTLY matching the compare_arm_results logic
                literal_used = target_arm_result.has_literal.item() > 0.0
                if literal_used:
                    field_usage['literal'] += 1
                
                # Reset gradients
                optimizer.zero_grad()
                
                # Forward pass through the world model
                # Note: model.forward expects Dict[str, Any] as per its signature
                # The dataset provides this directly
                model_output = model(json_data)
                
                # Get the generated ArmResult
                generated_arm_result = model.output_to_arm()
                
                # Move generated ArmResult to device if needed
                if hasattr(generated_arm_result, 'to_device'):
                    generated_arm_result.to_device(device)
                
                # Calculate loss
                loss = compare_arm_results(generated_arm_result, target_arm_result)

                # Add cycle count to loss
                cycle_count = model.current_cycle_count
                cycle_loss_alpha = 0.1
                cycle_loss = cycle_loss_alpha * t.sqrt(t.tensor(cycle_count, device=DEVICE))
                loss += cycle_loss
                # Calculate accuracy metrics
                accuracy = calculate_accuracy(generated_arm_result, target_arm_result)
                
                # Backward pass and optimize
                loss.backward()
                optimizer.step()
                
                # Track loss
                loss_val = loss.item()
                if not t.isnan(t.tensor(loss_val, device=DEVICE)) and not t.isinf(t.tensor(loss_val, device=DEVICE)):
                    total_loss += loss_val
                    valid_samples += 1
                    
                    # Track accuracy
                    sample_accuracy = accuracy['overall']
                    total_accuracy += sample_accuracy
                    
                    for key, value in accuracy.items():
                        accuracy_totals[key] += value
                        accuracy_counts[key] += 1
                    
                    # Display running loss and accuracy in progress bar
                    running_loss = total_loss / valid_samples
                    running_accuracy = total_accuracy / valid_samples
                    progress_bar.set_postfix({"loss": f"{running_loss:.6f}", "acc": f"{running_accuracy:.4f}"})
            except Exception as e:
                print(f"Error processing example {idx}: {str(e)}")
                # Enhanced exception handling with device debugging
                try:
                    if 'target_arm_result' in locals() and 'generated_arm_result' in locals():
                        print("Device debug information:")
                        print(debug_tensor_devices(generated_arm_result, target_arm_result))
                    print(f"Model device: {next(model.parameters()).device}")
                except Exception as debug_e:
                    print(f"Error during debugging: {str(debug_e)}")
                continue
        
        # Print epoch summary
        if valid_samples > 0:
            avg_loss = total_loss / valid_samples
            avg_accuracy = total_accuracy / valid_samples
            print(f"Epoch {epoch+1}/{epochs}, Average Loss: {avg_loss:.6f}, Average Accuracy: {avg_accuracy:.4f}, Valid Samples: {valid_samples}/{train_size}")
            
            # Print instruction type distribution
            if epoch == 0:  # Only print on first epoch to avoid repetition
                print("\nInstruction Type Distribution:")
                total_instr = sum(instruction_distribution.values())
                sorted_instr = sorted(instruction_distribution.items(), key=lambda x: x[1], reverse=True)
                for instr_idx, count in sorted_instr:
                    percentage = (count / total_instr) * 100
                    print(f"  Instruction {instr_idx}: {count}/{total_instr} ({percentage:.1f}%)")
                print(f"  Special indices [3,4,5,8,19,20]: {sum(instruction_distribution.get(idx, 0) for idx in [3,4,5,8,19,20])}/{total_instr}")
            
            # Print field usage statistics
            print("\nField Usage Statistics (how many samples use each field):")
            for key, count in field_usage.items():
                percentage = (count / valid_samples) * 100
                print(f"  {key}: {count}/{valid_samples} ({percentage:.1f}%)")
            
            # Print detailed accuracy metrics
            print("\nDetailed Accuracy Metrics:")
            for key in sorted(accuracy_totals.keys()):
                if accuracy_counts[key] > 0:
                    avg_component_accuracy = accuracy_totals[key] / accuracy_counts[key]
                    # Format the display based on field usage
                    if key in field_usage:
                        if field_usage[key] > 0:
                            print(f"  {key}: {avg_component_accuracy:.4f} (used in {field_usage[key]} samples)")
                        else:
                            print(f"  {key}: N/A (not used in any samples)")
                    else:
                        print(f"  {key}: {avg_component_accuracy:.4f}")
        else:
            print(f"Epoch {epoch+1}/{epochs}, No valid samples in this epoch")
    
    print("Training completed.")
    
    # Test the model on the test set
    print("\n" + "="*50)
    print("EVALUATING ON TEST SET")
    print("="*50)
    
    model.eval()  # Set model to evaluation mode
    test_loss = 0.0
    test_accuracy = 0.0
    valid_test_samples = 0
    
    # Accuracy tracking for test set
    test_accuracy_totals = {key: 0.0 for key in accuracy_totals.keys()}
    test_accuracy_counts = {key: 0 for key in accuracy_counts.keys()}
    
    # Using tqdm for progress tracking on test set
    test_progress_bar = tqdm.tqdm(test_indices, desc="Testing")
    
    with t.no_grad():  # No need to track gradients for testing
        for idx in test_progress_bar:
            try:
                # Get a data pair
                json_data, armresult_data = dataset[idx]
                
                # Move data to device if needed
                if isinstance(json_data, t.Tensor):
                    json_data = json_data.to(device)
                
                # Ensure armresult_data is a list with at least one element
                if not isinstance(armresult_data, list) or len(armresult_data) == 0:
                    continue
                
                # Get the first ArmResult as target
                target_arm_result = armresult_data[0]
                
                # Move target ArmResult to device if needed
                if hasattr(target_arm_result, 'to_device'):
                    target_arm_result.to_device(device)
                
                # Forward pass through the world model
                model_output = model(json_data)
                
                # Get the generated ArmResult
                generated_arm_result = model.output_to_arm()
                
                # Move generated ArmResult to device if needed
                if hasattr(generated_arm_result, 'to_device'):
                    generated_arm_result.to_device(device)
                
                # Calculate loss
                loss = compare_arm_results(generated_arm_result, target_arm_result)
                
                # Calculate accuracy metrics
                accuracy = calculate_accuracy(generated_arm_result, target_arm_result)
                
                # Track loss
                loss_val = loss.item()
                if not t.isnan(t.tensor(loss_val, device=DEVICE)) and not t.isinf(t.tensor(loss_val, device=DEVICE)):
                    test_loss += loss_val
                    valid_test_samples += 1
                    
                    # Track accuracy
                    sample_accuracy = accuracy['overall']
                    test_accuracy += sample_accuracy
                    
                    for key, value in accuracy.items():
                        test_accuracy_totals[key] += value
                        test_accuracy_counts[key] += 1
                    
                    # Display running loss and accuracy in progress bar
                    running_loss = test_loss / valid_test_samples
                    running_accuracy = test_accuracy / valid_test_samples
                    test_progress_bar.set_postfix({"loss": f"{running_loss:.6f}", "acc": f"{running_accuracy:.4f}"})
            except Exception as e:
                print(f"Error processing test example {idx}: {str(e)}")
                continue
    
    # Print test summary
    if valid_test_samples > 0:
        avg_test_loss = test_loss / valid_test_samples
        avg_test_accuracy = test_accuracy / valid_test_samples
        print(f"Test Loss: {avg_test_loss:.6f}, Test Accuracy: {avg_test_accuracy:.4f}, Valid Test Samples: {valid_test_samples}/{test_size}")
        
        # Print detailed test accuracy metrics
        print("\nDetailed Test Accuracy Metrics:")
        for key in sorted(test_accuracy_totals.keys()):
            if test_accuracy_counts[key] > 0:
                avg_component_accuracy = test_accuracy_totals[key] / test_accuracy_counts[key]
                print(f"  {key}: {avg_component_accuracy:.4f}")
    else:
        print("No valid test samples.")

if __name__ == "__main__":
    # Set data directory
    data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "wacc-json")
    
    # Create dataset
    dataset = WACCDataset(data_dir=data_dir)
    print(f"Dataset loaded with {len(dataset)} examples")
    
    # Create model
    model = WorldModel(embedding_dim=EMBEDDING_DIM)  # Adjust embedding_dim as needed
    
    # Train model
    train(model, dataset, epochs=TRAIN_EPOCHS, device=DEVICE)
    
    # Save the trained model
    model_path = os.path.join(os.path.dirname(__file__), "trained_model.pt")
    # Move model to CPU before saving to ensure compatibility
    model = model.to('cpu')
    t.save(model.state_dict(), model_path)
    print(f"Model saved to {model_path}")
