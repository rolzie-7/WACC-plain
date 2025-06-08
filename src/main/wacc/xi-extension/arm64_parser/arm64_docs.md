# ARM64 Module Documentation

## Class Overview

The ARM64 module uses an integer-based approach where each class stores a single integer value and provides validation and mapping to/from string representations.

### Core Classes

#### Register

Represents ARM64 registers (x0-x30, sp, w0-w30, wzr, xzr).

```python
# Constructor
Register(value: int)

# Integer values:
# 0-30: X registers (x0-x30)
# 31: XZR (zero register)
# 32-62: W registers (w0-w30)
# 63: WZR (zero register)
# 62/30: SP (stack pointer) - same value as x30/w30

# Class methods
Register.from_string(name: str) -> Register  # Convert register name to Register object

# Instance methods
register.value -> int          # Get integer value
register.to_string() -> str    # Get register name
register.__str__() -> str      # String representation (same as to_string)
```

#### AddressingMode

Represents ARM64 memory addressing modes.

```python
# Constructor
AddressingMode(value: int)

# Integer values:
# 0: OFFSET          (e.g., [x0, #8])
# 1: IMMEDIATE       (e.g., [x0, #8])
# 2: PRE_INDEXED     (e.g., [x0, #8]!)
# 3: POST_INDEXED    (e.g., [x0], #8)
# 4: REGISTER        (e.g., [x0, x1])
# 5: EXTENDED        (e.g., [x0, w1, SXTW])

# Class methods
AddressingMode.from_string(name: str) -> AddressingMode

# Instance methods
mode.value -> int         # Get integer value
mode.to_string() -> str   # Get addressing mode name
mode.__str__() -> str     # String representation
```

#### ExtendType

Represents register extension types.

```python
# Constructor
ExtendType(value: int)

# Integer values:
# 0: NONE
# 1: UXTB (Unsigned extend byte)
# 2: UXTH (Unsigned extend halfword)
# 3: UXTW (Unsigned extend word)
# 4: UXTX (Unsigned extend doubleword)
# 5: SXTB (Signed extend byte)
# 6: SXTH (Signed extend halfword)
# 7: SXTW (Signed extend word)
# 8: SXTX (Signed extend doubleword)

# Class methods
ExtendType.from_string(name: str) -> ExtendType

# Instance methods
extend.value -> int         # Get integer value
extend.to_string() -> str   # Get extend type name
extend.__str__() -> str     # String representation
```

#### ShiftType

Represents shift operations.

```python
# Constructor
ShiftType(value: int)

# Integer values:
# 0: NONE (No shift)
# 1: LSL  (Logical shift left)
# 2: LSR  (Logical shift right)
# 3: ASR  (Arithmetic shift right)
# 4: ROR  (Rotate right)

# Class methods
ShiftType.from_string(name: str) -> ShiftType

# Instance methods
shift.value -> int         # Get integer value
shift.to_string() -> str   # Get shift type name
shift.__str__() -> str     # String representation
```

#### Condition

Represents branch conditions.

```python
# Constructor
Condition(value: int)

# Integer values:
# 0: NONE (No condition)
# 1: EQ   (Equal)
# 2: NE   (Not equal)
# 3: CS   (Carry set / higher or same)
# 4: CC   (Carry clear / lower)
# 5: MI   (Minus / negative)
# 6: PL   (Plus / positive or zero)
# 7: VS   (Overflow)
# 8: VC   (No overflow)
# 9: HI   (Higher)
# 10: LS  (Lower or same)
# 11: GE  (Greater than or equal)
# 12: LT  (Less than)
# 13: GT  (Greater than)
# 14: LE  (Less than or equal)
# 15: AL  (Always)

# Class methods
Condition.from_string(name: str) -> Condition

# Instance methods
condition.value -> int         # Get integer value
condition.to_string() -> str   # Get condition name
condition.__str__() -> str     # String representation
```

#### InstructionType

Represents categories of ARM64 instructions.

```python
# Constructor
InstructionType(value: int)

# Integer values: 
# 0-23: Various instruction types like ARITHMETIC, LOGICAL, MEMORY, etc.

# Class methods
InstructionType.from_string(name: str) -> InstructionType

# Instance methods
inst_type.value -> int         # Get integer value
inst_type.to_string() -> str   # Get instruction type name
inst_type.__str__() -> str     # String representation
```

### Operand Classes

#### ParamType

Enum for parameter types.

```python
# Integer values:
# 0: NONE
# 1: REGISTER
# 2: IMMEDIATE
# 3: SHIFTED_REGISTER
# 4: EXTENDED_REGISTER
# 5: MEMORY
# 6: LABEL
# 7: CONDITION
```

#### Operand

Base class for all operands.

```python
# Constructor
Operand(param_type: int)

# Instance methods
operand.param_type -> int     # Get parameter type
operand.__str__() -> str      # String representation
```

#### ImmediateOperand

Represents an immediate value.

```python
# Constructor
ImmediateOperand(value: int)

# Instance methods
immediate.value -> int         # Get immediate value
immediate.__str__() -> str     # String representation (#value)
```

