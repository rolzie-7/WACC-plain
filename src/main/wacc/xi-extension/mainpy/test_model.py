import os
import torch as t
import random
from world_model import WorldModel
from dataset import WACCDataset
from arm_config import EMBEDDING_DIM, INSTRUCTION_TYPES, REGISTERS, ADDRESSING_MODES, SHIFT_TYPES, EXTEND_TYPES, CONDITIONS, DEVICE, to_device, REG_INSTR_NO

SAMPLES_TO_TEST = 231
# Configuration constants
TRAINED_EMBEDDING_DIM = EMBEDDING_DIM
DISPLAY_CONFIG = {
    'line_width': 80,               # Width of display lines
    'column_width': 38,             # Width for each column in side-by-side display
    'show_full_tensors': False,     # Whether to show full tensor values or truncated versions
    'max_tensor_values': 5,         # Maximum number of tensor values to display when truncated
    'match_symbol': '✓',            # Symbol for matching values
    'mismatch_symbol': '✗',         # Symbol for mismatching values
    'show_traceback': False,        # Whether to show full traceback on errors
}

def safe_tensor_value(tensor_or_value):
    """Safely extract value from tensor or return the value itself if not a tensor."""
    if hasattr(tensor_or_value, 'item'):
        try:
            # Move tensor to device first
            if hasattr(tensor_or_value, 'to'):
                tensor_or_value = tensor_or_value.to(DEVICE)
            return tensor_or_value.item()
        except (ValueError, RuntimeError):
            # For multi-element tensors, convert to list
            if hasattr(tensor_or_value, 'to'):
                tensor_or_value = tensor_or_value.to(DEVICE)
            return tensor_or_value.detach().cpu().tolist()
    return tensor_or_value

def format_tensor_for_display(tensor, max_values=None):
    """Format a tensor for display, showing at most max_values elements."""
    if tensor is None:
        return "None"
    
    # Move tensor to device
    if hasattr(tensor, 'to'):
        tensor = tensor.to(DEVICE)
    
    max_values = max_values or DISPLAY_CONFIG['max_tensor_values']
    
    if hasattr(tensor, 'detach'):
        tensor = tensor.detach().cpu()
        
        # Convert tensor to list for display
        values = tensor.tolist()
        
        # Handle different tensor shapes
        if isinstance(values, list):
            if any(isinstance(v, list) for v in values):
                # For 2D+ tensors, just show the shape
                return f"Tensor of shape {list(tensor.size())}"
            
            # For 1D tensor, show values (truncated if needed)
            if len(values) > max_values and not DISPLAY_CONFIG['show_full_tensors']:
                return f"{values[:max_values]} (+ {len(values) - max_values} more)"
            return f"{values}"
        else:
            # For 0D tensor (scalar)
            return f"{values}"
    
    # For non-tensor values
    return str(tensor)

def get_name_by_index(index, mapping_dict):
    """Helper function to get a name from index using a mapping dictionary"""
    for name, idx in mapping_dict.items():
        if idx == index:
            return name
    return f"Unknown ({index})"

