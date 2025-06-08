import torch as t
import torch.nn as nn

# Import constants from the config file
from arm_config import (
    REG_INSTR_NO, INSTRUCTION_TYPE_EMBEDDING_DIM, REGISTER_EMBEDDING_DIM,
    ADDRESSING_MODE_EMBEDDING_DIM, SHIFT_TYPE_EMBEDDING_DIM, EXTEND_TYPE_EMBEDDING_DIM,
    CONDITION_EMBEDDING_DIM, HAS_LABEL_EMBEDDING_DIM, LITERAL_EMBEDDING_DIM,
    INSTRUCTION_TYPES, REGISTERS, ADDRESSING_MODES, SHIFT_TYPES, EXTEND_TYPES, CONDITIONS,
    LABEL_ID_EMBEDDING_DIM, DEVICE, to_device, HAS_LITERAL_EMBEDDING_DIM
)

# Import the label symbol table
try:
    from label_symbols import get_label_id, reset_label_table, get_all_labels
except ImportError:
    # Define stubs for when the module isn't available
    def get_label_id(label_name, create_if_missing=True): return 0
    def reset_label_table(): pass
    def get_all_labels(): return {}

class ArmResult:
    def __init__(
            self,
            instruction_type: t.Tensor,    # [71] one-hot for instruction types
            registers: t.Tensor,           # [3, 66] three register slots, each 66-bit one-hot
            addressing_mode: t.Tensor,     # [5] one-hot for addressing modes
            shift_type: t.Tensor,         # [4] one-hot for shift types
            extend_type: t.Tensor,        # [8] one-hot for extend types
            condition: t.Tensor,          # [18] one-hot for condition codes
            has_label: t.Tensor,          # [1] binary flag for label presence
            has_literal: t.Tensor,        # [1] binary flag for literal presence
            literal: int,                 # scalar value for immediates/literals
            label_id: int = 0             # unique ID for the label (if present)
            ):
        self.instruction_type = to_device(instruction_type)
        self.registers = to_device(registers)
        self.addressing_mode = to_device(addressing_mode)
        self.shift_type = to_device(shift_type)
        self.extend_type = to_device(extend_type)
        self.condition = to_device(condition)
        self.has_label = to_device(has_label)
        self.has_literal = to_device(has_literal)
        self.literal = literal
        self.label_id = label_id

    def __str__(self):
        return f"Instruction Type: {self.instruction_type.argmax().item()}\n" \
               f"Registers: {self.registers.argmax(dim=1).tolist()}\n" \
               f"Addressing Mode: {self.addressing_mode.argmax().item()}\n" \
               f"Shift Type: {self.shift_type.argmax().item()}\n" \
               f"Extend Type: {self.extend_type.argmax().item()}\n" \
               f"Condition: {self.condition.argmax().item()}\n" \
               f"Has Label: {self.has_label.item()}\n" \
               f"Label ID: {self.label_id}\n" \
               f"Literal: {self.literal}\n" \
               f"Has Literal: {self.has_literal.item()}\n"
    
    @classmethod
    def from_str(cls, asm_str: str) -> 'ArmResult':
        # Create zero tensors for all fields
        instr_type = t.zeros(INSTRUCTION_TYPE_EMBEDDING_DIM, device=DEVICE)
        registers = t.zeros(REG_INSTR_NO, REGISTER_EMBEDDING_DIM, device=DEVICE)
        addr_mode = t.zeros(ADDRESSING_MODE_EMBEDDING_DIM, device=DEVICE)
        shift_type = t.zeros(SHIFT_TYPE_EMBEDDING_DIM, device=DEVICE)
        extend_type = t.zeros(EXTEND_TYPE_EMBEDDING_DIM, device=DEVICE)
        condition = t.zeros(CONDITION_EMBEDDING_DIM, device=DEVICE)
        has_label = t.zeros(HAS_LABEL_EMBEDDING_DIM, device=DEVICE)
        has_literal = t.zeros(HAS_LITERAL_EMBEDDING_DIM, device=DEVICE)
        literal = 0
        label_id = 0  # Default label ID is 0 (no label)

        # Parse the assembly string
        asm_str = asm_str.lower().strip()
        
        # First, split the instruction from the operands
        tokens = asm_str.split(None, 1)  # Split on first whitespace
        instr = tokens[0]
        operands = tokens[1] if len(tokens) > 1 else ""
        
        # Check for condition code in instruction (e.g., "b.eq")
        if '.' in instr:
            instr_parts = instr.split('.')
            base_instr = instr_parts[0]
            cond = instr_parts[1]
            if cond in CONDITIONS:
                condition[CONDITIONS[cond]] = 1
        else:
            base_instr = instr
        
        # Parse instruction type
        if base_instr in INSTRUCTION_TYPES:
            instr_type[INSTRUCTION_TYPES[base_instr]] = 1
        
        # Check for pre-indexed addressing mode
        is_pre_indexed = "]!" in operands
        is_post_indexed = "], #" in operands or "] #" in operands
        
        if is_pre_indexed:
            addr_mode[ADDRESSING_MODES['pre_indexed']] = 1
        elif is_post_indexed:
            addr_mode[ADDRESSING_MODES['post_indexed']] = 1
        elif '[' in operands and ']' in operands:
            addr_mode[ADDRESSING_MODES['immediate']] = 1
        
        # Replace commas with space commas space to ensure proper tokenization
        operands = operands.replace(',', ' , ')
        
        # Special tokenization for addressing modes
        if is_pre_indexed or is_post_indexed or ('[' in operands and ']' in operands):
            # Handle register operations
            parts = []
            current_part = ""
            in_brackets = False
            
            for c in operands:
                if c == '[':
                    in_brackets = True
                    if current_part:
                        for part in current_part.strip().split():
                            if part:
                                parts.append(part)
                        current_part = ""
                    parts.append('[')
                elif c == ']':
                    in_brackets = False
                    if current_part:
                        for part in current_part.strip().split():
                            if part:
                                parts.append(part)
                        current_part = ""
                    
                    if operands.find(']!', operands.index(c)) == operands.index(c):
                        parts.append(']!')
                    else:
                        parts.append(']')
                elif c == ',' and not in_brackets:
                    if current_part:
                        for part in current_part.strip().split():
                            if part:
                                parts.append(part)
                        current_part = ""
                elif c == '#':
                    if current_part:
                        for part in current_part.strip().split():
                            if part:
                                parts.append(part)
                        current_part = ""
                    parts.append('#')
                else:
                    current_part += c
            
            if current_part:
                for part in current_part.strip().split():
                    if part:
                        parts.append(part)
        else:
            # Simpler tokenization for non-addressing mode instructions
            operands = operands.replace(',', ' ')
            operands = operands.replace('#', ' # ')
            parts = [p for p in operands.split() if p]
            
        # Insert instruction at beginning for consistent processing
        parts = [base_instr] + parts
        
        # Process the tokens
        reg_idx = 0
        in_addressing_mode = False
        i = 1  # Skip the instruction
        
        while i < len(parts):
            part = parts[i]
            
            # Handle registers
            if part in REGISTERS:
                if reg_idx < REG_INSTR_NO:
                    registers[reg_idx][REGISTERS[part]] = 1
                    reg_idx += 1
                i += 1
                continue
                
            # Handle addressing mode start
            elif part == '[':
                in_addressing_mode = True
                i += 1
                continue
                
            # Handle addressing mode end
            elif part == ']' or part == ']!':
                in_addressing_mode = False
                i += 1
                continue
                
            # Handle shift types
            elif part in SHIFT_TYPES:
                shift_type[SHIFT_TYPES[part]] = 1
                i += 1
                continue
                
            # Handle extend types
            elif part in EXTEND_TYPES:
                extend_type[EXTEND_TYPES[part]] = 1
                i += 1
                continue
            
            # Handle immediate values
            elif part == '#':
                if i + 1 < len(parts) and parts[i + 1].replace('-', '').isdigit():
                    literal = int(parts[i + 1])
                    has_literal[0] = 1  # Set has_literal flag for immediate values
                    i += 2
                    continue
                i += 1
                continue
            
            # Handle standalone literals
            elif part.replace('-', '').isdigit():
                literal = int(part)
                has_literal[0] = 1  # Set has_literal flag for standalone literals
                i += 1
                continue
                
            # Handle labels - avoid special characters like ! and pre/post indexing operators
            elif not in_addressing_mode and (
                    part.startswith('.') or (
                        i == len(parts) - 1 and
                        not part.isdigit() and
                        part not in ['!', ']!', ',', ']', '['] and
                        '#' not in part
                    )
                ):
                has_label[0] = 1
                # Get or create a unique ID for this label
                label_name = part
                label_id = get_label_id(label_name)
                i += 1
                continue
            
            # If none of the above, move to the next token
            i += 1
        
        return cls(instr_type, registers, addr_mode,
                   shift_type, extend_type, condition, has_label, has_literal, literal, label_id)
    
    # Add to_device method to ensure all tensors are on the specified device
    def to_device(self, device):
        """
        Move all tensor attributes to the specified device.
        """
        self.instruction_type = self.instruction_type.to(device)
        self.registers = self.registers.to(device)
        self.addressing_mode = self.addressing_mode.to(device)
        self.shift_type = self.shift_type.to(device)
        self.extend_type = self.extend_type.to(device)
        self.condition = self.condition.to(device)
        self.has_label = self.has_label.to(device)
        self.has_literal = self.has_literal.to(device)
        
        # Convert scalar tensors to device if needed
        if isinstance(self.literal, t.Tensor):
            self.literal = self.literal.to(device)
        if isinstance(self.label_id, t.Tensor):
            self.label_id = self.label_id.to(device)
        
        return self

