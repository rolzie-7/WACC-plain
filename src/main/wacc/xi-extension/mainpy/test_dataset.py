import os
import unittest
from dataset import WACCDataset


class TestWACCDataset(unittest.TestCase):
    """Test case for the WACCDataset class."""
    
    def setUp(self):
        """Set up the dataset for testing."""
        self.data_dir = os.path.join(os.path.dirname(__file__), '../wacc-json')
        self.dataset = WACCDataset(data_dir=self.data_dir)
    
    def test_dataset_initialization(self):
        """Test that the dataset initializes and finds file pairs."""
        self.assertGreater(len(self.dataset), 0, "Dataset should find file pairs")
    
    def test_file_paths(self):
        """Test that the file paths are correctly retrieved."""
        if len(self.dataset) > 0:
            json_path, armresult_path = self.dataset.get_file_paths(0)
            
            self.assertTrue(json_path.endswith('.json'), "JSON path should end with .json")
            self.assertTrue(armresult_path.endswith('ARMRESULT.pt'), "ARMRESULT path should end with ARMRESULT.pt")
            
            # Check that the base names match
            json_base = os.path.basename(json_path).replace('.json', '')
            armresult_base = os.path.basename(armresult_path).replace('ARMRESULT.pt', '')
            
            self.assertEqual(json_base, armresult_base, 
                             "Base names of JSON and ARMRESULT files should match")
    
    def test_lazy_loading(self):
        """Test that lazy loading works correctly."""
        if len(self.dataset) > 0:
            # Access the first item to trigger loading
            json_data, armresult_data = self.dataset[0]
            
            self.assertIsNotNone(json_data, "JSON data should be loaded")
            self.assertIsNotNone(armresult_data, "ARMRESULT data should be loaded")
    
    def test_iter_lazy(self):
        """Test the lazy iterator."""
        count = 0
        for json_data, armresult_data in self.dataset.iter_lazy():
            self.assertIsNotNone(json_data)
            self.assertIsNotNone(armresult_data)
            count += 1
            if count >= 3:  # Just test the first few to save time
                break
        
        self.assertGreater(count, 0, "Iterator should yield at least one item")


if __name__ == '__main__':
    unittest.main() 