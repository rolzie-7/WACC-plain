import os
import torch as t
from torch import nn, optim
from typing import Dict, Any, List
import tqdm
from vector2arm import ArmResult

from dataset import WACCDataset
from world_model import WorldModel
from arm_config import REG_INSTR_NO, EMBEDDING_DIM, DEVICE, TRAIN_EPOCHS

def compare_instruction_sequences(generated_seq: List[ArmResult], target_seq: List[ArmResult], halter_values: List[float]) -> t.Tensor:
    """
    Compare two sequences of ArmResult objects and return a loss tensor.
    
    Args:
        generated_seq: A list of generated ArmResult objects
        target_seq: A list of target ArmResult objects
        halter_values: Values produced by the sequence_halter for each instruction
        
    Returns:
        A loss tensor representing the difference between the sequences
    """
    loss = t.tensor(0.0, device=DEVICE)
    
    # Get the common length (minimum of both sequences)
    common_length = min(len(generated_seq), len(target_seq))
    
    # Special case: if target is empty or has only 1 instruction, adjust penalties
    # This prevents model from learning to always output just 1 instruction
    extremely_short_target = len(target_seq) <= 1
    
    # Compare each instruction pair in the common sequence
    for i in range(common_length):
        # Import the compare_arm_results function from train.py
        from train import compare_arm_results
        pair_loss = compare_arm_results(generated_seq[i], target_seq[i])
        loss += pair_loss
    
    # Add penalty for length mismatch - we want the sequences to be the same length
    # Reduce the penalty for stability
    length_penalty = min(20.0, abs(len(generated_seq) - len(target_seq)) * 2.0)
    
    # If the target is very short, reduce the penalty for generating more instructions
    # This prevents the model from being biased toward always outputting just 1 instruction
    if extremely_short_target and len(generated_seq) > len(target_seq):
        # Reduce the penalty by 50% if the target is very short
        length_penalty *= 0.5
        
    loss += t.tensor(length_penalty, device=DEVICE)
    
    # Add STRONG penalties for missing instructions (if generated sequence is too short)
    if len(generated_seq) < len(target_seq):
        # Add a significant fixed penalty for each missing instruction
        # This creates a strong incentive to generate the full sequence
        missing_instruction_count = len(target_seq) - len(generated_seq)
        
        # Calculate the percentage of missing instructions relative to the target length
        missing_percentage = missing_instruction_count / len(target_seq)
        
        # Make the penalty exponentially larger as the percentage of missing instructions increases
        # This severely penalizes generating very few instructions when many are expected
        severity_factor = 1.0 + 5.0 * (missing_percentage ** 2)
        
        missing_instruction_penalty = 40.0 * missing_instruction_count * severity_factor
        loss += t.tensor(missing_instruction_penalty, device=DEVICE)
    
    # Ensure loss is not exploding due to numerical instability
    if t.isnan(loss) or t.isinf(loss):
        print("Warning: Loss is NaN or Inf, using a fallback value")
        loss = t.tensor(100.0, device=DEVICE)  # Fallback to a high but reasonable value
    
    # Add direct supervision for sequence_halter values
    halter_loss = t.tensor(0.0, device=DEVICE)
    
    # Create target values for halter:
    # - Should predict 0 for positions before the target sequence length (continue)
    # - Should predict 1 for the position at the target sequence length (stop)
    # Also handle edge cases for sequences that are too short or too long
    for i, halter_val in enumerate(halter_values):
        # Default target is to continue (0.0)
        target_val = 0.0
        
        # If we're at the target length minus 1, halter should predict close to 1 (stop)
        # This is the "correct" stopping point - RIGHT after generating the last instruction
        if i == len(target_seq) - 1:
            target_val = 1.0
            
        # For any position beyond the target length, the halter should have stopped earlier
        # So target remains 1.0 (should have stopped)
        elif i >= len(target_seq):
            target_val = 1.0
            
        # Use binary cross-entropy loss for the halter
        try:
            # Convert to tensors safely
            halter_tensor = t.tensor(halter_val, device=DEVICE, dtype=t.float32)
            target_tensor = t.tensor(target_val, device=DEVICE, dtype=t.float32)
            
            # Ensure values are in valid range for BCE
            halter_tensor = t.clamp(halter_tensor, 1e-7, 1.0 - 1e-7)
            
            # Add stronger weight when this is a critical decision point
            weight = 1.0
            if i == len(target_seq) - 1:  # At stopping point
                weight = 5.0  # Higher weight for stopping at the right point
            elif i >= len(target_seq):   # Beyond stopping point
                weight = 3.0  # Higher weight for not going past the end
            
            # Calculate BCE loss safely with appropriate weighting
            bce_loss = weight * nn.functional.binary_cross_entropy(
                halter_tensor,
                target_tensor
            )
            
            # Keep loss values reasonable
            halter_loss += t.clamp(bce_loss, 0.0, 10.0)
        except Exception as e:
            print(f"Warning: Error in halter BCE calculation: {e}")
            # Skip this term if there's an error
    
    # Add the halter loss to the total loss
    if halter_values:  # Only if we have halter values
        loss += halter_loss / len(halter_values)
    
    return loss / max(1, common_length)  # Normalize by sequence length

