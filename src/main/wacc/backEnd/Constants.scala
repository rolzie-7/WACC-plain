package wacc.backEnd

object Constants {
  // Register indices
  val PC_REGISTER_INDEX = 15      // Program Counter (R15)
  val IP_REGISTER_INDEX = 12      // Intra-Procedure call scratch register (R12)
  val FP_REGISTER_INDEX = 11      // Frame Pointer (R11)
  val SP_REGISTER_INDEX = 13      // Stack Pointer (R13)
  val LR_REGISTER_INDEX = 14      // Link Register (R14)
  
  // Temporary register indices for code generation
  val TEMP_REG_INDEX = 4          // Temporary register (R4) for computation
  val PRESERVE_REG_INDEX = 5      // Temporary register (R5) for preserving values
  val GLOBAL_ACCESS_REG_INDEX = 10 // Register (R10) used for global variable access
  
  // ARM register aliases for argument passing
  val R0_INDEX = 0                // First argument register
  val R1_INDEX = 1                // Second argument register
  val R2_INDEX = 2                // Third argument register 
  val R3_INDEX = 3                // Fourth argument register
  val R6_INDEX = 6                // Register r6
  val R7_INDEX = 7                // Register r7
  val R8_INDEX = 8                // Register r8
  val R9_INDEX = 9                // Register r9
  
  // Memory sizes
  val WORD_SIZE = 4               // Size of a word in bytes (32-bit)
  val BYTE_SIZE = 1               // Size of a byte
  val REFERENCE_SIZE = 4          // Size of a reference/pointer
  val PAIR_SIZE = 8               // Size of a pair (two 4-byte pointers)
  
  // Stack management
  val INITIAL_STACK_OFFSET = -4   // Initial stack offset relative to frame pointer
  val STACK_ALIGNMENT = 8         // Required stack alignment in bytes (ARM requirement)
  val STACK_ALIGNMENT_MASK = 7    // Bitmask for stack alignment (8-1)
  val WORD_ALIGNMENT_MASK = 3     // Bitmask for word alignment (4-1)
  
  // Array and bounds checking
  val ARRAY_LENGTH_OFFSET = -4    // Offset to access array length (before array data)
  val ARRAY_DATA_OFFSET = 0       // Offset to array data (after length field)
  val MIN_ARRAY_INDEX = 0         // Minimum valid array index
  val ARRAY_HEADER_SIZE = 4       // Size of array header (length field)
  
  // Binary shifts
  val WORD_SIZE_SHIFT = 2         // Shift value to multiply by 4 (2^2 = 4)
  val BYTE_SIZE_SHIFT = 0         // Shift value for bytes (2^0 = 1)
  val SIGN_EXTENSION_SHIFT = 31   // Shift value for sign extension (most significant bit)
  
  // Character ranges for CHR operation
  val MIN_CHAR_VALUE = 0          // Minimum valid ASCII value
  val MAX_CHAR_VALUE = 127        // Maximum valid ASCII value

  // Function argument registers
  val MAX_REGISTER_ARGS = 4       // Maximum number of arguments that can be passed in registers
  
  // Loop counters
  val INITIAL_COUNTER_VALUE = 0   // Initial value for counters
  val INCREMENT_COUNTER_VALUE = 1 // Increment value for counters

  // Register lists
  val CALLEE_SAVED_REGISTERS = List(4, 5, 6, 7, 8, 9, 10)  // r4-r10
  val CALLER_SAVED_REGISTERS = List(0, 1, 2, 3)           // r0-r3
  val ALL_USABLE_REGISTERS = (1 to 10).toList ++ List(12)  // r1-r10, r12 (excluding special registers)
  
  // Return codes
  val DEFAULT_EXIT_CODE = 0       // Default successful exit code
  val ERROR_EXIT_CODE = 255       // Exit code for runtime errors
  
  // Memory validation limits
  val MAX_IMMEDIATE_VALUE = 255   // Maximum immediate value for ARM instructions
  val MIN_IMMEDIATE_VALUE = -255  // Minimum immediate value for ARM instructions
  val MAX_MEMORY_OFFSET = 4095    // Maximum memory offset for load/store operations
  val MIN_MEMORY_OFFSET = -4095   // Minimum memory offset for load/store operations
  
  // Bit manipulation
  val BYTE_MASK = 0xffffff00      // Mask to clear all bits except lowest 8 (for exit codes)
  
  // Pair offsets
  val PAIR_FST_OFFSET = 0         // Offset to first element of pair
  val PAIR_SND_OFFSET = 4         // Offset to second element of pair
  
  // Boolean values
  val BOOL_TRUE = 1               // Integer representation of true
  val BOOL_FALSE = 0              // Integer representation of false
  
  // Scanf return values
  val SCANF_SUCCESS = 1           // Return value for successful scanf read
  
  // Stack spacing for local variables
  val LOCAL_VAR_STACK_SPACE = 8   // Space allocated on stack for local variables (bytes)
  val LOCAL_VAR_VALUE_OFFSET = 4  // Offset for value in local var stack allocation
  
  // Literal pool defaults
  val DEFAULT_ALIGNMENT = 4       // Default alignment for data section
  
  // String and character formatting
  val UNICODE_HEX_PADDING = 4     // Padding length for Unicode hex representation
  
  // Character values
  val NULL_CHAR = '\u0000'        // Null character (ASCII 0)
}

