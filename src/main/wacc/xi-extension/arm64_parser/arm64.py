#!/usr/bin/env python3

from typing import List, Optional, Union, Dict, Callable, ClassVar, TypeVar, Type


class Register:
    """Represents ARM64 registers, stored as an integer value with validation"""
    
    # Map of integers to string representations (for ToString)
    _INT_TO_STR: ClassVar[Dict[int, str]] = {
        0: "x0", 1: "x1", 2: "x2", 3: "x3", 4: "x4", 5: "x5", 6: "x6", 7: "x7",
        8: "x8", 9: "x9", 10: "x10", 11: "x11", 12: "x12", 13: "x13", 14: "x14", 15: "x15",
        16: "x16", 17: "x17", 18: "x18", 19: "x19", 20: "x20", 21: "x21", 22: "x22", 23: "x23",
        24: "x24", 25: "x25", 26: "x26", 27: "x27", 28: "x28", 29: "x29", 30: "x30",
        
        31: "w0", 32: "w1", 33: "w2", 34: "w3", 35: "w4", 36: "w5", 37: "w6", 38: "w7",
        39: "w8", 40: "w9", 41: "w10", 42: "w11", 43: "w12", 44: "w13", 45: "w14", 46: "w15",
        47: "w16", 48: "w17", 49: "w18", 50: "w19", 51: "w20", 52: "w21", 53: "w22", 54: "w23",
        55: "w24", 56: "w25", 57: "w26", 58: "w27", 59: "w28", 60: "w29", 61: "w30",
        
        62: "sp", 63: "xzr", 64: "wzr", 65: "nzcv"
    }
    
    # Map of string representations to integers (for from_string)
    _STR_TO_INT: ClassVar[Dict[str, int]] = {s: i for i, s in _INT_TO_STR.items()}
    
    # Valid range for register values
    _MIN_VALUE = 0
    _MAX_VALUE = 65
    
    def __init__(self, value: int):
        """Initialize with integer value, validating it's in the proper range"""
        if not isinstance(value, int):
            raise TypeError("Register value must be an integer")
        
        if value < self._MIN_VALUE or value > self._MAX_VALUE:
            raise ValueError(f"Register value must be between {self._MIN_VALUE} and {self._MAX_VALUE}")
        
        self._value = value
    
    @property
    def value(self) -> int:
        """Get the integer value of the register"""
        return self._value
    
    @classmethod
    def from_string(cls, reg_str: str) -> 'Register':
        """Convert a string to a Register object"""
        reg_str = reg_str.lower()
        if reg_str in cls._STR_TO_INT:
            return cls(cls._STR_TO_INT[reg_str])
        raise ValueError(f"Unknown register: {reg_str}")
    
    def to_string(self) -> str:
        """Convert register to its string representation"""
        return self._INT_TO_STR[self._value]
    
    def __str__(self) -> str:
        """String representation using the mapping"""
        return self.to_string()
    
    def __eq__(self, other) -> bool:
        """Compare registers by their integer value"""
        if isinstance(other, Register):
            return self._value == other._value
        return False


