#!/usr/bin/env python3

import unittest
from arm64_parser.arm64 import (
    Register, AddressingMode, ExtendType, ShiftType, Condition,
    InstructionType, ParamType, Instruction, Label, Directive,
    ImmediateOperand, RegisterOperand, ShiftedRegisterOperand,
    ExtendedRegisterOperand, MemoryOperand, LabelOperand,
    ConditionOperand, AssemblyProgram
)


class TestRegister(unittest.TestCase):
    def test_initialization(self):
        """Test that Register initialization works with valid values"""
        reg = Register(0)  # x0
        self.assertEqual(reg.value, 0)

        reg = Register(30)  # x30
        self.assertEqual(reg.value, 30)

        reg = Register(62)  # sp
        self.assertEqual(reg.value, 62)

    def test_initialization_validation(self):
        """Test that Register initialization validates the input"""
        # Value must be an integer
        with self.assertRaises(TypeError):
            Register("x0")

        # Value must be within valid range
        with self.assertRaises(ValueError):
            Register(-1)

        with self.assertRaises(ValueError):
            Register(66)

    def test_to_string(self):
        """Test conversion of Register to string"""
        self.assertEqual(Register(0).to_string(), "x0")
        self.assertEqual(Register(31).to_string(), "w0")
        self.assertEqual(Register(62).to_string(), "sp")
        self.assertEqual(Register(63).to_string(), "xzr")
        self.assertEqual(Register(64).to_string(), "wzr")

    def test_str_representation(self):
        """Test string representation of Register"""
        self.assertEqual(str(Register(0)), "x0")
        self.assertEqual(str(Register(31)), "w0")
        self.assertEqual(str(Register(62)), "sp")

    def test_from_string(self):
        """Test creation of Register from string"""
        self.assertEqual(Register.from_string("x0").value, 0)
        self.assertEqual(Register.from_string("w0").value, 31)
        self.assertEqual(Register.from_string("sp").value, 62)
        self.assertEqual(Register.from_string("xzr").value, 63)
        self.assertEqual(Register.from_string("wzr").value, 64)

        # Should be case-insensitive
        self.assertEqual(Register.from_string("X0").value, 0)
        self.assertEqual(Register.from_string("SP").value, 62)

        # Invalid register name
        with self.assertRaises(ValueError):
            Register.from_string("invalid")

    def test_equality(self):
        """Test Register equality comparison"""
        self.assertEqual(Register(0), Register(0))
        self.assertNotEqual(Register(0), Register(1))
        self.assertNotEqual(Register(0), "x0")


class TestAddressingMode(unittest.TestCase):
    def test_initialization(self):
        """Test that AddressingMode initialization works with valid values"""
        mode = AddressingMode(1)  # IMMEDIATE
        self.assertEqual(mode.value, 1)

        mode = AddressingMode(5)  # REGISTER_EXTENDED
        self.assertEqual(mode.value, 5)

    def test_initialization_validation(self):
        """Test that AddressingMode initialization validates the input"""
        # Value must be an integer
        with self.assertRaises(TypeError):
            AddressingMode("IMMEDIATE")

        # Value must be within valid range
        with self.assertRaises(ValueError):
            AddressingMode(0)

        with self.assertRaises(ValueError):
            AddressingMode(6)

    def test_to_string(self):
        """Test conversion of AddressingMode to string"""
        self.assertEqual(AddressingMode(1).to_string(), "IMMEDIATE")
        self.assertEqual(AddressingMode(2).to_string(), "PRE_INDEXED")
        self.assertEqual(AddressingMode(3).to_string(), "POST_INDEXED")
        self.assertEqual(AddressingMode(4).to_string(), "REGISTER_OFFSET")
        self.assertEqual(AddressingMode(5).to_string(), "REGISTER_EXTENDED")

    def test_str_representation(self):
        """Test string representation of AddressingMode"""
        self.assertEqual(str(AddressingMode(1)), "IMMEDIATE")
        self.assertEqual(str(AddressingMode(5)), "REGISTER_EXTENDED")

    def test_constants(self):
        """Test AddressingMode class constants"""
        self.assertEqual(AddressingMode.IMMEDIATE().value, 1)
        self.assertEqual(AddressingMode.PRE_INDEXED().value, 2)
        self.assertEqual(AddressingMode.POST_INDEXED().value, 3)
        self.assertEqual(AddressingMode.REGISTER_OFFSET().value, 4)
        self.assertEqual(AddressingMode.REGISTER_EXTENDED().value, 5)

    def test_equality(self):
        """Test AddressingMode equality comparison"""
        self.assertEqual(AddressingMode(1), AddressingMode(1))
        self.assertNotEqual(AddressingMode(1), AddressingMode(2))
        self.assertNotEqual(AddressingMode(1), "IMMEDIATE")
        self.assertEqual(AddressingMode.IMMEDIATE(), AddressingMode(1))


