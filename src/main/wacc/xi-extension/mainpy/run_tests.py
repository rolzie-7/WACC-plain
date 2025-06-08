import pytest
import sys
import os

def main():
    # Get the directory containing this script
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Add the current directory to Python path
    sys.path.append(current_dir)
    
    # Run the tests with full path to test file
    test_file = os.path.join(current_dir, 'test_transformers.py')
    
    pytest.main([
        test_file,
        '-v',  # verbose output
        '--capture=no'  # show print statements
    ])

if __name__ == "__main__":
    main()