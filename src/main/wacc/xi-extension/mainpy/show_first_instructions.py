import os
import torch as t
from collections import Counter, defaultdict
from dataset import WACCDataset

# Load dataset
data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "wacc-json")
dataset = WACCDataset(data_dir=data_dir)
print(f"Dataset has {len(dataset)} samples")

# Get a random sample from the dataset (or you can choose a specific one)
samples_to_test = 10
print(len(dataset))
for idx in range(samples_to_test):
    # idx = random.randint(0, len(dataset) - 1)
    json_data, armresult_data = dataset[idx]
    armresult_data = armresult_data[0]
    # print(json_data)
    # print("Instruction type: ", armresult_data.instruction_type)
    # print("Registers: ", armresult_data.registers)
    # print("Addressing mode: ", armresult_data.addressing_mode)
    # print("Shift type: ", armresult_data.shift_type)
    # print("Extend type: ", armresult_data.extend_type)
    # print("Condition: ", armresult_data.condition)
    print("Has label: ", armresult_data.has_label)
    print("Has literal: ", armresult_data.has_literal)
    print("Literal: ", armresult_data.literal)
    print("Label ID: ", armresult_data.label_id)