class TestExtendType(unittest.TestCase):
    def test_initialization(self):
        """Test that ExtendType initialization works with valid values"""
        ext = ExtendType(1)  # UXTB
        self.assertEqual(ext.value, 1)

        ext = ExtendType(8)  # SXTX
        self.assertEqual(ext.value, 8)

    def test_initialization_validation(self):
        """Test that ExtendType initialization validates the input"""
        # Value must be an integer
        with self.assertRaises(TypeError):
            ExtendType("UXTB")

        # Value must be within valid range
        with self.assertRaises(ValueError):
            ExtendType(0)

        with self.assertRaises(ValueError):
            ExtendType(9)

    def test_to_string(self):
        """Test conversion of ExtendType to string"""
        self.assertEqual(ExtendType(1).to_string(), "UXTB")
        self.assertEqual(ExtendType(2).to_string(), "UXTH")
        self.assertEqual(ExtendType(3).to_string(), "UXTW")
        self.assertEqual(ExtendType(4).to_string(), "UXTX")
        self.assertEqual(ExtendType(5).to_string(), "SXTB")
        self.assertEqual(ExtendType(6).to_string(), "SXTH")
        self.assertEqual(ExtendType(7).to_string(), "SXTW")
        self.assertEqual(ExtendType(8).to_string(), "SXTX")

    def test_str_representation(self):
        """Test string representation of ExtendType"""
        self.assertEqual(str(ExtendType(1)), "UXTB")
        self.assertEqual(str(ExtendType(7)), "SXTW")

    def test_from_string(self):
        """Test creation of ExtendType from string"""
        self.assertEqual(ExtendType.from_string("UXTB").value, 1)
        self.assertEqual(ExtendType.from_string("UXTH").value, 2)
        self.assertEqual(ExtendType.from_string("UXTW").value, 3)
        self.assertEqual(ExtendType.from_string("UXTX").value, 4)
        self.assertEqual(ExtendType.from_string("SXTB").value, 5)
        self.assertEqual(ExtendType.from_string("SXTH").value, 6)
        self.assertEqual(ExtendType.from_string("SXTW").value, 7)
        self.assertEqual(ExtendType.from_string("SXTX").value, 8)

        # Should be case-sensitive
        self.assertEqual(ExtendType.from_string("uxtb").value, 1)

        # Invalid extend type name
        with self.assertRaises(ValueError):
            ExtendType.from_string("invalid")

    def test_constants(self):
        """Test ExtendType class constants"""
        self.assertEqual(ExtendType.UXTB().value, 1)
        self.assertEqual(ExtendType.UXTH().value, 2)
        self.assertEqual(ExtendType.UXTW().value, 3)
        self.assertEqual(ExtendType.UXTX().value, 4)
        self.assertEqual(ExtendType.SXTB().value, 5)
        self.assertEqual(ExtendType.SXTH().value, 6)
        self.assertEqual(ExtendType.SXTW().value, 7)
        self.assertEqual(ExtendType.SXTX().value, 8)

    def test_equality(self):
        """Test ExtendType equality comparison"""
        self.assertEqual(ExtendType(1), ExtendType(1))
        self.assertNotEqual(ExtendType(1), ExtendType(2))
        self.assertNotEqual(ExtendType(1), "UXTB")
        self.assertEqual(ExtendType.UXTB(), ExtendType(1))


