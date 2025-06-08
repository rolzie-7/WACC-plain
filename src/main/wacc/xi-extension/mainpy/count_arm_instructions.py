#!/usr/bin/env python3
import sys
import os
import re
from pathlib import Path

def count_arm_instructions(filepath):
    """
    Count instructions in an ARM assembly file without parsing them.
    This is useful to check what instructions are present in the files.
    """
    
    print(f"Analyzing ARM assembly file: {filepath}")
    instruction_counts = {}
    total_lines = 0
    instruction_lines = 0
    
    # Regular expression to extract instruction name
    instr_pattern = re.compile(r'^\s*([a-z][a-z0-9.]*)')
    
    with open(filepath, 'r') as f:
        for line_no, line in enumerate(f, 1):
            total_lines += 1
            line = line.strip()
            
            # Skip empty lines, comments, labels, directives
            if not line or line.startswith('//') or line.startswith('.') or line.endswith(':'):
                continue
                
            # Skip directives with arguments (e.g. .word, .asciz)
            if line.startswith('\t.'):
                continue
                
            # Extract instruction name
            match = instr_pattern.match(line)
            if match:
                instruction_lines += 1
                instr = match.group(1)
                
                # Handle conditional instructions (e.g., b.eq)
                if '.' in instr:
                    base_instr, cond = instr.split('.', 1)
                    instr = base_instr
                    
                instruction_counts[instr] = instruction_counts.get(instr, 0) + 1
    
    print(f"Total lines: {total_lines}")
    print(f"Instruction lines: {instruction_lines}")
    print("Instruction distribution:")
    for instr, count in sorted(instruction_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"  {instr}: {count}")
        
    return instruction_counts

def process_directory(dirpath):
    """Process all .s files in a directory and its subdirectories."""
    
    all_counts = {}
    
    for root, dirs, files in os.walk(dirpath):
        for file in files:
            if file.endswith('.s'):
                filepath = os.path.join(root, file)
                print(f"\nProcessing file: {filepath}")
                counts = count_arm_instructions(filepath)
                
                # Merge counts
                for instr, count in counts.items():
                    all_counts[instr] = all_counts.get(instr, 0) + count
    
    print("\n=== Overall Statistics ===")
    print("Total instruction distribution across all files:")
    for instr, count in sorted(all_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"  {instr}: {count}")
    
    return all_counts

def main():
    if len(sys.argv) < 2:
        print("Usage: python count_arm_instructions.py <path_to_arm_file_or_directory>")
        sys.exit(1)
        
    path = sys.argv[1]
    if not os.path.exists(path):
        print(f"Error: Path not found: {path}")
        sys.exit(1)
        
    if os.path.isdir(path):
        process_directory(path)
    else:
        count_arm_instructions(path)

if __name__ == "__main__":
    main() 