def test_trained_model():
    # Set data directory
    data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "wacc-json")
    
    # Create dataset
    dataset = WACCDataset(data_dir=data_dir)
    print(f"Dataset loaded with {len(dataset)} examples")
    
    # Create model with the same parameters used during training
    model = WorldModel(embedding_dim=TRAINED_EMBEDDING_DIM)
    
    # Load trained weights
    model_path = os.path.join(os.path.dirname(__file__), "trained_model.pt")
    model.load_state_dict(t.load(model_path, map_location=DEVICE))
    model.to(DEVICE)  # Move model to the specified device
    model.eval()  # Set to evaluation mode
    print(f"Model loaded from {model_path} and moved to {DEVICE}")
    
    # Initialize statistics tracking
    stats = {
        'samples_processed': 0,
        'samples_errored': 0,
        'field_matches': {
            'instruction_type': 0,
            'registers': 0,
            'addressing_mode': 0,
            'shift_type': 0,
            'extend_type': 0,
            'condition': 0,
            'has_label': 0,
            'literal': 0,
            'has_literal': 0,
        },
        'total_fields_checked': 0
    }
    
    # Get a random sample from the dataset (or you can choose a specific one)
    samples_to_test = SAMPLES_TO_TEST
    print(len(dataset))
    for idx in range(samples_to_test):
        # idx = random.randint(0, len(dataset) - 1)
        
        try:
            # Get the data
            json_data, armresult_data = dataset[idx]
            
            # Move data to device
            if isinstance(json_data, t.Tensor):
                json_data = to_device(json_data)
            if isinstance(armresult_data, list):
                for i in range(len(armresult_data)):
                    # Move any tensors within the ARM result to device
                    if hasattr(armresult_data[i], 'to_device'):
                        armresult_data[i].to_device(DEVICE)
            
            print(f"\n{'='*50}")
            print(f"Testing sample {idx}")
            print(f"{'='*50}")
            
            # Ensure armresult_data is a list with at least one element
            if not isinstance(armresult_data, list) or len(armresult_data) == 0:
                print(f"Sample {idx} has no ARM result data, skipping")
                stats['samples_errored'] += 1
                continue
            
            # Get the first ArmResult as the target
            target_arm_result = armresult_data[0]
            
            # Forward pass through the model
            with t.no_grad():
                model_output = model(json_data)
            
            # Get the generated ArmResult
            generated_arm_result = model.output_to_arm()
            
            # Ensure tensors are on the correct device
            if hasattr(target_arm_result, 'to_device'):
                target_arm_result.to_device(DEVICE)
            if hasattr(generated_arm_result, 'to_device'):
                generated_arm_result.to_device(DEVICE)
            
            # Print the JSON data in a simplified format
            print("\nInput JSON:")
            print_simplified_json(json_data)
            
            # Compare and display the ArmResult objects (only tensor fields)
            # Instruction Type
            print(f"\n{'-'*20}INSTRUCTION TYPE{'-'*20}")
            target_instr_idx = target_arm_result.instruction_type.to(DEVICE).argmax().item()
            generated_instr_idx = generated_arm_result.instruction_type.to(DEVICE).argmax().item()
            
            target_instr = get_name_by_index(target_instr_idx, INSTRUCTION_TYPES)
            generated_instr = get_name_by_index(generated_instr_idx, INSTRUCTION_TYPES)
            
            match = target_instr_idx == generated_instr_idx
            match_symbol = DISPLAY_CONFIG['match_symbol'] if match else DISPLAY_CONFIG['mismatch_symbol']
            if match:
                stats['field_matches']['instruction_type'] += 1
            stats['total_fields_checked'] += 1
            
            print(f"Generated: {generated_instr:<20} | Target: {target_instr:<20}")
            print(f"Tensor: {format_tensor_for_display(generated_arm_result.instruction_type, DISPLAY_CONFIG['max_tensor_values']):<20} | {format_tensor_for_display(target_arm_result.instruction_type, DISPLAY_CONFIG['max_tensor_values']):<20}")
            print(f"Match: {match_symbol}")
            
            # Registers
            print(f"\n{'-'*20}REGISTERS{'-'*20}")
            all_regs_match = True
            for i in range(REG_INSTR_NO):  # Assuming up to 4 registers
                target_reg_idx = target_arm_result.registers[i].to(DEVICE).argmax().item()
                generated_reg_idx = generated_arm_result.registers[i].to(DEVICE).argmax().item()
                
                target_reg = get_name_by_index(target_reg_idx, REGISTERS)
                generated_reg = get_name_by_index(generated_reg_idx, REGISTERS)
                
                match = target_reg_idx == generated_reg_idx
                if not match:
                    all_regs_match = False
                match_symbol = DISPLAY_CONFIG['match_symbol'] if match else DISPLAY_CONFIG['mismatch_symbol']
                
                print(f"Register {i}:")
                print(f"Generated: {generated_reg:<20} | Target: {target_reg:<20}")
                print(f"Tensor: {format_tensor_for_display(generated_arm_result.registers[i], DISPLAY_CONFIG['max_tensor_values']):<20} | {format_tensor_for_display(target_arm_result.registers[i], DISPLAY_CONFIG['max_tensor_values']):<20}")
                print(f"Match: {match_symbol}")
            
            if all_regs_match:
                stats['field_matches']['registers'] += 1
            stats['total_fields_checked'] += 1
            
            # Addressing Mode
            print(f"\n{'-'*20}ADDRESSING MODE{'-'*20}")
            target_addr_mode_idx = target_arm_result.addressing_mode.to(DEVICE).argmax().item()
            generated_addr_mode_idx = generated_arm_result.addressing_mode.to(DEVICE).argmax().item()
            
            target_addr_mode = get_name_by_index(target_addr_mode_idx, ADDRESSING_MODES)
            generated_addr_mode = get_name_by_index(generated_addr_mode_idx, ADDRESSING_MODES)
            
            match = target_addr_mode_idx == generated_addr_mode_idx
            match_symbol = DISPLAY_CONFIG['match_symbol'] if match else DISPLAY_CONFIG['mismatch_symbol']
            if match:
                stats['field_matches']['addressing_mode'] += 1
            stats['total_fields_checked'] += 1
            
            print(f"Generated: {generated_addr_mode:<20} | Target: {target_addr_mode:<20}")
            print(f"Tensor: {format_tensor_for_display(generated_arm_result.addressing_mode, DISPLAY_CONFIG['max_tensor_values']):<20} | {format_tensor_for_display(target_arm_result.addressing_mode, DISPLAY_CONFIG['max_tensor_values']):<20}")
            print(f"Match: {match_symbol}")
            
            # Shift Type
            print(f"\n{'-'*20}SHIFT TYPE{'-'*20}")
            target_shift_type_idx = target_arm_result.shift_type.to(DEVICE).argmax().item()
            generated_shift_type_idx = generated_arm_result.shift_type.to(DEVICE).argmax().item()
            
            target_shift_type = get_name_by_index(target_shift_type_idx, SHIFT_TYPES)
            generated_shift_type = get_name_by_index(generated_shift_type_idx, SHIFT_TYPES)
            
            match = target_shift_type_idx == generated_shift_type_idx
            match_symbol = DISPLAY_CONFIG['match_symbol'] if match else DISPLAY_CONFIG['mismatch_symbol']
            if match:
                stats['field_matches']['shift_type'] += 1
            stats['total_fields_checked'] += 1
            
            print(f"Generated: {generated_shift_type:<20} | Target: {target_shift_type:<20}")
            print(f"Tensor: {format_tensor_for_display(generated_arm_result.shift_type, DISPLAY_CONFIG['max_tensor_values']):<20} | {format_tensor_for_display(target_arm_result.shift_type, DISPLAY_CONFIG['max_tensor_values']):<20}")
            print(f"Match: {match_symbol}")
            
            # Extend Type
            print(f"\n{'-'*20}EXTEND TYPE{'-'*20}")
            target_extend_type_idx = target_arm_result.extend_type.to(DEVICE).argmax().item()
            generated_extend_type_idx = generated_arm_result.extend_type.to(DEVICE).argmax().item()
            
            target_extend_type = get_name_by_index(target_extend_type_idx, EXTEND_TYPES)
            generated_extend_type = get_name_by_index(generated_extend_type_idx, EXTEND_TYPES)
            
            match = target_extend_type_idx == generated_extend_type_idx
            match_symbol = DISPLAY_CONFIG['match_symbol'] if match else DISPLAY_CONFIG['mismatch_symbol']
            if match:
                stats['field_matches']['extend_type'] += 1
            stats['total_fields_checked'] += 1
            
            print(f"Generated: {generated_extend_type:<20} | Target: {target_extend_type:<20}")
            print(f"Tensor: {format_tensor_for_display(generated_arm_result.extend_type, DISPLAY_CONFIG['max_tensor_values']):<20} | {format_tensor_for_display(target_arm_result.extend_type, DISPLAY_CONFIG['max_tensor_values']):<20}")
            print(f"Match: {match_symbol}")
            
            # Condition
            print(f"\n{'-'*20}CONDITION{'-'*20}")
            target_condition_idx = target_arm_result.condition.to(DEVICE).argmax().item()
            generated_condition_idx = generated_arm_result.condition.to(DEVICE).argmax().item()
            
            target_condition = get_name_by_index(target_condition_idx, CONDITIONS)
            generated_condition = get_name_by_index(generated_condition_idx, CONDITIONS)
            
            match = target_condition_idx == generated_condition_idx
            match_symbol = DISPLAY_CONFIG['match_symbol'] if match else DISPLAY_CONFIG['mismatch_symbol']
            if match:
                stats['field_matches']['condition'] += 1
            stats['total_fields_checked'] += 1
            
            print(f"Generated: {generated_condition:<20} | Target: {target_condition:<20}")
            print(f"Tensor: {format_tensor_for_display(generated_arm_result.condition, DISPLAY_CONFIG['max_tensor_values']):<20} | {format_tensor_for_display(target_arm_result.condition, DISPLAY_CONFIG['max_tensor_values']):<20}")
            print(f"Match: {match_symbol}")
            
            # Has Label
            print(f"\n{'-'*20}HAS LABEL{'-'*20}")
            target_has_label = safe_tensor_value(to_device(target_arm_result.has_label))
            generated_has_label = safe_tensor_value(to_device(generated_arm_result.has_label))
            
            match = target_has_label == generated_has_label
            match_symbol = DISPLAY_CONFIG['match_symbol'] if match else DISPLAY_CONFIG['mismatch_symbol']
            if match:
                stats['field_matches']['has_label'] += 1
            stats['total_fields_checked'] += 1
            
            print(f"Value: {generated_has_label:<20} | {target_has_label:<20}")
            print(f"Tensor: {format_tensor_for_display(generated_arm_result.has_label):<20} | {format_tensor_for_display(target_arm_result.has_label):<20}")
            print(f"Match: {match_symbol}")
            
            # Literal
            print(f"\n{'-'*20}LITERAL{'-'*20}")
            target_literal = safe_tensor_value(to_device(target_arm_result.literal))
            generated_literal = safe_tensor_value(to_device(generated_arm_result.literal))
            
            match = abs(target_literal - generated_literal) < 1.0
            match_symbol = DISPLAY_CONFIG['match_symbol'] if match else DISPLAY_CONFIG['mismatch_symbol']
            if match:
                stats['field_matches']['literal'] += 1
            stats['total_fields_checked'] += 1
            
            print(f"Value: {generated_literal:<20} | {target_literal:<20}")
            print(f"Match: {match_symbol}")
            
            # Has Literal
            print(f"\n{'-'*20}HAS LITERAL{'-'*20}")
            # Handle case where has_literal might not exist
            if hasattr(target_arm_result, 'has_literal') and hasattr(generated_arm_result, 'has_literal'):
                target_has_literal = safe_tensor_value(to_device(target_arm_result.has_literal))
                generated_has_literal = safe_tensor_value(to_device(generated_arm_result.has_literal))
                
                # Check if has_literal is a binary flag (0 or 1)
                target_has_literal_bool = target_has_literal > 0.5 if hasattr(target_has_literal, '__gt__') else bool(target_has_literal)
                generated_has_literal_bool = generated_has_literal > 0.5 if hasattr(generated_has_literal, '__gt__') else bool(generated_has_literal)
                
                match = target_has_literal_bool == generated_has_literal_bool
                match_symbol = DISPLAY_CONFIG['match_symbol'] if match else DISPLAY_CONFIG['mismatch_symbol']
                if match:
                    stats['field_matches']['has_literal'] += 1
                stats['total_fields_checked'] += 1
                
                print(f"Value: {generated_has_literal:<20} | {target_has_literal:<20}")
                print(f"Boolean: {generated_has_literal_bool:<20} | {target_has_literal_bool:<20}")
                print(f"Match: {match_symbol}")
            else:
                print("Has literal field not found in one or both ARM results")
            
            # Update the successful sample count
            stats['samples_processed'] += 1
            
        except Exception as e:
            print(f"Error processing sample {idx}: {e}")
            if DISPLAY_CONFIG['show_traceback']:
                import traceback
                traceback.print_exc()
            stats['samples_errored'] += 1
    
    # Print summary statistics
    print("\n" + "="*50)
    print("SUMMARY STATISTICS")
    print("="*50)
    print(f"Samples processed: {stats['samples_processed']} of {samples_to_test} attempted")
    print(f"Samples with errors: {stats['samples_errored']}")
    
    if stats['samples_processed'] > 0:
        overall_accuracy = sum(stats['field_matches'].values()) / stats['total_fields_checked'] * 100
        print(f"\nOverall accuracy: {overall_accuracy:.2f}%")
        
        print("\nField-by-field accuracy:")
        for field, matches in stats['field_matches'].items():
            field_accuracy = (matches / stats['samples_processed']) * 100
            print(f"  {field}: {field_accuracy:.2f}%")
        
        # Quality assessment
        if overall_accuracy > 90:
            quality = "Excellent"
        elif overall_accuracy > 75:
            quality = "Good"
        elif overall_accuracy > 50:
            quality = "Fair"
        else:
            quality = "Needs improvement"
        
        print(f"\nModel quality assessment: {quality}")