class TestShiftType(unittest.TestCase):
    def test_initialization(self):
        """Test that ShiftType initialization works with valid values"""
        shift = ShiftType(1)  # LSL
        self.assertEqual(shift.value, 1)

        shift = ShiftType(4)  # ROR
        self.assertEqual(shift.value, 4)

    def test_initialization_validation(self):
        """Test that ShiftType initialization validates the input"""
        # Value must be an integer
        with self.assertRaises(TypeError):
            ShiftType("LSL")

        # Value must be within valid range
        with self.assertRaises(ValueError):
            ShiftType(0)

        with self.assertRaises(ValueError):
            ShiftType(5)

    def test_to_string(self):
        """Test conversion of ShiftType to string"""
        self.assertEqual(ShiftType(1).to_string(), "LSL")
        self.assertEqual(ShiftType(2).to_string(), "LSR")
        self.assertEqual(ShiftType(3).to_string(), "ASR")
        self.assertEqual(ShiftType(4).to_string(), "ROR")

    def test_str_representation(self):
        """Test string representation of ShiftType"""
        self.assertEqual(str(ShiftType(1)), "LSL")
        self.assertEqual(str(ShiftType(3)), "ASR")

    def test_from_string(self):
        """Test creation of ShiftType from string"""
        self.assertEqual(ShiftType.from_string("LSL").value, 1)
        self.assertEqual(ShiftType.from_string("LSR").value, 2)
        self.assertEqual(ShiftType.from_string("ASR").value, 3)
        self.assertEqual(ShiftType.from_string("ROR").value, 4)

        # Should be case-insensitive
        self.assertEqual(ShiftType.from_string("lsl").value, 1)

        # Invalid shift type name
        with self.assertRaises(ValueError):
            ShiftType.from_string("invalid")

    def test_constants(self):
        """Test ShiftType class constants"""
        self.assertEqual(ShiftType.LSL().value, 1)
        self.assertEqual(ShiftType.LSR().value, 2)
        self.assertEqual(ShiftType.ASR().value, 3)
        self.assertEqual(ShiftType.ROR().value, 4)

    def test_equality(self):
        """Test ShiftType equality comparison"""
        self.assertEqual(ShiftType(1), ShiftType(1))
        self.assertNotEqual(ShiftType(1), ShiftType(2))
        self.assertNotEqual(ShiftType(1), "LSL")
        self.assertEqual(ShiftType.LSL(), ShiftType(1))


class TestCondition(unittest.TestCase):
    def test_initialization(self):
        """Test that Condition initialization works with valid values"""
        cond = Condition(1)  # EQ
        self.assertEqual(cond.value, 1)

        cond = Condition(18)  # NV
        self.assertEqual(cond.value, 18)

    def test_initialization_validation(self):
        """Test that Condition initialization validates the input"""
        # Value must be an integer
        with self.assertRaises(TypeError):
            Condition("EQ")

        # Value must be within valid range
        with self.assertRaises(ValueError):
            Condition(0)

        with self.assertRaises(ValueError):
            Condition(19)

    def test_to_string(self):
        """Test conversion of Condition to string"""
        self.assertEqual(Condition(1).to_string(), "EQ")
        self.assertEqual(Condition(2).to_string(), "NE")
        self.assertEqual(Condition(13).to_string(), "GE")
        self.assertEqual(Condition(17).to_string(), "AL")
        self.assertEqual(Condition(18).to_string(), "NV")

    def test_str_representation(self):
        """Test string representation of Condition"""
        self.assertEqual(str(Condition(1)), "EQ")
        self.assertEqual(str(Condition(17)), "AL")

    def test_from_string(self):
        """Test creation of Condition from string"""
        self.assertEqual(Condition.from_string("EQ").value, 1)
        self.assertEqual(Condition.from_string("NE").value, 2)
        self.assertEqual(Condition.from_string("CS").value, 3)
        self.assertEqual(Condition.from_string("HS").value, 4)
        self.assertEqual(Condition.from_string("AL").value, 17)
        self.assertEqual(Condition.from_string("NV").value, 18)

        # Should be case-insensitive
        self.assertEqual(Condition.from_string("eq").value, 1)

        # Invalid condition name
        with self.assertRaises(ValueError):
            Condition.from_string("invalid")

    def test_equality(self):
        """Test Condition equality comparison"""
        self.assertEqual(Condition(1), Condition(1))
        self.assertNotEqual(Condition(1), Condition(2))
        self.assertNotEqual(Condition(1), "EQ")


