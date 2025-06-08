#!/usr/bin/env python3

import unittest
import sys
import os

# Add the parent directory to the path so we can import the arm64_parser package
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Import the test module
from arm64_parser.test_arm64 import (
    TestRegister, TestAddressingMode, TestExtendType, TestShiftType,
    TestCondition, TestInstructionType, TestParamType, TestInstruction,
    TestOperands, TestLabel, TestDirective, TestAssemblyProgram, TestIntegration
)

if __name__ == "__main__":
    # Create a test suite with all test cases
    test_suite = unittest.TestSuite()
    
    # Add test cases to the suite
    test_classes = [
        TestRegister, TestAddressingMode, TestExtendType, TestShiftType,
        TestCondition, TestInstructionType, TestParamType, TestInstruction,
        TestOperands, TestLabel, TestDirective, TestAssemblyProgram, TestIntegration
    ]
    
    for test_class in test_classes:
        tests = unittest.defaultTestLoader.loadTestsFromTestCase(test_class)
        test_suite.addTests(tests)
    
    # Run the tests
    print("Running ARM64 parser tests...")
    result = unittest.TextTestRunner(verbosity=2).run(test_suite)
    
    # Exit with non-zero code if there were failures
    sys.exit(not result.wasSuccessful()) 