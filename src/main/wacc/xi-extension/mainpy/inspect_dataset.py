import os
import torch as t
import sys
from typing import Dict, Any

# Add the parent directory to the path so we can import the dataset
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Import the dataset and other necessary modules
from dataset import WACCDataset
from arm_config import DEVICE

def main():
    # Set data directory (same as in train.py)
    data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "wacc-json")
    
    # Create dataset
    dataset = WACCDataset(data_dir=data_dir)
    print(f"Dataset loaded with {len(dataset)} examples")
    
    # Print instruction type for each sample
    print("\nInspecting instruction types for all samples:")
    print("-" * 50)
    print("Sample ID | Instruction Type | Instruction Index")
    print("-" * 50)
    
    # Track instruction counts
    instruction_counts = {}
    
    for idx in range(len(dataset)):
        try:
            # Get a data pair
            json_data, armresult_data = dataset[idx]
            
            # Ensure armresult_data is a list with at least one element
            if not isinstance(armresult_data, list) or len(armresult_data) == 0:
                print(f"{idx:9d} | Invalid sample  | N/A")
                continue
            
            # Get the first ArmResult as target
            target_arm_result = armresult_data[0]
            
            # Get instruction type
            instr_idx = target_arm_result.instruction_type.argmax().item()
            
            # Print sample info
            print(f"{idx:9d} | {instr_idx:16d} | {target_arm_result.instruction_type}")
            
            # Track instruction counts
            if instr_idx not in instruction_counts:
                instruction_counts[instr_idx] = 0
            instruction_counts[instr_idx] += 1
            
        except Exception as e:
            print(f"{idx:9d} | Error: {str(e)[:30]}... | N/A")
    
    print("\nInstruction Type Summary:")
    print("-" * 50)
    total = len(dataset)
    for instr_idx, count in sorted(instruction_counts.items(), key=lambda x: x[1], reverse=True):
        percentage = (count / total) * 100
        print(f"Instruction {instr_idx:3d}: {count:3d}/{total} samples ({percentage:6.2f}%)")
    
    # Check special indices
    special_indices = [3, 4, 5, 8, 19, 20]
    special_count = sum(instruction_counts.get(idx, 0) for idx in special_indices)
    special_percentage = (special_count / total) * 100
    print(f"\nSpecial indices [3,4,5,8,19,20]: {special_count}/{total} ({special_percentage:.2f}%)")
    
    # Print additional data about the first sample for debugging
    if len(dataset) > 0:
        print("\nDetailed view of first sample:")
        json_data, armresult_data = dataset[0]
        target_arm_result = armresult_data[0]
        
        print(f"Instruction type: {target_arm_result.instruction_type.argmax().item()}")
        print(f"Registers: {[reg.argmax().item() for reg in target_arm_result.registers]}")
        print(f"Addressing mode: {target_arm_result.addressing_mode.argmax().item()}")
        print(f"Shift type: {target_arm_result.shift_type.argmax().item()}")
        print(f"Extend type: {target_arm_result.extend_type.argmax().item()}")
        print(f"Condition: {target_arm_result.condition.argmax().item()}")
        print(f"Has label: {target_arm_result.has_label.item()}")
        print(f"Literal: {target_arm_result.literal.item()}")
        print(f"Label ID: {target_arm_result.label_id.item()}")

if __name__ == "__main__":
    main() 