class AddressingMode:
    """Represents ARM64 addressing modes, stored as an integer value with validation"""
    
    # Map of integers to string representations
    _INT_TO_STR: ClassVar[Dict[int, str]] = {
        1: "IMMEDIATE",        # [X0, #16]
        2: "PRE_INDEXED",      # [X0, #16]!
        3: "POST_INDEXED",     # [X0], #16
        4: "REGISTER_OFFSET",  # [X0, X1]
        5: "REGISTER_EXTENDED"  # [X0, W1, SXTW]
    }
    
    # Valid range for addressing mode values
    _MIN_VALUE = 1
    _MAX_VALUE = 5
    
    def __init__(self, value: int):
        """Initialize with integer value, validating it's in the proper range"""
        if not isinstance(value, int):
            raise TypeError("AddressingMode value must be an integer")
        
        if value < self._MIN_VALUE or value > self._MAX_VALUE:
            raise ValueError(f"AddressingMode value must be between {self._MIN_VALUE} and {self._MAX_VALUE}")
        
        self._value = value
    
    @property
    def value(self) -> int:
        """Get the integer value of the addressing mode"""
        return self._value
    
    def to_string(self) -> str:
        """Convert addressing mode to its string representation"""
        return self._INT_TO_STR[self._value]
    
    def __str__(self) -> str:
        """String representation using the mapping"""
        return self.to_string()
    
    def __eq__(self, other) -> bool:
        """Compare addressing modes by their integer value"""
        if isinstance(other, AddressingMode):
            return self._value == other._value
        return False
    
    # Constants for common addressing modes
    @classmethod
    def IMMEDIATE(cls) -> 'AddressingMode':
        return cls(1)
    
    @classmethod
    def PRE_INDEXED(cls) -> 'AddressingMode':
        return cls(2)
    
    @classmethod
    def POST_INDEXED(cls) -> 'AddressingMode':
        return cls(3)
    
    @classmethod
    def REGISTER_OFFSET(cls) -> 'AddressingMode':
        return cls(4)
    
    @classmethod
    def REGISTER_EXTENDED(cls) -> 'AddressingMode':
        return cls(5)


class ExtendType:
    """Represents ARM64 register extension types, stored as an integer value with validation"""
    
    # Map of integers to string representations
    _INT_TO_STR: ClassVar[Dict[int, str]] = {
        1: "UXTB",  # Unsigned extend byte
        2: "UXTH",  # Unsigned extend halfword
        3: "UXTW",  # Unsigned extend word
        4: "UXTX",  # Unsigned extend doubleword
        5: "SXTB",  # Signed extend byte
        6: "SXTH",  # Signed extend halfword
        7: "SXTW",  # Signed extend word
        8: "SXTX",  # Signed extend doubleword
    }
    
    # Map of string representations to integers
    _STR_TO_INT: ClassVar[Dict[str, int]] = {s: i for i, s in _INT_TO_STR.items()}
    
    # Valid range for extend type values
    _MIN_VALUE = 1
    _MAX_VALUE = 8
    
    def __init__(self, value: int):
        """Initialize with integer value, validating it's in the proper range"""
        if not isinstance(value, int):
            raise TypeError("ExtendType value must be an integer")
        
        if value < self._MIN_VALUE or value > self._MAX_VALUE:
            raise ValueError(f"ExtendType value must be between {self._MIN_VALUE} and {self._MAX_VALUE}")
        
        self._value = value
    
    @property
    def value(self) -> int:
        """Get the integer value of the extend type"""
        return self._value
    
    @classmethod
    def from_string(cls, ext_str: str) -> 'ExtendType':
        """Convert a string to an ExtendType object"""
        ext_str = ext_str.upper()
        if ext_str in cls._STR_TO_INT:
            return cls(cls._STR_TO_INT[ext_str])
        raise ValueError(f"Unknown extend type: {ext_str}")
    
    def to_string(self) -> str:
        """Convert extend type to its string representation"""
        return self._INT_TO_STR[self._value]
    
    def __str__(self) -> str:
        """String representation using the mapping"""
        return self.to_string()
    
    def __eq__(self, other) -> bool:
        """Compare extend types by their integer value"""
        if isinstance(other, ExtendType):
            return self._value == other._value
        return False
    
    # Constants for common extend types
    @classmethod
    def UXTB(cls) -> 'ExtendType':
        return cls(1)
    
    @classmethod
    def UXTH(cls) -> 'ExtendType':
        return cls(2)
    
    @classmethod
    def UXTW(cls) -> 'ExtendType':
        return cls(3)
    
    @classmethod
    def UXTX(cls) -> 'ExtendType':
        return cls(4)
    
    @classmethod
    def SXTB(cls) -> 'ExtendType':
        return cls(5)
    
    @classmethod
    def SXTH(cls) -> 'ExtendType':
        return cls(6)
    
    @classmethod
    def SXTW(cls) -> 'ExtendType':
        return cls(7)
    
    @classmethod
    def SXTX(cls) -> 'ExtendType':
        return cls(8)