class TestInstructionType(unittest.TestCase):
    def test_initialization(self):
        """Test that InstructionType initialization works with valid values"""
        instr_type = InstructionType(1)  # add (register)
        self.assertEqual(instr_type.value, 1)

        instr_type = InstructionType(47)  # mvn
        self.assertEqual(instr_type.value, 47)

    def test_initialization_validation(self):
        """Test that InstructionType initialization validates the input"""
        # Value must be an integer
        with self.assertRaises(TypeError):
            InstructionType("add")

        # Value must be within valid range
        with self.assertRaises(ValueError):
            InstructionType(0)

        with self.assertRaises(ValueError):
            InstructionType(49)  # Updated to 49 since we now support 48 (nop)

    def test_to_string(self):
        """Test conversion of InstructionType to string"""
        self.assertEqual(InstructionType(1).to_string(), "add")  # add (register)
        self.assertEqual(InstructionType(12).to_string(), "add")  # add (immediate)
        self.assertEqual(InstructionType(20).to_string(), "ldr")
        self.assertEqual(InstructionType(35).to_string(), "ret")
        self.assertEqual(InstructionType(46).to_string(), "mov")

    def test_str_representation(self):
        """Test string representation of InstructionType"""
        self.assertEqual(str(InstructionType(1)), "add")
        self.assertEqual(str(InstructionType(35)), "ret")

    def test_from_string(self):
        """Test creation of InstructionType from string"""
        # Test basic instructions
        self.assertEqual(InstructionType.from_string("ret").value, 35)
        self.assertEqual(InstructionType.from_string("mov").value, 46)
        
        # Test ambiguous instructions with has_immediate parameter
        self.assertEqual(InstructionType.from_string("add", has_immediate=False).value, 1)
        self.assertEqual(InstructionType.from_string("add", has_immediate=True).value, 12)
        
        self.assertEqual(InstructionType.from_string("sub", has_immediate=False).value, 2)
        self.assertEqual(InstructionType.from_string("sub", has_immediate=True).value, 13)
        
        # Test conditional branch
        self.assertEqual(InstructionType.from_string("b.eq").value, 40)
        self.assertEqual(InstructionType.from_string("b").value, 31)

        # Should be case-insensitive
        self.assertEqual(InstructionType.from_string("ADD", has_immediate=False).value, 1)

        # Invalid instruction name
        with self.assertRaises(ValueError):
            InstructionType.from_string("invalid")

    def test_equality(self):
        """Test InstructionType equality comparison"""
        self.assertEqual(InstructionType(1), InstructionType(1))
        self.assertNotEqual(InstructionType(1), InstructionType(2))
        self.assertNotEqual(InstructionType(1), "add")


class TestParamType(unittest.TestCase):
    def test_initialization(self):
        """Test that ParamType initialization works with valid values"""
        param_type = ParamType(0)  # NONE
        self.assertEqual(param_type.value, 0)

        param_type = ParamType(8)  # SHIFT_TYPE_OR_EXTEND_TYPE
        self.assertEqual(param_type.value, 8)

    def test_initialization_validation(self):
        """Test that ParamType initialization validates the input"""
        # Value must be an integer
        with self.assertRaises(TypeError):
            ParamType("REGISTER")

        # Value must be within valid range
        with self.assertRaises(ValueError):
            ParamType(-1)

        with self.assertRaises(ValueError):
            ParamType(9)

    def test_to_string(self):
        """Test conversion of ParamType to string"""
        self.assertEqual(ParamType(0).to_string(), "NONE")
        self.assertEqual(ParamType(1).to_string(), "REGISTER")
        self.assertEqual(ParamType(2).to_string(), "IMMEDIATE")
        self.assertEqual(ParamType(8).to_string(), "SHIFT_TYPE_OR_EXTEND_TYPE")

    def test_str_representation(self):
        """Test string representation of ParamType"""
        self.assertEqual(str(ParamType(0)), "NONE")
        self.assertEqual(str(ParamType(2)), "IMMEDIATE")

    def test_constants(self):
        """Test ParamType class constants"""
        self.assertEqual(ParamType.NONE().value, 0)
        self.assertEqual(ParamType.REGISTER().value, 1)
        self.assertEqual(ParamType.IMMEDIATE().value, 2)
        self.assertEqual(ParamType.MEMORY().value, 3)
        self.assertEqual(ParamType.LABEL().value, 4)
        self.assertEqual(ParamType.CONDITION().value, 5)
        self.assertEqual(ParamType.SHIFT().value, 6)
        self.assertEqual(ParamType.EXTEND().value, 7)
        self.assertEqual(ParamType.SHIFT_TYPE().value, 8)
        self.assertEqual(ParamType.EXTEND_TYPE().value, 8)

    def test_equality(self):
        """Test ParamType equality comparison"""
        self.assertEqual(ParamType(1), ParamType(1))
        self.assertNotEqual(ParamType(1), ParamType(2))
        self.assertNotEqual(ParamType(1), "REGISTER")
        self.assertEqual(ParamType.REGISTER(), ParamType(1))


