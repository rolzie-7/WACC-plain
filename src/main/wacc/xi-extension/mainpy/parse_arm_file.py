#!/usr/bin/env python3
import sys
import os
from pathlib import Path
import torch as t

# Add path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# # Mock the arm64_parser module if not available
# try:
#     import arm64_parser.arm64 as arm64
# except ImportError:
#     print("Warning: arm64_parser module not found. Using mock implementation.")
#     class MockArm64:
#         pass
#     arm64 = MockArm64()

try:
    from vector2arm import ArmResult, INSTRUCTION_TYPES, REGISTERS, ADDRESSING_MODES, SHIFT_TYPES, EXTEND_TYPES, CONDITIONS
except ImportError as e:
    print(f"Error importing vector2arm: {e}")
    sys.exit(1)

def parse_arm_file(filepath):
    """Parse an ARM assembly file and convert each instruction to an ArmResult object."""
    
    print(f"Parsing ARM assembly file: {filepath}")
    results = []
    instruction_counts = {}
    
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
                arm_result = ArmResult.from_str(line)
                results.append((line_no, line, arm_result))
                
                # Count instruction types
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
                    
            except Exception as e:
                print(f"Error parsing line {line_no}: {line}")
                print(f"Error: {e}")
    
    print(f"Successfully parsed {len(results)} instructions")
    print("Instruction type distribution:")
    for instr, count in sorted(instruction_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"  {instr}: {count}")
        
    return results

def main():
    if len(sys.argv) < 2:
        print("Usage: python parse_arm_file.py <path_to_arm_file>")
        sys.exit(1)
        
    filepath = sys.argv[1]
    if not os.path.exists(filepath):
        print(f"Error: File not found: {filepath}")
        sys.exit(1)
        
    parse_arm_file(filepath)

if __name__ == "__main__":
    main() 