class ShiftType:
    """Represents ARM64 shift types, stored as an integer value with validation"""
    
    # Map of integers to string representations
    _INT_TO_STR: ClassVar[Dict[int, str]] = {
        1: "LSL",  # Logical shift left
        2: "LSR",  # Logical shift right
        3: "ASR",  # Arithmetic shift right
        4: "ROR",  # Rotate right
    }
    
    # Map of string representations to integers
    _STR_TO_INT: ClassVar[Dict[str, int]] = {s: i for i, s in _INT_TO_STR.items()}
    
    # Valid range for shift type values
    _MIN_VALUE = 1
    _MAX_VALUE = 4
    
    def __init__(self, value: int):
        """Initialize with integer value, validating it's in the proper range"""
        if not isinstance(value, int):
            raise TypeError("ShiftType value must be an integer")
        
        if value < self._MIN_VALUE or value > self._MAX_VALUE:
            raise ValueError(f"ShiftType value must be between {self._MIN_VALUE} and {self._MAX_VALUE}")
        
        self._value = value
    
    @property
    def value(self) -> int:
        """Get the integer value of the shift type"""
        return self._value
    
    @classmethod
    def from_string(cls, shift_str: str) -> 'ShiftType':
        """Convert a string to a ShiftType object"""
        shift_str = shift_str.upper()
        if shift_str in cls._STR_TO_INT:
            return cls(cls._STR_TO_INT[shift_str])
        raise ValueError(f"Unknown shift type: {shift_str}")
    
    def to_string(self) -> str:
        """Convert shift type to its string representation"""
        return self._INT_TO_STR[self._value]
    
    def __str__(self) -> str:
        """String representation using the mapping"""
        return self.to_string()
    
    def __eq__(self, other) -> bool:
        """Compare shift types by their integer value"""
        if isinstance(other, ShiftType):
            return self._value == other._value
        return False
    
    # Constants for common shift types
    @classmethod
    def LSL(cls) -> 'ShiftType':
        return cls(1)
    
    @classmethod
    def LSR(cls) -> 'ShiftType':
        return cls(2)
    
    @classmethod
    def ASR(cls) -> 'ShiftType':
        return cls(3)
    
    @classmethod
    def ROR(cls) -> 'ShiftType':
        return cls(4)


class Condition:
    """Represents ARM64 condition codes, stored as an integer value with validation"""
    
    # Map of integers to string representations
    _INT_TO_STR: ClassVar[Dict[int, str]] = {
        1: "EQ",  # Equal
        2: "NE",  # Not equal
        3: "CS",  # Carry set (or HS: unsigned higher or same)
        4: "HS",  # Unsigned higher or same (alias of CS)
        5: "CC",  # Carry clear (or LO: unsigned lower)
        6: "LO",  # Unsigned lower (alias of CC)
        7: "MI",  # Minus/negative
        8: "PL",  # Plus/positive or zero
        9: "VS",  # Overflow
        10: "VC",  # No overflow
        11: "HI",  # Unsigned higher
        12: "LS",  # Unsigned lower or same
        13: "GE",  # Signed greater than or equal
        14: "LT",  # Signed less than
        15: "GT",  # Signed greater than
        16: "LE",  # Signed less than or equal
        17: "AL",  # Always (default)
        18: "NV",  # Never
    }
    
    # Map of string representations to integers
    _STR_TO_INT: ClassVar[Dict[str, int]] = {s: i for i, s in _INT_TO_STR.items()}
    
    # Valid range for condition values
    _MIN_VALUE = 1
    _MAX_VALUE = 18
    
    def __init__(self, value: int):
        """Initialize with integer value, validating it's in the proper range"""
        if not isinstance(value, int):
            raise TypeError("Condition value must be an integer")
        
        if value < self._MIN_VALUE or value > self._MAX_VALUE:
            raise ValueError(f"Condition value must be between {self._MIN_VALUE} and {self._MAX_VALUE}")
        
        self._value = value
    
    @property
    def value(self) -> int:
        """Get the integer value of the condition"""
        return self._value
    
    @classmethod
    def from_string(cls, cond_str: str) -> 'Condition':
        """Convert a string to a Condition object"""
        cond_str = cond_str.upper()
        if cond_str in cls._STR_TO_INT:
            return cls(cls._STR_TO_INT[cond_str])
        raise ValueError(f"Unknown condition: {cond_str}")
    
    def to_string(self) -> str:
        """Convert condition to its string representation"""
        return self._INT_TO_STR[self._value]
    
    def __str__(self) -> str:
        """String representation using the mapping"""
        return self.to_string()
    
    def __eq__(self, other) -> bool:
        """Compare conditions by their integer value"""
        if isinstance(other, Condition):
            return self._value == other._value
        return False


