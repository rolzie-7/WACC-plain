import os
import json
import argparse
import sys
import torch

# Add the mainpy directory to the Python path to import the dataset
mainpy_dir = os.path.join(os.path.dirname(__file__), 'mainpy')
sys.path.append(mainpy_dir)

from mainpy.dataset import WACCDataset


def display_detailed_examples(num_examples: int = 3, show_assembly: bool = True,
                              assembly_preview_length: int = 500, data_dir: str = 'wacc-json'):
    """
    Display detailed examples of WACC JSON and ARM assembly code.
    
    Args:
        num_examples: Number of examples to display
        show_assembly: Whether to show the assembly code
        assembly_preview_length: Length of assembly code preview
        data_dir: Directory containing the dataset
    """
    # Create dataset
    full_data_dir = os.path.join(os.path.dirname(__file__), data_dir)
    dataset = WACCDataset(data_dir=full_data_dir)
    
    # Print the number of file pairs found
    print(f"Found {len(dataset)} file pairs")
    
    if len(dataset) == 0:
        print("No data pairs found in the dataset.")
        return
    
    # Display examples
    for idx in range(min(num_examples, len(dataset))):
        try:
            # Get the file paths
            json_path, armresult_path = dataset.get_file_paths(idx)
            
            # Get the data pair (json_content, armresult_content)
            json_data, armresult_data = dataset[idx]
            
            print(f"\n{'='*80}")
            print(f"Example {idx+1}/{min(num_examples, len(dataset))}")
            print(f"{'='*80}")
            print(f"JSON File: {os.path.basename(json_path)}")
            print(f"ARMRESULT File: {os.path.basename(armresult_path)}")
            
            # Display JSON content
            print("\nJSON Content (summary):")
            if isinstance(json_data, dict):
                if "type" in json_data:
                    print(f"  Type: {json_data['type']}")
            
                # Show program structure
                if "functions" in json_data:
                    print(f"  Number of functions: {len(json_data['functions'])}")
                    if json_data["functions"]:
                        print("  Functions:")
                        for i, func in enumerate(json_data["functions"]):
                            if "type" in func and func["type"] == "FuncDecl" and "identifier" in func:
                                func_name = func["identifier"].get("name", "unnamed") if isinstance(func["identifier"], dict) else "unnamed"
                                print(f"    {i+1}. {func_name}")
                
                # Show main if available
                if "main" in json_data:
                    print("\n  Main Program:")
                    if isinstance(json_data["main"], dict) and "type" in json_data["main"]:
                        print(f"    Type: {json_data['main']['type']}")
                        
                        # If main is a StmtList, show more details
                        if json_data["main"]["type"] == "StmtList" and "first" in json_data["main"]:
                            first_stmt = json_data["main"]["first"]
                            if isinstance(first_stmt, dict) and "type" in first_stmt:
                                print(f"    First statement type: {first_stmt['type']}")
            
            # Display ARMRESULT content
            print("\nARMRESULT Content:")
            
            # Improved handling for ArmResult objects
            if isinstance(armresult_data, list):
                print(f"  List of {len(armresult_data)} ArmResult objects")
                
                # Display the first few ArmResult objects
                max_display = 3  # Only show first few to avoid overwhelming output
                for i, arm_result in enumerate(armresult_data[:max_display]):
                    print(f"\n  ArmResult Object {i+1}:")
                    # Use the __str__ method of the ArmResult object
                    arm_str = str(arm_result)
                    preview_length = assembly_preview_length
                    preview = arm_str[:preview_length] + "..." if len(arm_str) > preview_length else arm_str
                    print(f"    {preview}")
                
                if len(armresult_data) > max_display:
                    print(f"\n  ... and {len(armresult_data) - max_display} more ArmResult objects")
                
                # Try to access common attributes if they exist
                if len(armresult_data) > 0:
                    first_result = armresult_data[0]
                    print("\n  First ArmResult attributes:")
                    
                    # Check for common attributes
                    for attr in ['assembly', 'execution_output', 'exit_code']:
                        if hasattr(first_result, attr):
                            value = getattr(first_result, attr)
                            if attr == 'assembly' and show_assembly:
                                print(f"\n  Assembly Code Preview (first object):")
                                assembly_preview = value[:assembly_preview_length] + "..." if len(value) > assembly_preview_length else value
                                print(assembly_preview)
                            else:
                                value_str = str(value)
                                print(f"    {attr}: {value_str[:100] + '...' if len(value_str) > 100 else value_str}")
            
            else:
                print(f"  Type: {type(armresult_data)}")
                print("  Content Preview:")
                content_str = str(armresult_data)
                preview = content_str[:assembly_preview_length] + "..." if len(content_str) > assembly_preview_length else content_str
                print(preview)
            
            print('-' * 80)
        
        except Exception as e:
            print(f"Error processing example {idx}: {str(e)}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Display detailed examples from the WACC dataset")
    parser.add_argument("-n", "--num-examples", type=int, default=3, 
                        help="Number of examples to display")
    parser.add_argument("--no-assembly", action="store_true", 
                        help="Hide assembly code in the output")
    parser.add_argument("-l", "--length", type=int, default=500, 
                        help="Length of assembly code preview")
    parser.add_argument("-d", "--data-dir", type=str, default="wacc-json",
                        help="Directory containing the dataset files")
    
    args = parser.parse_args()
    
    display_detailed_examples(
        num_examples=args.num_examples,
        show_assembly=not args.no_assembly,
        assembly_preview_length=args.length,
        data_dir=args.data_dir
    ) 