def print_simplified_json(json_data):
    """Print a simplified version of the JSON data"""
    if not isinstance(json_data, dict):
        print(f"Non-dictionary data: {type(json_data)}")
        return
    
    # If it's a program, start with key information
    if 'type' in json_data and json_data['type'] == 'Program':
        print(f"Program with {len(json_data.get('functions', []))} functions")
        
        # Print main program type
        if 'main' in json_data:
            main = json_data['main']
            print(f"Main program of type: {main.get('type', 'Unknown')}")
            
            # Try to extract key statements
            statements = []
            current = main
            while 'first' in current and 'second' in current:
                if 'type' in current['first']:
                    statements.append(current['first']['type'])
                current = current['second']
            if current.get('type'):
                statements.append(current['type'])
            
            print(f"Contains statements: {', '.join(statements[:5])}" + 
                  (f" (and {len(statements) - 5} more)" if len(statements) > 5 else ""))
    else:
        # Otherwise just print the keys at the top level
        print(f"Keys: {', '.join(json_data.keys())}")
        
        # And some sample values if it's not too large
        if len(json_data) < 5:
            for k, v in json_data.items():
                print(f"{k}: {str(v)[:50]}{'...' if len(str(v)) > 50 else ''}")

if __name__ == "__main__":
    test_trained_model() 