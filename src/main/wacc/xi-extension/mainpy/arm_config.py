"""
ARM Configuration parameters for the WACC-ARM neural compiler.

This file contains constants that define the shapes and sizes of various 
tensors used throughout the ARM compilation system.
"""

import torch as t

# Device configuration - use MPS if available, else CPU
DEVICE = t.device("mps" if hasattr(t.backends, "mps") and t.backends.mps.is_available() else "cpu")
# DEVICE = t.device("cpu")
print(f"Using device: {DEVICE}")

# Helper function to ensure tensors are on the correct device
def to_device(tensor):
    if isinstance(tensor, t.Tensor):
        return tensor.to(DEVICE)
    return tensor

EMBEDDING_DIM = 2048

TRAIN_EPOCHS = 5

DROPOUT_RATE = 0.1
# Number of register instruction slots in an ARM instruction
REG_INSTR_NO = 3

MAGIC_PRIME = 10009

# CYCLES and training
MAX_CYCLES = 100

# Embedding dimensions for each component of an ARM instruction
INSTRUCTION_TYPE_EMBEDDING_DIM = 71  # Number of possible instruction types
REGISTER_EMBEDDING_DIM = 66          # Number of possible registers
ADDRESSING_MODE_EMBEDDING_DIM = 5    # Number of possible addressing modes
SHIFT_TYPE_EMBEDDING_DIM = 4         # Number of possible shift types
EXTEND_TYPE_EMBEDDING_DIM = 8        # Number of possible extend types
CONDITION_EMBEDDING_DIM = 18         # Number of possible conditions
HAS_LABEL_EMBEDDING_DIM = 1          # Binary flag for label presence
LITERAL_EMBEDDING_DIM = 1            # Dimension for literal value embedding
LABEL_ID_EMBEDDING_DIM = 1           # Dimension for label ID embedding
HAS_LITERAL_EMBEDDING_DIM = 1        # Binary flag for literal presence

# Default model configuration
DEFAULT_EMBEDDING_DIM = 128          # Default dimension for transformer embeddings

# Instruction type mappings (expanded based on WACC examples)
INSTRUCTION_TYPES = {
    # Arithmetic
    'add': 0, 'sub': 1, 'mul': 2, 'div': 3,
    'adds': 4, 'subs': 5, 'muls': 6, 'divs': 7,
    'adc': 8, 'sbc': 9, 'adcs': 10, 'sbcs': 11,
    'sdiv': 12, 'udiv': 13, 'msub': 14, 'madd': 15,
    'smull': 16, 'umull': 17, 'negs': 18,
    
    # Logical
    'and': 19, 'orr': 20, 'eor': 21, 'bic': 22,
    'ands': 23, 'orrs': 24, 'eors': 25, 'bics': 26,
    'tst': 27,
    
    # Shift
    'lsl': 28, 'lsr': 29, 'asr': 30, 'ror': 31,
    'lsls': 32, 'lsrs': 33, 'asrs': 34, 'rors': 35,
    
    # Load/Store
    'ldr': 36, 'str': 37,
    'ldrb': 38, 'strb': 39,
    'ldrh': 40, 'strh': 41,
    'ldrsw': 42, 'strsw': 43,
    'ldrsh': 44, 'strsh': 45,
    'ldrsb': 46, 'strsb': 47,
    'ldur': 48, 'stur': 49,
    'ldurb': 50, 'sturb': 51,
    
    # Move
    'mov': 52, 'movz': 53, 'movk': 54, 'movn': 55,
    
    # Compare
    'cmp': 56, 'cmn': 57, 'teq': 58,
    
    # Branches and jumps
    'b': 59, 'bl': 60, 'ret': 61, 'cbz': 62, 'cbnz': 63,
    
    # Special
    'stp': 64, 'ldp': 65, 'adrp': 66, 'adr': 67,
    'cset': 68, 'csel': 69, 'fmov': 70
}

# Register mappings (66 registers)
REGISTERS = {
    # General purpose registers (x0-x30)
    **{f'x{i}': i for i in range(31)},
    # 32-bit registers (w0-w30) - with distinct indices
    **{f'w{i}': i + 31 for i in range(31)},
    # Special registers
    'sp': 31, 'xzr': 63, 'wzr': 64, 'nzcv': 65,
    'lr': 30, 'fp': 29
}

# Addressing modes (5 types)
ADDRESSING_MODES = {
    'immediate': 0,
    'pre_indexed': 1,
    'post_indexed': 2,
    'register_offset': 3,
    'register_extended': 4
}

# Shift types (4 types)
SHIFT_TYPES = {
    'lsl': 0,
    'lsr': 1,
    'asr': 2,
    'ror': 3
}

# Extend types (8 types)
EXTEND_TYPES = {
    'uxtb': 0, 'uxth': 1, 'uxtw': 2, 'uxtx': 3,
    'sxtb': 4, 'sxth': 5, 'sxtw': 6, 'sxtx': 7
}

# Condition codes (18 types)
CONDITIONS = {
    'eq': 0, 'ne': 1, 'cs': 2, 'hs': 3,
    'cc': 4, 'lo': 5, 'mi': 6, 'pl': 7,
    'vs': 8, 'vc': 9, 'hi': 10, 'ls': 11,
    'ge': 12, 'lt': 13, 'gt': 14, 'le': 15,
    'al': 16, 'nv': 17
} 