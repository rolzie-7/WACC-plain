import os
import json
import glob
import torch
from typing import List, Dict, Tuple, Any, Generator, Optional
import vector2arm

class WACCDataset:
    """
    Dataset for pairing WACC JSON files with their corresponding ARMRESULT.pt files.
    Implements lazy loading for efficiency.
    """
    def __init__(self, data_dir: str = 'wacc-json'):
        """
        Initialize the dataset by finding all JSON and ARMRESULT.pt file pairs.
        
        Args:
            data_dir: Directory containing the JSON and ARMRESULT.pt files
        """
        self.data_dir = data_dir
        self.file_pairs = self._find_file_pairs()
        
    def _find_file_pairs(self) -> List[Tuple[str, str]]:
        """Find all matching JSON and ARMRESULT.pt file pairs."""
        # Find all JSON files
        json_files = glob.glob(os.path.join(self.data_dir, "*.json"))
        
        # Create a mapping from the base name (without ARMRESULT.pt) to the ARMRESULT.pt file
        armresult_files = glob.glob(os.path.join(self.data_dir, "*ARMRESULT.pt"))
        armresult_map = {}
        
        for arm_file in armresult_files:
            # Extract the base name by removing the ARMRESULT.pt suffix
            base_name = os.path.basename(arm_file).replace("ARMRESULT.pt", "")
            armresult_map[base_name] = arm_file
        
        # Match JSON files with their corresponding ARMRESULT.pt files
        pairs = []
        for json_file in json_files:
            base_name = os.path.basename(json_file).replace(".json", "")
            if base_name in armresult_map:
                pairs.append((json_file, armresult_map[base_name]))
        
        return pairs
    
    def __len__(self) -> int:
        """Return the number of file pairs."""
        return len(self.file_pairs)
    
    def __getitem__(self, idx: int) -> Tuple[Dict[str, Any], Any]:
        """
        Get a pair of JSON and ARMRESULT.pt files by index.
        Implements lazy loading - only loads the files when accessed.
        
        Args:
            idx: Index of the file pair to load
            
        Returns:
            Tuple of (JSON content as dict, ARMRESULT.pt content)
        """
        if idx >= len(self.file_pairs):
            raise IndexError(f"Index {idx} out of range for dataset with {len(self.file_pairs)} items")
        
        json_file, armresult_file = self.file_pairs[idx]
        
        # Load JSON file
        with open(json_file, 'r') as f:
            json_content = json.load(f)
        
        # Load ARMRESULT.pt file
        armresult_content = torch.load(armresult_file)
        
        return json_content, armresult_content
    
    def get_file_paths(self, idx: int) -> Tuple[str, str]:
        """Get the file paths for a specific index without loading the files."""
        if idx >= len(self.file_pairs):
            raise IndexError(f"Index {idx} out of range for dataset with {len(self.file_pairs)} items")
        
        return self.file_pairs[idx]
    
    def iter_lazy(self) -> Generator[Tuple[Dict[str, Any], Any], None, None]:
        """
        Iterate through all file pairs lazily, loading each pair only when needed.
        
        Yields:
            Tuple of (JSON content as dict, ARMRESULT.pt content)
        """
        for idx in range(len(self.file_pairs)):
            yield self[idx]


# Example usage:
if __name__ == "__main__":
    # Create dataset
    dataset = WACCDataset()
    
    # Print the number of file pairs found
    print(f"Found {len(dataset)} file pairs")
    
    # Print the first 5 file pairs (paths only, no loading)
    print("File pairs (first 5):")
    for idx in range(min(5, len(dataset))):
        json_path, armresult_path = dataset.get_file_paths(idx)
        print(f"  {idx}: {os.path.basename(json_path)} -> {os.path.basename(armresult_path)}")
    
    # Access a specific pair (lazy loading)
    if len(dataset) > 0:
        print("\nAccessing first item:")
        json_data, armresult_data = dataset[0]
        print(f"  JSON type: {type(json_data)}")
        print(f"  ARMRESULT type: {type(armresult_data)}")
