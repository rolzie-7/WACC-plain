"""
ARM64 parser package for working with ARM64 assembly code.

This package provides tools for parsing, manipulating, and analyzing ARM64 assembly.
It uses integer-based storage for efficiency and provides clean mapping functionality.
"""

from arm64_parser.arm64 import (
    Register, AddressingMode, ExtendType, ShiftType, Condition,
    InstructionType, ParamType, Instruction, Label, Directive,
    ImmediateOperand, RegisterOperand, ShiftedRegisterOperand,
    ExtendedRegisterOperand, MemoryOperand, LabelOperand,
    ConditionOperand, AssemblyProgram
)

__version__ = '1.0.0' 