#### RegisterOperand

Represents a register operand.

```python
# Constructor
RegisterOperand(register: Register)

# Instance methods
reg_op.register -> Register    # Get register object
reg_op.__str__() -> str        # String representation (register name)
```

#### ShiftedRegisterOperand

Represents a register with a shift.

```python
# Constructor
ShiftedRegisterOperand(register: Register, shift_type: ShiftType, shift_amount: int)

# Instance methods
shifted.register -> Register         # Get register object
shifted.shift_type -> ShiftType      # Get shift type
shifted.shift_amount -> int          # Get shift amount
shifted.__str__() -> str             # String representation (e.g., "x0, LSL #2")
```

#### ExtendedRegisterOperand

Represents a register with an extension.

```python
# Constructor
ExtendedRegisterOperand(register: Register, extend_type: ExtendType, extend_amount: int = 0)

# Instance methods
extended.register -> Register        # Get register object
extended.extend_type -> ExtendType   # Get extend type
extended.extend_amount -> int        # Get extend amount
extended.__str__() -> str            # String representation (e.g., "w0, SXTW #2")
```

#### MemoryOperand

Represents a memory operand.

```python
# Constructor
MemoryOperand(
    base_register: Register,
    addressing_mode: AddressingMode,
    offset: int = 0,
    offset_register: Register = None,
    extend_type: ExtendType = None,
    shift_type: ShiftType = None,
    shift_amount: int = 0
)

# Instance methods
memory.base_register -> Register               # Get base register
memory.addressing_mode -> AddressingMode       # Get addressing mode
memory.offset -> int                           # Get offset (for immediate modes)
memory.offset_register -> Register             # Get offset register (for register modes)
memory.extend_type -> ExtendType               # Get extend type (for extended mode)
memory.shift_type -> ShiftType                 # Get shift type (for register with shift)
memory.shift_amount -> int                     # Get shift amount
memory.__str__() -> str                        # String representation
```

#### LabelOperand

Represents a label operand.

```python
# Constructor
LabelOperand(label: str)

# Instance methods
label_op.label -> str          # Get label string
label_op.__str__() -> str      # String representation (label)
```

#### ConditionOperand

Represents a condition operand.

```python
# Constructor
ConditionOperand(condition: Condition)

# Instance methods
cond_op.condition -> Condition  # Get condition object
cond_op.__str__() -> str        # String representation (condition name)
```

### Program Components

#### Instruction

Represents an ARM64 instruction.

```python
# Constructor
Instruction(opcode: str, operands: list = None, comment: str = None)

# Instance methods
instruction.opcode -> str                 # Get instruction opcode
instruction.operands -> list              # Get list of operands
instruction.comment -> str                # Get comment
instruction.instruction_type -> int       # Get instruction type
instruction.__str__() -> str              # String representation
```

#### Label

Represents a label in assembly.

```python
# Constructor
Label(name: str)

# Instance methods
label.name -> str              # Get label name
label.__str__() -> str         # String representation (name:)
```

#### Directive

Represents an assembler directive.

```python
# Constructor
Directive(name: str, args: list = None)

# Instance methods
directive.name -> str          # Get directive name
directive.args -> list         # Get directive arguments
directive.__str__() -> str     # String representation (.name args)
```

#### AssemblyProgram

Represents a complete assembly program.

```python
# Constructor
AssemblyProgram(name: str)

# Instance methods
program.name -> str                       # Get program name
program.elements -> list                  # Get program elements
program.labels -> dict                    # Get labels dictionary
program.add_element(element) -> None      # Add element to program
program.__str__() -> str                  # Generate formatted assembly code
program.write_to_file(filename) -> None   # Write program to file
```

## Usage Examples

### Creating Registers

```python
# Create x0 register
x0 = Register(0)  

# Create w0 register
w0 = Register(32)  

# Access value
print(x0.value)  # 0

# Get string representation
print(x0)  # "x0"
```

### Creating Instructions

```python
# ADD x0, x1, x2
add_inst = Instruction("add", [
    RegisterOperand(Register(0)),  # x0
    RegisterOperand(Register(1)),  # x1
    RegisterOperand(Register(2))   # x2
])

# LDR x0, [sp, #16]
ldr_inst = Instruction("ldr", [
    RegisterOperand(Register(0)),  # x0
    MemoryOperand(
        Register(62),              # sp (same value as register 30)
        AddressingMode(1),         # IMMEDIATE
        16                         # offset
    )
])

# String representation
print(add_inst)  # "add x0, x1, x2"
print(ldr_inst)  # "ldr x0, [sp, #16]"
```

### Building a Program

```python
# Create program
program = AssemblyProgram("example")

# Add elements
program.add_element(Directive("text"))
program.add_element(Label("main"))
program.add_element(Instruction("mov", [
    RegisterOperand(Register(0)),
    ImmediateOperand(42)
]))
program.add_element(Instruction("ret"))

# Output program
print(program)
# .text
# main:
#     mov x0, #42
#     ret
``` 