class TestInstruction(unittest.TestCase):
    def test_initialization_with_instr_type(self):
        """Test Instruction initialization with InstructionType"""
        instr_type = InstructionType(1)  # add (register)
        instruction = Instruction(instr_type)
        self.assertEqual(instruction.instr_type, instr_type)
        self.assertEqual(len(instruction.operands), 0)
        self.assertIsNone(instruction.comment)

    def test_initialization_with_string(self):
        """Test Instruction initialization with string"""
        # Simple instruction
        instruction = Instruction("ret")
        self.assertEqual(instruction.instr_type.value, 35)  # ret

        # Instruction with immediate operand
        instruction = Instruction("add", [ImmediateOperand(42)])
        self.assertEqual(instruction.instr_type.value, 12)  # add (immediate)
        self.assertEqual(len(instruction.operands), 1)

        # Instruction with comment
        instruction = Instruction("mov", comment="Move register")
        self.assertEqual(instruction.instr_type.value, 46)  # mov
        self.assertEqual(instruction.comment, "Move register")

        # Unknown instruction
        with self.assertRaises(ValueError):
            Instruction("invalid")

    def test_str_representation(self):
        """Test string representation of Instruction"""
        # Simple instruction
        instruction = Instruction("ret")
        self.assertEqual(str(instruction), "ret")

        # Instruction with register operand
        instruction = Instruction("mov", [RegisterOperand(Register(0))])
        self.assertEqual(str(instruction), "mov x0")

        # Instruction with multiple operands
        instruction = Instruction("add", [
            RegisterOperand(Register(0)),
            RegisterOperand(Register(1)),
            ImmediateOperand(42)
        ])
        self.assertEqual(str(instruction), "add x0, x1, #42")

        # Instruction with comment
        instruction = Instruction("nop", comment="No operation")
        self.assertEqual(str(instruction), "nop // No operation")

        # Conditional branch instruction
        instruction = Instruction("b", [
            ConditionOperand(Condition(1)),  # EQ
            LabelOperand("loop")
        ])
        self.assertEqual(str(instruction), "b.eq loop")


