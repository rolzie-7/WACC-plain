#!/usr/bin/env python3

import sys
import os
import glob
import torch as t

# Add path for imports
project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
sys.path.append(os.path.join(project_root, "src/main/wacc/xi-extension/mainpy"))

try:
    from vector2arm import ArmResult, INSTRUCTION_TYPES, REGISTERS
    from label_symbols import reset_label_table
except ImportError as e:
    print(f"Error importing modules: {e}")
    sys.exit(1)

def parse_arm_file(filepath):
    """Parse an ARM assembly file and convert each instruction to an ArmResult object."""
    
    print(f"Parsing file: {filepath}")
    
    # Reset the label table for each new file
    reset_label_table()
    
    results = []
    
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
                    arm_result = ArmResult.from_str(line)
                    results.append(arm_result)
                except Exception as e:
                    print(f"Error parsing line {line_no}: {line}")
                    print(f"Error: {e}")
        
        return results
    except Exception as e:
        print(f"Error processing file {filepath}: {e}")
        return []

def process_folder(folder_path, output_dir=None):
    """
    Process all .asm files in the folder, saving ArmResult objects for each.
    
    Args:
        folder_path: Path to folder containing .asm files
        output_dir: Directory to save output files (defaults to same folder)
    """
    if output_dir is None:
        output_dir = folder_path
    
    os.makedirs(output_dir, exist_ok=True)
    
    # Find all .asm files
    asm_files = glob.glob(os.path.join(folder_path, "*.asm"))
    
    if not asm_files:
        print(f"No .asm files found in {folder_path}")
        return
    
    print(f"Found {len(asm_files)} .asm files")
    
    for asm_file in asm_files:
        base_name = os.path.basename(asm_file)
        output_name = os.path.splitext(base_name)[0] + "ARMRESULT.pt"
        output_path = os.path.join(output_dir, output_name)
        
        print(f"Processing: {base_name}")
        
        # Parse the assembly file
        arm_results = parse_arm_file(asm_file)
        
        if not arm_results:
            print(f"No valid instructions found in {base_name}")
            continue
        
        # Save the results as a torch tensor list
        # We need to convert to a format compatible with PyTorch
        # For ArmResult objects, we can save them directly with torch.save
        t.save(arm_results, output_path)
        
        print(f"Saved {len(arm_results)} ArmResult objects to {output_name}")
    
    print(f"\nProcessed {len(asm_files)} files. Results saved in {output_dir}")

def main():
    # Get the path to the wacc-json folder
    wacc_json_path = os.path.join(project_root, "main/wacc/xi-extension/wacc-json")
    print(f"WACC JSON path: {wacc_json_path}")
    
    # Allow command-line override
    if len(sys.argv) > 1:
        wacc_json_path = sys.argv[1]
    
    if not os.path.exists(wacc_json_path):
        print(f"Error: Directory not found: {wacc_json_path}")
        wacc_json_path = input("Enter path to folder containing .asm files: ").strip()
        if not os.path.exists(wacc_json_path):
            print(f"Error: Directory not found: {wacc_json_path}")
            sys.exit(1)
    
    # Process the folder
    process_folder(wacc_json_path)
    
    print("\nAll done! You can load these files in PyTorch with:")
    print("import torch")
    print("arm_results = torch.load('valid_while_whileFalseARMRESULT.pt')  # example")
    print("\nOr create a DataLoader:")
    print("from torch.utils.data import Dataset, DataLoader")
    print("class ArmResultsDataset(Dataset):")
    print("    def __init__(self, file_paths):")
    print("        self.file_paths = file_paths")
    print("    def __len__(self):")
    print("        return len(self.file_paths)")
    print("    def __getitem__(self, idx):")
    print("        return torch.load(self.file_paths[idx])")
    print("\nfile_paths = glob.glob('*ARMRESULT.pt')")
    print("dataset = ArmResultsDataset(file_paths)")
    print("dataloader = DataLoader(dataset, batch_size=4, shuffle=True)")

if __name__ == "__main__":
    main() 