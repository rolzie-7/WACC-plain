import os
import torch as t
import random
import numpy as np
from typing import List, Dict, Any
import matplotlib.pyplot as plt
from tabulate import tabulate

from dataset import WACCDataset
from world_model import WorldModel
from vector2arm import ArmResult
from arm_config import EMBEDDING_DIM, DEVICE, to_device, INSTRUCTION_TYPES

def get_instruction_name(arm_result: ArmResult) -> str:
    """Get the name of the instruction from the ArmResult."""
    instr_idx = int(arm_result.instruction_type.argmax().item())
    # Reverse lookup in the dictionary
    for name, idx in INSTRUCTION_TYPES.items():
        if idx == instr_idx:
            return name
    return "unknown"

def print_arm_result(arm_result: ArmResult, index: int = None) -> None:
    """Print an ArmResult object in a readable format."""
    instr_name = get_instruction_name(arm_result)
    
    prefix = f"[{index}] " if index is not None else ""
    print(f"{prefix}Instruction: {instr_name}")
    
    # Get registers as list of indices
    reg_indices = arm_result.registers.argmax(dim=1).tolist()
    print(f"  Registers: {reg_indices}")
    
    # Get addressing mode
    addr_mode = arm_result.addressing_mode.argmax().item()
    print(f"  Addressing Mode: {addr_mode}")
    
    # Print other fields
    has_label = arm_result.has_label.item() > 0.5
    if has_label:
        print(f"  Label ID: {int(arm_result.label_id)}")
    
    has_literal = arm_result.has_literal.item() > 0.0
    if has_literal:
        print(f"  Literal: {int(arm_result.literal)}")
    
    # Print condition if present
    cond_idx = arm_result.condition.argmax().item()
    if cond_idx > 0:
        print(f"  Condition: {cond_idx}")
    
    # Print shift type if present
    shift_idx = arm_result.shift_type.argmax().item()
    if shift_idx > 0:
        print(f"  Shift Type: {shift_idx}")
    
    # Print extend type if present
    extend_idx = arm_result.extend_type.argmax().item()
    if extend_idx > 0:
        print(f"  Extend Type: {extend_idx}")

def print_simplified_json(json_data: Dict[str, Any]) -> None:
    """Print a simplified version of the JSON data."""
    # If it's a dictionary with 'ast' key, get the type
    if isinstance(json_data, dict):
        if 'type' in json_data:
            print(f"Type: {json_data['type']}")
        
        if 'ast' in json_data and isinstance(json_data['ast'], dict):
            ast = json_data['ast']
            if 'type' in ast:
                print(f"AST Type: {ast['type']}")
            
            # If the AST has a 'class' key, it might be a program root
            if 'class' in ast:
                print(f"Class: {ast['class']}")
            
            # If the AST has a 'statements' key, show the number of statements
            if 'statements' in ast and isinstance(ast['statements'], list):
                print(f"Number of statements: {len(ast['statements'])}")
                
                # Print types of the first few statements if available
                for i, stmt in enumerate(ast['statements'][:3]):
                    if isinstance(stmt, dict) and 'type' in stmt:
                        print(f"  Statement {i} type: {stmt['type']}")
            
            # If the AST has a 'functions' key, show the number of functions
            if 'functions' in ast and isinstance(ast['functions'], list):
                print(f"Number of functions: {len(ast['functions'])}")
                
                # Print function names if available
                for i, func in enumerate(ast['functions'][:3]):
                    if isinstance(func, dict) and 'name' in func:
                        print(f"  Function {i} name: {func['name']}")

def calculate_accuracy(generated: ArmResult, target: ArmResult) -> float:
    """Calculate a simple accuracy score between two ArmResult objects."""
    # Import the function from the training script
    from train import calculate_accuracy
    return calculate_accuracy(generated, target)['overall']