class TestOperands(unittest.TestCase):
    def test_immediate_operand(self):
        """Test ImmediateOperand"""
        operand = ImmediateOperand(42)
        self.assertEqual(operand.value, 42)
        self.assertEqual(str(operand), "#42")

    def test_register_operand(self):
        """Test RegisterOperand"""
        register = Register(0)  # x0
        operand = RegisterOperand(register)
        self.assertEqual(operand.register, register)
        self.assertEqual(str(operand), "x0")

    def test_shifted_register_operand(self):
        """Test ShiftedRegisterOperand"""
        register = Register(0)  # x0
        shift_type = ShiftType(1)  # LSL
        
        # Without shift
        operand = ShiftedRegisterOperand(register)
        self.assertEqual(operand.register, register)
        self.assertIsNone(operand.shift_type)
        self.assertEqual(operand.shift_amount, 0)
        self.assertEqual(str(operand), "x0")
        
        # With shift
        operand = ShiftedRegisterOperand(register, shift_type, 2)
        self.assertEqual(operand.register, register)
        self.assertEqual(operand.shift_type, shift_type)
        self.assertEqual(operand.shift_amount, 2)
        self.assertEqual(str(operand), "x0, LSL #2")

    def test_extended_register_operand(self):
        """Test ExtendedRegisterOperand"""
        register = Register(0)  # x0
        extend_type = ExtendType(7)  # SXTW
        
        # Without shift amount
        operand = ExtendedRegisterOperand(register, extend_type)
        self.assertEqual(operand.register, register)
        self.assertEqual(operand.extend_type, extend_type)
        self.assertEqual(operand.shift_amount, 0)
        self.assertEqual(str(operand), "x0, SXTW")
        
        # With shift amount
        operand = ExtendedRegisterOperand(register, extend_type, 2)
        self.assertEqual(operand.register, register)
        self.assertEqual(operand.extend_type, extend_type)
        self.assertEqual(operand.shift_amount, 2)
        self.assertEqual(str(operand), "x0, SXTW #2")

    def test_memory_operand(self):
        """Test MemoryOperand"""
        base_register = Register(0)  # x0
        offset_register = Register(1)  # x1
        extend_type = ExtendType(7)  # SXTW
        
        # Immediate addressing mode
        operand = MemoryOperand(base_register, AddressingMode.IMMEDIATE())
        self.assertEqual(operand.base_register, base_register)
        self.assertEqual(operand.mode.value, 1)
        self.assertEqual(operand.offset, 0)
        self.assertEqual(str(operand), "[x0]")
        
        # Immediate addressing mode with offset
        operand = MemoryOperand(base_register, AddressingMode.IMMEDIATE(), 16)
        self.assertEqual(str(operand), "[x0, #16]")
        
        # Pre-indexed addressing mode
        operand = MemoryOperand(base_register, AddressingMode.PRE_INDEXED(), 16)
        self.assertEqual(str(operand), "[x0, #16]!")
        
        # Post-indexed addressing mode
        operand = MemoryOperand(base_register, AddressingMode.POST_INDEXED(), 16)
        self.assertEqual(str(operand), "[x0], #16")
        
        # Register offset addressing mode
        operand = MemoryOperand(base_register, AddressingMode.REGISTER_OFFSET(), offset_register)
        self.assertEqual(str(operand), "[x0, x1]")
        
        # Register extended addressing mode
        operand = MemoryOperand(
            base_register, AddressingMode.REGISTER_EXTENDED(),
            offset_register, extend_type
        )
        self.assertEqual(str(operand), "[x0, x1, SXTW]")
        
        # Register extended addressing mode with shift
        operand = MemoryOperand(
            base_register, AddressingMode.REGISTER_EXTENDED(),
            offset_register, extend_type, 2
        )
        self.assertEqual(str(operand), "[x0, x1, SXTW #2]")

    def test_label_operand(self):
        """Test LabelOperand"""
        operand = LabelOperand("loop")
        self.assertEqual(operand.name, "loop")
        self.assertEqual(str(operand), "loop")

    def test_condition_operand(self):
        """Test ConditionOperand"""
        condition = Condition(1)  # EQ
        operand = ConditionOperand(condition)
        self.assertEqual(operand.condition, condition)
        self.assertEqual(str(operand), "EQ")


class TestLabel(unittest.TestCase):
    def test_initialization(self):
        """Test Label initialization"""
        label = Label("loop")
        self.assertEqual(label.name, "loop")

    def test_str_representation(self):
        """Test string representation of Label"""
        label = Label("loop")
        self.assertEqual(str(label), "loop:")

        label = Label(".L1")
        self.assertEqual(str(label), ".L1:")


class TestDirective(unittest.TestCase):
    def test_initialization(self):
        """Test Directive initialization"""
        directive = Directive("text")
        self.assertEqual(directive.name, "text")
        self.assertEqual(directive.args, [])

        directive = Directive("global", ["main"])
        self.assertEqual(directive.name, "global")
        self.assertEqual(directive.args, ["main"])

    def test_str_representation(self):
        """Test string representation of Directive"""
        directive = Directive("text")
        self.assertEqual(str(directive), ".text")

        directive = Directive("global", ["main"])
        self.assertEqual(str(directive), ".global main")

        directive = Directive("align", ["4", "2"])
        self.assertEqual(str(directive), ".align 4, 2")