def calculate_sequence_accuracy(generated_seq: List[ArmResult], target_seq: List[ArmResult]) -> Dict[str, float]:
    """
    Calculate accuracy metrics for two sequences of ArmResult objects.
    
    Args:
        generated_seq: A list of generated ArmResult objects
        target_seq: A list of target ArmResult objects
        
    Returns:
        A dictionary with accuracy metrics
    """
    # Import the calculate_accuracy function from train.py
    from train import calculate_accuracy
    
    # Get the common length (minimum of both sequences)
    common_length = min(len(generated_seq), len(target_seq))
    
    # Initialize accuracy totals
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
        'overall': 0.0,
        'sequence_length': 0.0,  # Accuracy of sequence length prediction
        'length_match_rate': 0.0,
        'too_short_rate': 0.0,
        'too_long_rate': 0.0,
        'single_instruction_rate': 0.0,
        'missed_instructions_pct': 0.0,
        'extra_instructions_pct': 0.0,
        'target_length': 0.0,
        'generated_length': 0.0
    }
    
    # Compare each instruction pair in the common sequence
    for i in range(common_length):
        pair_accuracy = calculate_accuracy(generated_seq[i], target_seq[i])
        
        # Add each component's accuracy to the totals
        for key in accuracy_totals:
            if key in pair_accuracy:
                accuracy_totals[key] += pair_accuracy[key]
    
    # Normalize by sequence length
    for key in accuracy_totals:
        if key != 'sequence_length':
            accuracy_totals[key] /= max(1, common_length)
    
    # Calculate sequence length accuracy (1.0 if perfect, decreasing as the difference increases)
    length_diff = abs(len(generated_seq) - len(target_seq))
    if length_diff == 0:
        accuracy_totals['sequence_length'] = 1.0
    else:
        # Exponential decay for sequence length accuracy
        accuracy_totals['sequence_length'] = max(0.0, 1.0 - (length_diff / max(len(target_seq), 1)))
    
    # Overall accuracy includes sequence length accuracy
    overall_components = list(accuracy_totals.values())
    accuracy_totals['overall'] = sum(overall_components) / len(overall_components)
    
    return accuracy_totals

