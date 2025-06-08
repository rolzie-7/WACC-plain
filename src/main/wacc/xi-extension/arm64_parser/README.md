# ARM64 Parser Module

A lightweight and efficient module for working with ARM64 assembly code. This module provides representations of ARM64 assembly components using a simplified integer-based approach, where each class stores just a single integer value with proper validation and string mapping.

## Features

- **Integer-Based Storage**: Every class stores just a single integer value, making the representation compact and efficient
- **Validation**: Built-in validation in each constructor ensures integer values are within valid ranges
- **Mapping Functions**: Comprehensive mapping between integer values and string representations
- **Clean API**: Consistent interface across all components
- **Assembly Program Building**: Tools for programmatically constructing ARM64 assembly programs

## Key Components

- `Register`: Represents ARM64 registers (x0-x30, sp, w0-w30, wzr, xzr)
- `AddressingMode`: Represents memory addressing modes (PRE_INDEXED, POST_INDEXED, etc.)
- `ExtendType`: Register extension types (UXTB, SXTW, etc.)
- `ShiftType`: Shift operations (LSL, LSR, ASR, ROR)
- `Condition`: Branch conditions (EQ, NE, GT, etc.)
- `InstructionType`: Categories of ARM64 instructions
- `Operand` subclasses: Various operand types (Register, Immediate, Memory, etc.)
- `Instruction`: Representation of ARM64 instructions with operands
- `AssemblyProgram`: Container for full assembly programs including labels and directives

## Installation

Place the `arm64_parser` directory in your project or add it to your Python path.

## Usage

### Basic Class Usage

```python
# Create registers with integer values
x0 = Register(0)  # Integer value 0 represents register x0
x1 = Register(1)
sp = Register(62)  # Special registers have specific values

# Access the integer value
print(f"x0 value: {x0.value}")  # 0

# Get string representation
print(f"x0 string: {x0}")  # "x0"

# Create other components
eq_cond = Condition(1)  # EQ condition
lsl = ShiftType(1)      # LSL shift

# Equality works as expected
assert Register(0) == Register(0)
assert Register(0) != Register(1)
```

### String Conversion

```python
# Convert from string to object
x0_str = Register.from_string("x0")
w0_str = Register.from_string("w0")
lsl_str = ShiftType.from_string("LSL")

# Convert from object to string
x0_name = Register(0).to_string()  # "x0"
```

### Creating Instructions

```python
# Simple instruction
ret = Instruction("ret")

# Instruction with register operands
add = Instruction("add", [
    RegisterOperand(Register(0)),  # x0
    RegisterOperand(Register(1)),  # x1
    RegisterOperand(Register(2))   # x2
])
# Will format as: "add x0, x1, x2"

# Instruction with immediate operand
addi = Instruction("add", [
    RegisterOperand(Register(0)),  # x0
    RegisterOperand(Register(1)),  # x1
    ImmediateOperand(42)
])
# Will format as: "add x0, x1, #42"

# Memory instruction
ldr = Instruction("ldr", [
    RegisterOperand(Register(0)),  # x0
    MemoryOperand(
        Register(1),               # x1 (base)
        AddressingMode(1),         # IMMEDIATE
        16                         # offset
    )
])
# Will format as: "ldr x0, [x1, #16]"
```

### Building Programs

```python
# Create a program
program = AssemblyProgram("my_program")

# Add directives
program.add_element(Directive("text"))
program.add_element(Directive("global", ["main"]))

# Add a label
program.add_element(Label("main"))

# Add instructions
program.add_element(Instruction("mov", [
    RegisterOperand(Register(0)),  # x0
    ImmediateOperand(42)
], "Load value 42"))

program.add_element(Instruction("ret"))

# Get string representation of the program
program_str = str(program)
```

## Running Tests

Run the included tests to verify the functionality:

```bash
cd arm64_parser
python run_tests.py
```

## Example Script

See the included `example.py` script for a comprehensive demonstration of the module's capabilities.

```bash
cd arm64_parser
python example.py
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License. 