class TestAssemblyProgram(unittest.TestCase):
    def test_initialization(self):
        """Test AssemblyProgram initialization"""
        program = AssemblyProgram()
        self.assertEqual(program.name, "unnamed")
        self.assertEqual(program.elements, [])
        self.assertEqual(program.labels, {})

        program = AssemblyProgram("test_program")
        self.assertEqual(program.name, "test_program")

    def test_add_element(self):
        """Test adding elements to AssemblyProgram"""
        program = AssemblyProgram("test_program")
        
        # Add a directive
        directive = Directive("text")
        program.add_element(directive)
        self.assertEqual(len(program.elements), 1)
        self.assertEqual(program.elements[0], directive)
        
        # Add a label
        label = Label("main")
        program.add_element(label)
        self.assertEqual(len(program.elements), 2)
        self.assertEqual(program.elements[1], label)
        self.assertEqual(program.labels, {"main": 1})
        
        # Add an instruction
        instruction = Instruction("mov", [RegisterOperand(Register(0)), RegisterOperand(Register(1))])
        program.add_element(instruction)
        self.assertEqual(len(program.elements), 3)
        self.assertEqual(program.elements[2], instruction)

    def test_str_representation(self):
        """Test string representation of AssemblyProgram"""
        program = AssemblyProgram("test_program")
        
        # Add elements
        program.add_element(Directive("text"))
        program.add_element(Label("main"))
        program.add_element(Instruction("mov", [RegisterOperand(Register(0)), RegisterOperand(Register(1))]))
        program.add_element(Instruction("ret"))
        
        # Check string representation
        expected_str = "\n".join([
            "// Assembly program: test_program",
            "",
            ".text",
            "main:",
            "    mov x0, x1",
            "    ret"
        ])
        self.assertEqual(str(program), expected_str)


class TestIntegration(unittest.TestCase):
    def test_create_simple_program(self):
        """Test creating a simple assembly program"""
        program = AssemblyProgram("simple_program")
        
        # Add directives
        program.add_element(Directive("text"))
        program.add_element(Directive("global", ["main"]))
        
        # Add main function
        program.add_element(Label("main"))
        
        # Function body
        program.add_element(Instruction("mov", [
            RegisterOperand(Register(0)),
            ImmediateOperand(42)
        ]))
        
        program.add_element(Instruction("ret"))
        
        # Check string representation
        expected_str = "\n".join([
            "// Assembly program: simple_program",
            "",
            ".text",
            ".global main",
            "main:",
            "    mov x0, #42",
            "    ret"
        ])
        self.assertEqual(str(program), expected_str)

    def test_complex_instructions(self):
        """Test creating complex instructions"""
        # LDR with register extended addressing mode
        ldr_instruction = Instruction("ldr", [
            RegisterOperand(Register(0)),  # x0
            MemoryOperand(
                Register(1),               # x1 (base)
                AddressingMode.REGISTER_EXTENDED(),
                Register(2),               # x2 (offset)
                ExtendType(7),             # SXTW
                3                          # shift amount
            )
        ])
        self.assertEqual(str(ldr_instruction), "ldr x0, [x1, x2, SXTW #3]")
        
        # ADD with shifted register
        add_instruction = Instruction("add", [
            RegisterOperand(Register(0)),  # x0
            RegisterOperand(Register(1)),  # x1
            ShiftedRegisterOperand(
                Register(2),               # x2
                ShiftType(1),              # LSL
                2                          # shift amount
            )
        ])
        self.assertEqual(str(add_instruction), "add x0, x1, x2, LSL #2")
        
        # Conditional branch
        b_instruction = Instruction("b", [
            ConditionOperand(Condition(1)),  # EQ
            LabelOperand(".L1")
        ])
        self.assertEqual(str(b_instruction), "b.eq .L1")


if __name__ == "__main__":
    unittest.main() 