class InstructionType:
    """Represents ARM64 instruction types, stored as an integer value with validation"""
    
    # Map of integers to string representations
    _INT_TO_STR: ClassVar[Dict[int, str]] = {
        # Data processing (registers)
        1: "add",      # Add
        2: "sub",      # Subtract
        3: "mul",      # Multiply
        4: "sdiv",     # Signed Divide
        5: "udiv",     # Unsigned Divide
        6: "and",      # Bitwise AND
        7: "orr",      # Bitwise OR
        8: "eor",      # Bitwise XOR
        9: "lsl",      # Logical Shift Left
        10: "lsr",     # Logical Shift Right
        11: "asr",     # Arithmetic Shift Right
        
        # Data processing (immediate)
        12: "add",     # Add Immediate
        13: "sub",     # Subtract Immediate
        14: "and",     # AND Immediate
        15: "orr",     # OR Immediate
        16: "eor",     # XOR Immediate
        17: "movz",    # Move Wide with Zero
        18: "movn",    # Move Wide with NOT
        19: "movk",    # Move Wide with Keep
        
        # Memory operations
        20: "ldr",     # Load Register
        21: "str",     # Store Register
        22: "ldrb",    # Load Byte
        23: "strb",    # Store Byte
        24: "ldrh",    # Load Halfword
        25: "strh",    # Store Halfword
        26: "ldrsb",   # Load Signed Byte
        27: "ldrsh",   # Load Signed Halfword
        28: "ldrsw",   # Load Signed Word
        29: "ldp",     # Load Pair
        30: "stp",     # Store Pair
        
        # Control flow
        31: "b",       # Branch
        32: "bl",      # Branch with Link
        33: "br",      # Branch to Register
        34: "blr",     # Branch with Link to Register
        35: "ret",     # Return
        36: "cbz",     # Compare and Branch if Zero
        37: "cbnz",    # Compare and Branch if Not Zero
        38: "tbz",     # Test bit and Branch if Zero
        39: "tbnz",    # Test bit and Branch if Not Zero
        40: "b",       # Conditional Branch (requires condition suffix)
        
        # Comparison
        41: "cmp",     # Compare
        42: "cmp",     # Compare Immediate
        43: "cmn",     # Compare Negative
        44: "cmn",     # Compare Negative Immediate
        45: "tst",     # Test bits
        
        # Miscellaneous
        46: "mov",     # Move register
        47: "mvn",     # Move and NOT
        48: "nop",     # No operation
    }
    
    # Map to help distinguish between similar string representations
    _INSTRUCTION_TYPES: ClassVar[Dict[str, Dict[str, int]]] = {
        "add": {"reg": 1, "imm": 12},
        "sub": {"reg": 2, "imm": 13},
        "and": {"reg": 6, "imm": 14},
        "orr": {"reg": 7, "imm": 15},
        "eor": {"reg": 8, "imm": 16},
        "cmp": {"reg": 41, "imm": 42},
        "cmn": {"reg": 43, "imm": 44},
        "b": {"normal": 31, "cond": 40, "reg": 31}
    }
    
    # Valid range for instruction type values
    _MIN_VALUE = 1
    _MAX_VALUE = 48
    
    def __init__(self, value: int):
        """Initialize with integer value, validating it's in the proper range"""
        if not isinstance(value, int):
            raise TypeError("InstructionType value must be an integer")
        
        if value < self._MIN_VALUE or value > self._MAX_VALUE:
            raise ValueError(f"InstructionType value must be between {self._MIN_VALUE} and {self._MAX_VALUE}")
        
        self._value = value
    
    @property
    def value(self) -> int:
        """Get the integer value of the instruction type"""
        return self._value
    
    @classmethod
    def from_string(cls, instr_str: str, has_immediate: bool = False) -> 'InstructionType':
        """Create an InstructionType from a string representation.
        
        Args:
            instr_str: The instruction name string (e.g., "add", "mov")
            has_immediate: Whether the instruction uses an immediate operand
            
        Returns:
            An InstructionType instance
            
        Raises:
            ValueError: If the instruction name is invalid
        """
        instr_str = instr_str.lower()
        
        # Handle special case for conditional branches (b.eq, b.ne, etc.)
        if instr_str.startswith("b."):
            return cls(40)  # Conditional branch
        
        # Handle special case for nop
        if instr_str == "nop":
            return cls(48)  # NOP
            
        # Check if this is an instruction that has different types for reg/imm variants
        if instr_str in cls._INSTRUCTION_TYPES:
            if has_immediate and "imm" in cls._INSTRUCTION_TYPES[instr_str]:
                return cls(cls._INSTRUCTION_TYPES[instr_str]["imm"])
            else:
                # Default to register variant or normal for branch
                key = "reg" if "reg" in cls._INSTRUCTION_TYPES[instr_str] else "normal"
                return cls(cls._INSTRUCTION_TYPES[instr_str][key])
        
        # Standard lookup in reverse mapping
        for value, name in cls._INT_TO_STR.items():
            if name == instr_str:
                return cls(value)
        
        # If we get here, the instruction is not recognized
        raise ValueError(f"Unknown instruction type: {instr_str}")
    
    def to_string(self) -> str:
        """Convert instruction type to its string representation"""
        return self._INT_TO_STR[self._value]
    
    def __str__(self) -> str:
        """String representation using the mapping"""
        return self.to_string()
    
    def __eq__(self, other) -> bool:
        """Compare instruction types by their integer value"""
        if isinstance(other, InstructionType):
            return self._value == other._value
        return False


