#!/usr/bin/env python3

import sys
import os
import re
import time
from pathlib import Path
import torch as t

# Add path for imports
project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
sys.path.append(os.path.join(project_root, "src/main/wacc/xi-extension/mainpy"))

try:
    from vector2arm import ArmResult
    from arm_config import INSTRUCTION_TYPES, REGISTERS
    from label_symbols import reset_label_table, get_all_labels
except ImportError as e:
    print(f"Error importing modules: {e}")
    sys.exit(1)

def parse_arm_file(filepath, output_file=None):
    """Parse an ARM assembly file and convert each instruction to an ArmResult object."""
    
    # Always print the file name to console, regardless of output file
    print(f"Parsing file: {filepath}")
    
    # Reset the label table for each new file
    reset_label_table()
    
    print_or_write = lambda msg: output_file.write(msg + "\n") if output_file else print(msg)
    
    print_or_write(f"Parsing ARM assembly file: {filepath}")
    results = []
    instruction_counts = {}
    success_count = 0
    failure_count = 0
    
    try:
        with open(filepath, 'r') as f:
            for line_no, line in enumerate(f, 1):
                line = line.strip()
                
                # Skip empty lines, comments, labels, directives
                if not line or line.startswith('//') or line.startswith('.') or line.endswith(':'):
                    continue
                    
                # Skip directives with arguments (e.g. .word, .asciz)
                if line.startswith('\t.'):
                    continue
                    
                try:
                    start_time = time.time()
                    arm_result = ArmResult.from_str(line)
                    parse_time = time.time() - start_time
                    
                    # Check for instruction type
                    instr_type = None
                    if hasattr(arm_result, 'instruction_type'):
                        instr_idx = int(arm_result.instruction_type.argmax().item())
                        # Reverse lookup in the dictionary
                        for name, idx in INSTRUCTION_TYPES.items():
                            if idx == instr_idx:
                                instr_type = name
                                break
                    
                    if instr_type:
                        instruction_counts[instr_type] = instruction_counts.get(instr_type, 0) + 1
                    
                    # Print the ARM result for each instruction
                    print_or_write(f"Line {line_no}: {line}")
                    print_or_write(f"ARM Result: {arm_result}")
                    
                    # Print detailed register information
                    print_or_write("Register details:")
                    reg_idxs = arm_result.registers.argmax(dim=1).tolist()
                    reg_vectors = arm_result.registers
                    
                    print_or_write(f"Instruction Type: {instr_type}")
                    for i, reg_idx in enumerate(reg_idxs):
                        reg_name = "Unknown"
                        for name, idx in REGISTERS.items():
                            if idx == reg_idx:
                                reg_name = name
                                break
                        print_or_write(f"  Register slot {i}: Index {reg_idx} ('{reg_name}')")
                    
                    # Print label ID if present
                    if arm_result.label.item() == 1:
                        print_or_write(f"Label ID: {arm_result.label_id}")
                    
                    print_or_write("-" * 50)
                        
                    results.append((line_no, line, arm_result, instr_type, parse_time))
                    success_count += 1
                        
                except Exception as e:
                    print_or_write(f"Error parsing line {line_no}: {line}")
                    print_or_write(f"Error: {e}")
                    failure_count += 1
        
        print_or_write(f"Successfully parsed {success_count} instructions, failed on {failure_count}")
        print_or_write("Instruction type distribution:")
        for instr, count in sorted(instruction_counts.items(), key=lambda x: x[1], reverse=True):
            print_or_write(f"  {instr}: {count}")
        
        # Print summary of labels found in the file
        labels = get_all_labels()
        if labels:
            print_or_write("\nLabels found in this file:")
            for label_name, label_id in sorted(labels.items(), key=lambda x: x[1]):
                print_or_write(f"  {label_name}: ID {label_id}")
        
        file_success = success_count > 0
        return results, file_success
    except Exception as e:
        print_or_write(f"Error processing file {filepath}: {e}")
        return [], False

def process_wacc_examples(wacc_examples_path, max_files=231, output_file=None):
    """Process a sample of ARM assembly files from the wacc-examples directory."""
    
    print_or_write = lambda msg: output_file.write(msg + "\n") if output_file else print(msg)
    
    print_or_write(f"Processing WACC examples from: {wacc_examples_path}")
    processed_files = 0
    successful_files = 0
    failed_files = 0
    
    # Use all the folders specified by the user
    categories = [
        'array', 'basic', 'expressions', 'function', 'if', 'IO', 
        'pairs', 'scope', 'sequence', 'variables', 'while'
    ]
    
    # Process files from each category
    for category in categories:
        category_path = os.path.join(wacc_examples_path, 'valid', category)
        
        if not os.path.exists(category_path):
            print_or_write(f"Warning: Category path {category_path} does not exist")
            continue
            
        # Walk through all files in the category directory and its subdirectories
        for root, dirs, files in os.walk(category_path):
            for file in files:
                if file.endswith('.s'):
                    if processed_files >= max_files:
                        break
                        
                    filepath = os.path.join(root, file)
                    relative_path = os.path.relpath(filepath, wacc_examples_path)
                    # Always print to console which file is being processed
                    print(f"Processing: {relative_path}")
                    print_or_write(f"\n=== Processing Example: {relative_path} ===")
                    _, file_success = parse_arm_file(filepath, output_file)
                    processed_files += 1
                    if file_success:
                        successful_files += 1
                    else:
                        failed_files += 1
            
            if processed_files >= max_files:
                break
                
        if processed_files >= max_files:
            break
    
    # If we haven't processed enough files, try an advanced example
    if processed_files < max_files:
        advanced_path = os.path.join(wacc_examples_path, "test_output.s")
        if os.path.exists(advanced_path):
            # Always print to console when processing the advanced example
            print(f"Processing advanced example: test_output.s")
            print_or_write("\n=== Processing Advanced Example: test_output.s ===")
            _, file_success = parse_arm_file(advanced_path, output_file)
            processed_files += 1
            if file_success:
                successful_files += 1
            else:
                failed_files += 1
        else:
            print_or_write(f"Advanced example not found: {advanced_path}")
            
    return processed_files, successful_files, failed_files

def main():
    MAX_FILES = 5
    # Determine the wacc-examples path
    wacc_examples_path = "/Users/xida/Documents/mainquest/WACC_47/wacc-examples"
    if not os.path.exists(wacc_examples_path):
        print(f"Error: wacc-examples directory not found at {wacc_examples_path}")
        print("Please provide the path to the wacc-examples directory:")
        wacc_examples_path = input("> ").strip()
        if not os.path.exists(wacc_examples_path):
            print(f"Error: Directory not found: {wacc_examples_path}")
            sys.exit(1)
    
    # Create output file
    output_filepath = "wacc_parser_results.txt"
    with open(output_filepath, 'w') as output_file:
        print(f"Writing results to {output_filepath}")
        total_files, successful_files, failed_files = process_wacc_examples(wacc_examples_path, max_files=MAX_FILES, output_file=output_file)
    
    # Display summary at the end
    print(f"\nSummary:")
    print(f"Total files processed: {total_files}")
    print(f"Successfully parsed files: {successful_files}")
    print(f"Failed files: {failed_files}")

if __name__ == "__main__":
    main() 