def visualize_sequence_comparison(generated_seq: List[ArmResult], target_seq: List[ArmResult]) -> None:
    """Visualize the comparison between generated and target sequences."""
    # Get the common length
    common_length = min(len(generated_seq), len(target_seq))
    
    # Calculate accuracy for each pair in the common sequence
    accuracies = []
    for i in range(common_length):
        acc = calculate_accuracy(generated_seq[i], target_seq[i])
        accuracies.append(acc)
    
    # Create labels for the plot
    labels = [f"{i+1}: {get_instruction_name(target_seq[i])}" for i in range(common_length)]
    
    # Plot the accuracies
    plt.figure(figsize=(10, 5))
    plt.bar(range(common_length), accuracies, color='skyblue')
    plt.axhline(y=np.mean(accuracies), color='red', linestyle='-', label=f'Mean: {np.mean(accuracies):.2f}')
    plt.xticks(range(common_length), labels, rotation=45)
    plt.xlabel('Instruction')
    plt.ylabel('Accuracy')
    plt.title('Accuracy of Generated vs Target Instructions')
    plt.ylim(0, 1.0)
    plt.tight_layout()
    plt.legend()
    
    # Save the plot
    plt.savefig('sequence_accuracy.png')
    print(f"Saved visualization to sequence_accuracy.png")
    
    # Create a table with instruction names and accuracies
    table_data = []
    for i in range(common_length):
        gen_name = get_instruction_name(generated_seq[i])
        target_name = get_instruction_name(target_seq[i])
        acc = accuracies[i]
        match = "✓" if gen_name == target_name else "✗"
        table_data.append([i+1, target_name, gen_name, f"{acc:.4f}", match])
    
    # Add entry for missing instructions if lengths differ
    if len(generated_seq) != len(target_seq):
        if len(generated_seq) < len(target_seq):
            for i in range(common_length, len(target_seq)):
                target_name = get_instruction_name(target_seq[i])
                table_data.append([i+1, target_name, "MISSING", "0.0000", "✗"])
        else:
            for i in range(common_length, len(generated_seq)):
                gen_name = get_instruction_name(generated_seq[i])
                table_data.append([i+1, "MISSING", gen_name, "0.0000", "✗"])
    
    # Print the table
    headers = ["#", "Target Instruction", "Generated Instruction", "Accuracy", "Match"]
    print(tabulate(table_data, headers=headers, tablefmt="grid"))
    
    # Print summary statistics
    print(f"\nSummary:")
    print(f"  Target sequence length: {len(target_seq)}")
    print(f"  Generated sequence length: {len(generated_seq)}")
    print(f"  Length match: {'✓' if len(generated_seq) == len(target_seq) else '✗'}")
    print(f"  Average accuracy: {np.mean(accuracies):.4f}")
    
    # Calculate instruction type accuracy
    instr_type_matches = sum(1 for i in range(common_length) 
                            if get_instruction_name(generated_seq[i]) == get_instruction_name(target_seq[i]))
    print(f"  Instruction type accuracy: {instr_type_matches / common_length:.4f}")

def test_model(model_path: str, dataset: WACCDataset, num_samples: int = 5, max_instructions: int = 20) -> None:
    """
    Test the sequence model on a number of samples from the dataset.
    
    Args:
        model_path: Path to the trained model
        dataset: Dataset to test on
        num_samples: Number of samples to test
        max_instructions: Maximum number of instructions to generate
    """
    # Load the model
    model = WorldModel(embedding_dim=EMBEDDING_DIM)
    model.load_state_dict(t.load(model_path, map_location=DEVICE))
    model.to(DEVICE)
    model.eval()
    
    # Choose random samples to test
    dataset_size = len(dataset)
    test_indices = random.sample(range(dataset_size), min(num_samples, dataset_size))
    
    for idx in test_indices:
        print(f"\n{'='*80}")
        print(f"Testing sample {idx}")
        print(f"{'='*80}")
        
        try:
            # Get the data
            json_data, armresult_data = dataset[idx]
            
            # Move data to device if needed
            if isinstance(json_data, t.Tensor):
                json_data = to_device(json_data)
            
            # Ensure armresult_data is a list with at least one element
            if not isinstance(armresult_data, list) or len(armresult_data) == 0:
                print(f"Sample {idx} has no ARM result data, skipping")
                continue
            
            # Move target ArmResults to device if needed
            for i in range(len(armresult_data)):
                if hasattr(armresult_data[i], 'to_device'):
                    armresult_data[i].to_device(DEVICE)
            
            # Print the JSON data in a simplified format
            print("\nInput Program:")
            print_simplified_json(json_data)
            
            print("\nTarget Instruction Sequence:")
            for i, arm_result in enumerate(armresult_data):
                print_arm_result(arm_result, i)
            
            # Generate sequence with the model
            with t.no_grad():
                generated_sequence = model.generate_instruction_sequence(json_data, max_instructions=max_instructions)
            
            print("\nGenerated Instruction Sequence:")
            for i, arm_result in enumerate(generated_sequence):
                print_arm_result(arm_result, i)
            
            # Compare and visualize the sequences
            print("\nSequence Comparison:")
            visualize_sequence_comparison(generated_sequence, armresult_data)
            
        except Exception as e:
            print(f"Error processing sample {idx}: {str(e)}")
            import traceback
            traceback.print_exc()
            continue

if __name__ == "__main__":
    # Set data directory
    data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "wacc-json")
    
    # Create dataset
    dataset = WACCDataset(data_dir=data_dir)
    print(f"Dataset loaded with {len(dataset)} examples")
    
    # Check if sequence model exists, otherwise use regular model
    sequence_model_path = os.path.join(os.path.dirname(__file__), "trained_sequence_model.pt")
    regular_model_path = os.path.join(os.path.dirname(__file__), "trained_model.pt")
    
    if os.path.exists(sequence_model_path):
        print(f"Using sequence model from {sequence_model_path}")
        model_path = sequence_model_path
    elif os.path.exists(regular_model_path):
        print(f"Sequence model not found, using regular model from {regular_model_path}")
        model_path = regular_model_path
    else:
        print("No trained model found. Please train a model first.")
        exit(1)
    
    # Test the model
    num_samples = 5  # Number of samples to test
    test_model(model_path, dataset, num_samples=num_samples) 