# Base classes for operands
class Operand:
    """Base class for all operands"""
    pass


class ImmediateOperand(Operand):
    """Represents an immediate value (constant)"""
    def __init__(self, value: int):
        self.value = value
    
    def __str__(self):
        """Return formatted immediate, e.g. '#42'"""
        return f"#{self.value}"


class RegisterOperand(Operand):
    """Represents a register operand"""
    def __init__(self, register: Register):
        self.register = register
    
    def __str__(self):
        """Return register name, e.g. 'x0', 'sp'"""
        return str(self.register)


class ShiftedRegisterOperand(Operand):
    """Represents a register with an optional shift"""
    def __init__(self, register: Register, shift_type: ShiftType = None, shift_amount: int = 0):
        self.register = register
        self.shift_type = shift_type
        self.shift_amount = shift_amount
    
    def __str__(self):
        """Return register with shift if any, e.g. 'x0, LSL #2'"""
        if self.shift_type:
            return f"{self.register}, {self.shift_type} #{self.shift_amount}"
        return str(self.register)


class ExtendedRegisterOperand(Operand):
    """Represents a register with an extension"""
    def __init__(self, register: Register, extend_type: ExtendType, shift_amount: int = 0):
        self.register = register
        self.extend_type = extend_type
        self.shift_amount = shift_amount
    
    def __str__(self):
        """Return register with extension, e.g. 'x0, SXTW #2'"""
        if self.shift_amount:
            return f"{self.register}, {self.extend_type} #{self.shift_amount}"
        return f"{self.register}, {self.extend_type}"