def calculate_sequence_metrics(generated_seq: List[ArmResult], target_seq: List[ArmResult], halter_values: List[float]) -> Dict[str, float]:
    """
    Calculate comprehensive metrics for sequence generation quality.
    
    Args:
        generated_seq: A list of generated ArmResult objects
        target_seq: A list of target ArmResult objects
        halter_values: Values from the sequence halter
        
    Returns:
        Dictionary of evaluation metrics
    """
    # Get base accuracy metrics
    accuracy = calculate_sequence_accuracy(generated_seq, target_seq)
    
    # Get sequence length metrics
    metrics = {
        'sequence_length_diff': len(generated_seq) - len(target_seq),
        'sequence_length_abs_diff': abs(len(generated_seq) - len(target_seq)),
        'length_match_rate': 1.0 if len(generated_seq) == len(target_seq) else 0.0,
        'too_short_rate': 1.0 if len(generated_seq) < len(target_seq) else 0.0,
        'too_long_rate': 1.0 if len(generated_seq) > len(target_seq) else 0.0,
        'single_instruction_rate': 1.0 if len(generated_seq) == 1 else 0.0,
    }
    
    # Calculate how many instructions were missed (as percentage)
    if len(target_seq) > 0 and len(generated_seq) < len(target_seq):
        metrics['missed_instructions_pct'] = (len(target_seq) - len(generated_seq)) / len(target_seq)
    else:
        metrics['missed_instructions_pct'] = 0.0
    
    # Calculate how many extra instructions were generated (as percentage)
    if len(target_seq) > 0 and len(generated_seq) > len(target_seq):
        metrics['extra_instructions_pct'] = (len(generated_seq) - len(target_seq)) / len(target_seq)
    else:
        metrics['extra_instructions_pct'] = 0.0
        
    # Track these metrics during training
    metrics['target_length'] = len(target_seq)
    metrics['generated_length'] = len(generated_seq)
    
    # Get instruction type metrics
    common_length = min(len(generated_seq), len(target_seq))
    instr_type_matches = 0
    for i in range(common_length):
        gen_type = generated_seq[i].instruction_type.argmax().item()
        target_type = target_seq[i].instruction_type.argmax().item()
        if gen_type == target_type:
            instr_type_matches += 1
    
    metrics['instruction_type_match_rate'] = instr_type_matches / common_length if common_length > 0 else 0.0
    
    # Halter performance metrics
    if halter_values:
        proper_halts = 0
        for i, val in enumerate(halter_values):
            is_last = i == len(target_seq) - 1
            should_halt = is_last
            did_halt = val >= 0.5
            
            if should_halt == did_halt:
                proper_halts += 1
                
        metrics['halter_accuracy'] = proper_halts / len(halter_values)
    else:
        metrics['halter_accuracy'] = 0.0
    
    # Combine all metrics
    for key, value in accuracy.items():
        metrics[key] = value
    
    return metrics