class Disembedder(nn.Module):
    def __init__(self, embedding_dim: int, out_dim: int):
        super().__init__()
        # defining the dimensions
        self.hidden_dim = embedding_dim
        # shrinking to do rank bottleneck
        self.mid_dim = embedding_dim // 2

        self.l1 = nn.Linear(embedding_dim, self.mid_dim)
        self.layernorm1 = nn.LayerNorm(self.mid_dim)
        self.relu = nn.LeakyReLU(0.05)
        self.l2 = nn.Linear(self.mid_dim, out_dim)
        self.layernorm2 = nn.LayerNorm(out_dim)

    def forward(self, x: t.Tensor) -> t.Tensor:
        x = self.l1(x)
        x = self.layernorm1(x)
        x = self.relu(x)
        x = self.l2(x)
        x = self.layernorm2(x)
        return x
    
class LiteralDisembedder(nn.Module):
    def __init__(self, embedding_dim: int, out_dim: int):
        super().__init__()
        self.disembedder = nn.Sequential(
            nn.Linear(embedding_dim, embedding_dim // 2),
            nn.Tanh(),
            nn.Linear(embedding_dim // 2, out_dim)
        )
        
    def forward(self, x: t.Tensor) -> t.Tensor:
        return self.disembedder(x)
        

class SingletonNormalized(nn.Module):
    def __init__(self, embedding_dim: int, out_dim: int, use_sigmoid=True):
        super().__init__()
        # More expressive network with multiple layers
        self.net = nn.Sequential(
            nn.Linear(embedding_dim, embedding_dim // 2),
            nn.LeakyReLU(0.1),
            nn.Linear(embedding_dim // 2, out_dim)
        )
        # Option to use sigmoid for 0-1 normalization (for has_label)
        self.use_sigmoid = use_sigmoid
        self.sigmoid = nn.Sigmoid()
        
    def forward(self, x):
        x = self.net(x)
        # Apply sigmoid only if requested (for binary outputs like has_label)
        if self.use_sigmoid:
            return self.sigmoid(x)
        return x

class DisembedderSoftmax(nn.Module):
    def __init__(self, embedding_dim: int, out_dim: int):
        super().__init__()
        self.disembedder = Disembedder(embedding_dim, out_dim)
        self.softmax = nn.Softmax(dim=-1)
        
    def forward(self, x: t.Tensor) -> t.Tensor:
        x = self.disembedder(x)
        return self.softmax(x)

class Vector2Arm(nn.Module):
    def __init__(self, embedding_dim: int = 128):
        super().__init__()
        self.hidden_dim = embedding_dim
        self.instruction_type_embedding = DisembedderSoftmax(embedding_dim, INSTRUCTION_TYPE_EMBEDDING_DIM)
        self.registers_embedding = Disembedder(embedding_dim, REG_INSTR_NO * REGISTER_EMBEDDING_DIM)
        self.addressing_mode_embedding = DisembedderSoftmax(embedding_dim, ADDRESSING_MODE_EMBEDDING_DIM)
        self.shift_type_embedding = Disembedder(embedding_dim, SHIFT_TYPE_EMBEDDING_DIM)
        self.extend_type_embedding = Disembedder(embedding_dim, EXTEND_TYPE_EMBEDDING_DIM)
        self.condition_embedding = Disembedder(embedding_dim, CONDITION_EMBEDDING_DIM)
        self.has_label_embedding = SingletonNormalized(embedding_dim, HAS_LABEL_EMBEDDING_DIM, use_sigmoid=True) # shouldn't be softmaxed, what would it be softmaxxed with?
        self.literal_embedding = LiteralDisembedder(embedding_dim, LITERAL_EMBEDDING_DIM)
        self.label_id_embedding = SingletonNormalized(embedding_dim, LABEL_ID_EMBEDDING_DIM, use_sigmoid=False)
        self.has_literal_embedding = SingletonNormalized(embedding_dim, HAS_LITERAL_EMBEDDING_DIM)

    def forward(self, x: t.Tensor) -> ArmResult:
        # We always return label_id=0 from the forward method since we can't 
        # predict label IDs from embeddings (they're assigned during parsing)
        reg_embed_reshaped = self.registers_embedding(x).view(REG_INSTR_NO, REGISTER_EMBEDDING_DIM)
        return ArmResult(
            instruction_type=self.instruction_type_embedding(x),
            registers=reg_embed_reshaped,
            addressing_mode=self.addressing_mode_embedding(x),
            shift_type=self.shift_type_embedding(x),
            extend_type=self.extend_type_embedding(x),
            condition=self.condition_embedding(x),
            has_label=self.has_label_embedding(x),
            has_literal=self.has_literal_embedding(x),
            literal=self.literal_embedding(x),
            label_id=self.label_id_embedding(x)
        )