class MemoryOperand(Operand):
    """Represents a memory operand"""
    def __init__(
        self, 
        base_register: Register, 
        mode: AddressingMode, 
        offset: Union[int, Register] = 0,
        extend_type: ExtendType = None,
        shift_amount: int = 0
    ):
        self.base_register = base_register
        self.mode = mode
        self.offset = offset
        self.extend_type = extend_type
        self.shift_amount = shift_amount
    
    def __str__(self):
        """Return formatted memory operand based on addressing mode"""
        base = str(self.base_register)
        
        if self.mode.value == AddressingMode.IMMEDIATE()._value:
            # Format: [x0, #16]
            if isinstance(self.offset, int) and self.offset != 0:
                return f"[{base}, #{self.offset}]"
            return f"[{base}]"
        elif self.mode.value == AddressingMode.PRE_INDEXED()._value:
            # Format: [x0, #16]!
            return f"[{base}, #{self.offset}]!"
        elif self.mode.value == AddressingMode.POST_INDEXED()._value:
            # Format: [x0], #16
            return f"[{base}], #{self.offset}"
        elif self.mode.value == AddressingMode.REGISTER_OFFSET()._value:
            # Format: [x0, x1]
            if isinstance(self.offset, Register):
                return f"[{base}, {self.offset}]"
            return f"[{base}]"
        elif self.mode.value == AddressingMode.REGISTER_EXTENDED()._value:
            # Format: [x0, w1, SXTW #2]
            if isinstance(self.offset, Register) and self.extend_type:
                if self.shift_amount:
                    return f"[{base}, {self.offset}, {self.extend_type} #{self.shift_amount}]"
                return f"[{base}, {self.offset}, {self.extend_type}]"
            return f"[{base}]"
        
        # Default case
        return f"[{base}]"


class LabelOperand(Operand):
    """Represents a label operand"""
    def __init__(self, name: str):
        self.name = name
    
    def __str__(self):
        """Return label name, e.g. '.L1' or 'func'"""
        return self.name


class ConditionOperand(Operand):
    """Represents a condition code operand"""
    def __init__(self, condition: Condition):
        self.condition = condition
    
    def __str__(self):
        """Return condition name, e.g. 'EQ' or 'NE'"""
        return str(self.condition)


class ParamType:
    """Parameter types for instruction operands, stored as an integer value with validation"""
    
    # Map of integers to string representations
    _INT_TO_STR: ClassVar[Dict[int, str]] = {
        0: "NONE",
        1: "REGISTER",
        2: "IMMEDIATE",
        3: "MEMORY",
        4: "LABEL",
        5: "CONDITION",
        6: "SHIFT",
        7: "EXTEND",
        8: "SHIFT_TYPE_OR_EXTEND_TYPE"
    }
    
    # Valid range for parameter type values
    _MIN_VALUE = 0
    _MAX_VALUE = 8
    
    def __init__(self, value: int):
        """Initialize with integer value, validating it's in the proper range"""
        if not isinstance(value, int):
            raise TypeError("ParamType value must be an integer")
        
        if value < self._MIN_VALUE or value > self._MAX_VALUE:
            raise ValueError(f"ParamType value must be between {self._MIN_VALUE} and {self._MAX_VALUE}")
        
        self._value = value
    
    @property
    def value(self) -> int:
        """Get the integer value of the parameter type"""
        return self._value
    
    def to_string(self) -> str:
        """Convert parameter type to its string representation"""
        return self._INT_TO_STR[self._value]
    
    def __str__(self) -> str:
        """String representation using the mapping"""
        return self.to_string()
    
    def __eq__(self, other) -> bool:
        """Compare parameter types by their integer value"""
        if isinstance(other, ParamType):
            return self._value == other._value
        return False
    
    # Constants for common parameter types
    @classmethod
    def NONE(cls) -> 'ParamType':
        return cls(0)
    
    @classmethod
    def REGISTER(cls) -> 'ParamType':
        return cls(1)
    
    @classmethod
    def IMMEDIATE(cls) -> 'ParamType':
        return cls(2)
    
    @classmethod
    def MEMORY(cls) -> 'ParamType':
        return cls(3)
    
    @classmethod
    def LABEL(cls) -> 'ParamType':
        return cls(4)
    
    @classmethod
    def CONDITION(cls) -> 'ParamType':
        return cls(5)
    
    @classmethod
    def SHIFT(cls) -> 'ParamType':
        return cls(6)
    
    @classmethod
    def EXTEND(cls) -> 'ParamType':
        return cls(7)
    
    @classmethod
    def SHIFT_TYPE(cls) -> 'ParamType':
        return cls(8)
    
    @classmethod
    def EXTEND_TYPE(cls) -> 'ParamType':
        return cls(8)