def train_sequence_model(
    model: WorldModel,
    dataset: WACCDataset,
    epochs: int = TRAIN_EPOCHS,
    lr: float = 1e-4,
    batch_size: int = 1,
    device: str = DEVICE,
    max_instructions: int = 50,  # Reduced from suggested 180 to prevent memory issues
    max_lr: float = 1e-3,        # Maximum learning rate for scheduler
    min_lr: float = 1e-5         # Minimum learning rate for scheduler
) -> None:
    """
    Train the WorldModel to predict sequences of ARM instructions.
    
    Args:
        model: The WorldModel to train
        dataset: The dataset containing program-instruction pairs
        epochs: Number of training epochs
        lr: Learning rate for the optimizer
        batch_size: Batch size for training
        device: Device to train on
        max_instructions: Maximum number of instructions to predict
    """
    print(f"Training sequence model on device: {device}")
    model = model.to(device)
    optimizer = optim.Adam(model.parameters(), lr=lr)
    
    # Add learning rate scheduler for stability
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(
        optimizer, 
        mode='min', 
        factor=0.5, 
        patience=3, 
        verbose=True, 
        min_lr=min_lr
    )
    
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
    
    # Track statistics about sequences
    sequence_length_distribution = {}
    
    for epoch in range(epochs):
        total_loss = 0.0
        total_accuracy = 0.0
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
            'sequence_length': 0.0,
            'overall': 0.0
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
                
                # Track sequence length distribution
                seq_length = len(armresult_data)
                if seq_length not in sequence_length_distribution:
                    sequence_length_distribution[seq_length] = 0
                sequence_length_distribution[seq_length] += 1
                
                # Move target ArmResults to device if needed
                for i in range(len(armresult_data)):
                    if hasattr(armresult_data[i], 'to_device'):
                        armresult_data[i].to_device(device)
                
                # Reset gradients
                optimizer.zero_grad()
                
                # Generate a sequence of instructions
                generated_sequence = model.generate_instruction_sequence(json_data, max_instructions=max_instructions)
                
                # Calculate loss using the sequence_halter values from the model
                loss = compare_instruction_sequences(generated_sequence, armresult_data, model.halter_values)
                
                # Calculate comprehensive evaluation metrics
                metrics = calculate_sequence_metrics(generated_sequence, armresult_data, model.halter_values)
                
                # Backward pass and optimize
                loss.backward()
                
                # Add gradient clipping to prevent exploding gradients
                max_norm = 1.0  # Maximum gradient norm
                nn.utils.clip_grad_norm_(model.parameters(), max_norm)
                
                optimizer.step()
                
                # Track loss
                loss_val = loss.item()
                if not t.isnan(t.tensor(loss_val, device=DEVICE)) and not t.isinf(t.tensor(loss_val, device=DEVICE)):
                    total_loss += loss_val
                    valid_samples += 1
                    
                    # Track metrics
                    for key, value in metrics.items():
                        if key not in accuracy_totals:
                            accuracy_totals[key] = 0.0
                        accuracy_totals[key] += value
                    
                    # Display running loss and accuracy in progress bar
                    running_loss = total_loss / valid_samples
                    running_accuracy = metrics['overall']
                    total_accuracy += running_accuracy
                    
                    # Calculate average sequence length stats
                    avg_target_len = accuracy_totals.get('target_length', 0) / valid_samples
                    avg_gen_len = accuracy_totals.get('generated_length', 0) / valid_samples
                    single_instr_rate = accuracy_totals.get('single_instruction_rate', 0) / valid_samples
                    
                    # Show key metrics in progress bar
                    progress_bar.set_postfix({
                        "loss": f"{running_loss:.2f}", 
                        "acc": f"{running_accuracy:.2f}",
                        "tgt_len": f"{avg_target_len:.1f}",
                        "gen_len": f"{avg_gen_len:.1f}",
                        "1-instr": f"{single_instr_rate:.2f}"
                    })
            except Exception as e:
                print(f"Error processing example {idx}: {str(e)}")
                # Enhanced exception handling
                import traceback
                traceback.print_exc()
                continue
        
        # Print epoch summary
        if valid_samples > 0:
            avg_loss = total_loss / valid_samples
            avg_accuracy = total_accuracy / valid_samples
            print(f"Epoch {epoch+1}/{epochs}, Average Loss: {avg_loss:.6f}, Average Accuracy: {avg_accuracy:.4f}, Valid Samples: {valid_samples}/{train_size}")
            
            # Update learning rate scheduler based on average loss
            scheduler.step(avg_loss)
            
            # Print sequence length distribution
            if epoch == 0:  # Only print on first epoch to avoid repetition
                print("\nSequence Length Distribution:")
                total_samples = sum(sequence_length_distribution.values())
                sorted_lengths = sorted(sequence_length_distribution.items())
                for length, count in sorted_lengths:
                    percentage = (count / total_samples) * 100
                    print(f"  Length {length}: {count}/{total_samples} ({percentage:.1f}%)")
            
            # Print detailed accuracy metrics with special focus on sequence length
            print("\nDetailed Accuracy Metrics:")
            
            # Group metrics for better readability
            sequence_keys = [
                'sequence_length', 'length_match_rate', 'too_short_rate', 
                'too_long_rate', 'single_instruction_rate', 
                'missed_instructions_pct', 'extra_instructions_pct',
                'target_length', 'generated_length'
            ]
            
            instruction_keys = [
                'instruction_type', 'registers', 'addressing_mode', 
                'shift_type', 'extend_type', 'condition', 
                'has_label', 'literal', 'label_id', 'has_literal'
            ]
            
            # Print sequence statistics first (most important)
            print("\n-- Sequence Statistics --")
            for key in sequence_keys:
                if key in accuracy_totals:
                    component_avg = accuracy_totals[key] / valid_samples
                    print(f"  {key}: {component_avg:.4f}")
            
            # Then print instruction-level statistics
            print("\n-- Instruction-Level Statistics --")
            for key in instruction_keys:
                if key in accuracy_totals:
                    component_avg = accuracy_totals[key] / valid_samples
                    print(f"  {key}: {component_avg:.4f}")
            
            # Finally print overall metrics
            print("\n-- Overall --")
            print(f"  overall: {accuracy_totals['overall'] / valid_samples:.4f}")
            if 'halter_accuracy' in accuracy_totals:
                print(f"  halter_accuracy: {accuracy_totals['halter_accuracy'] / valid_samples:.4f}")
            if 'instruction_type_match_rate' in accuracy_totals:
                print(f"  instruction_type_match_rate: {accuracy_totals['instruction_type_match_rate'] / valid_samples:.4f}")
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
                
                # Move target ArmResults to device if needed
                for i in range(len(armresult_data)):
                    if hasattr(armresult_data[i], 'to_device'):
                        armresult_data[i].to_device(device)
                
                # Generate a sequence of instructions
                generated_sequence = model.generate_instruction_sequence(json_data, max_instructions=max_instructions)
                
                # Calculate loss
                loss = compare_instruction_sequences(generated_sequence, armresult_data, model.halter_values)
                
                # Calculate comprehensive evaluation metrics
                metrics = calculate_sequence_metrics(generated_sequence, armresult_data, model.halter_values)
                
                # Track loss
                loss_val = loss.item()
                if not t.isnan(t.tensor(loss_val, device=DEVICE)) and not t.isinf(t.tensor(loss_val, device=DEVICE)):
                    test_loss += loss_val
                    valid_test_samples += 1
                    
                    # Track metrics
                    for key, value in metrics.items():
                        if key not in test_accuracy_totals:
                            test_accuracy_totals[key] = 0.0
                        test_accuracy_totals[key] += value
                    
                    # Display running loss and accuracy in progress bar
                    running_loss = test_loss / valid_test_samples
                    running_accuracy = metrics['overall']
                    test_accuracy += running_accuracy
                    
                    # Calculate average sequence length stats
                    avg_target_len = test_accuracy_totals.get('target_length', 0) / valid_test_samples
                    avg_gen_len = test_accuracy_totals.get('generated_length', 0) / valid_test_samples
                    single_instr_rate = test_accuracy_totals.get('single_instruction_rate', 0) / valid_test_samples
                    
                    # Show key metrics in progress bar
                    test_progress_bar.set_postfix({
                        "loss": f"{running_loss:.2f}", 
                        "acc": f"{running_accuracy:.2f}",
                        "tgt_len": f"{avg_target_len:.1f}",
                        "gen_len": f"{avg_gen_len:.1f}",
                        "1-instr": f"{single_instr_rate:.2f}"
                    })
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
            component_avg = test_accuracy_totals[key] / valid_test_samples
            print(f"  {key}: {component_avg:.4f}")
    else:
        print("No valid test samples.")

if __name__ == "__main__":
    # Set data directory
    data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "wacc-json")
    
    # Create dataset
    dataset = WACCDataset(data_dir=data_dir)
    print(f"Dataset loaded with {len(dataset)} examples")
    
    # Create model
    model = WorldModel(embedding_dim=EMBEDDING_DIM)
    
    # Load pre-trained weights if available
    pretrained_path = os.path.join(os.path.dirname(__file__), "trained_model.pt")
    if os.path.exists(pretrained_path):
        print(f"Loading pre-trained model from {pretrained_path}")
        model.load_state_dict(t.load(pretrained_path, map_location=DEVICE), strict=False)
    
    # Train model to predict sequences
    train_sequence_model(model, dataset, epochs=TRAIN_EPOCHS, device=DEVICE, max_instructions=180)
    
    # Save the trained model
    model_path = os.path.join(os.path.dirname(__file__), "trained_sequence_model.pt")
    # Move model to CPU before saving to ensure compatibility
    model = model.to('cpu')
    t.save(model.state_dict(), model_path)
    print(f"Sequence model saved to {model_path}") 