class Instruction:
    """Represents an ARM64 instruction"""
    
    def __init__(self, opcode: Union[str, InstructionType], operands: List[Operand] = None, comment: str = None):
        # Handle opcode
        if isinstance(opcode, InstructionType):
            self.instr_type = opcode
        else:
            try:
                # Try to get the instruction type based on operands
                has_immediate = operands and any(isinstance(op, ImmediateOperand) for op in operands)
                
                # Special handling for nop instruction
                if opcode.lower() == "nop":
                    self.instr_type = InstructionType(48)  # NOP
                else:
                    self.instr_type = InstructionType.from_string(opcode, has_immediate)
            except ValueError:
                raise ValueError(f"Unknown instruction: {opcode}")
        
        # Handle operands
        self.operands = operands or []
        
        # Handle comment
        self.comment = comment
    
    def __str__(self):
        """Convert instruction to string representation."""
        # Start with the opcode
        if not self.operands:
            result = self.instr_type.to_string()
        else:
            # Check for both instruction type 40 (conditional branch) and type 31 (normal branch with condition operand)
            if (self.instr_type.value == 40 or self.instr_type.value == 31) and len(self.operands) >= 2 and isinstance(self.operands[0], ConditionOperand):
                # Format as "b.cond label" instead of "b cond, label"
                condition = self.operands[0].condition.to_string().lower()
                label = str(self.operands[1])
                result = f"b.{condition} {label}"
            else:
                # Normal instruction formatting
                operand_strs = [str(op) for op in self.operands]
                result = f"{self.instr_type.to_string()} {', '.join(operand_strs)}"
        
        # Add comment if present
        if self.comment:
            result = f"{result} // {self.comment}"
            
        return result


class Label:
    """Represents a label in the assembly code"""
    def __init__(self, name: str):
        self.name = name
    
    def __str__(self):
        """Return formatted label definition, e.g. 'loop:'"""
        return f"{self.name}:"


class Directive:
    """Represents an assembler directive"""
    def __init__(self, name: str, args: List[str] = None):
        self.name = name
        self.args = args or []
    
    def __str__(self):
        """Return formatted directive, e.g. '.globl main'"""
        args_str = ", ".join(self.args)
        return f".{self.name} {args_str}".strip()


class AssemblyProgram:
    """Represents a complete ARM64 assembly program"""
    def __init__(self, name: str = "unnamed"):
        self.name = name
        self.elements: List[Union[Instruction, Label, Directive]] = []
        self.labels: Dict[str, int] = {}  # Maps label names to their positions
    
    def add_element(self, element: Union[Instruction, Label, Directive]):
        """Add an element to the program"""
        self.elements.append(element)
        if isinstance(element, Label):
            self.labels[element.name] = len(self.elements) - 1
    
    def __str__(self):
        """Convert entire program to valid assembly code"""
        lines = []
        
        # Add optional header comment with program name
        lines.append(f"// Assembly program: {self.name}")
        lines.append("")
        
        # Process each element
        for element in self.elements:
            # Handle different element types
            if isinstance(element, Directive):
                # Directives start at beginning of line
                lines.append(str(element))
            elif isinstance(element, Label):
                # Labels start at beginning of line
                lines.append(str(element))
            elif isinstance(element, Instruction):
                # Instructions are indented
                lines.append(f"    {str(element)}")
            else:
                # Unknown element type, just convert to string
                lines.append(str(element))
        
        # Join all lines with newlines
        return "\n".join(lines)
    
    def to_file(self, filename: str):
        """Write the assembly program to a file"""
        with open(filename, 'w') as f:
            f.write(str(self))
