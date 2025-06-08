// ARM64 Assembly Test File
// Contains various instruction formats and addressing modes

.global _start
.section .text

// Program entry point
_start:
    // Set up stack frame
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Immediate operations
    mov x0, #42
    movk x0, #0xabcd, lsl #16
    
    // Register operations
    add x1, x0, x0
    sub x2, x1, x0
    mul x3, x1, x2
    
    // Memory operations with different addressing modes
    // Pre-indexed
    str x0, [sp, #-16]!
    // Post-indexed
    ldr x4, [sp], #16
    // Register offset
    str x1, [x29, x0]
    // Extended register
    ldr x5, [x29, w1, sxtw]
    
    // Branch operations
    cbz x0, skip_section
    cbnz x0, continue
    
skip_section:
    // Logical operations
    and x6, x0, x1
    orr x7, x2, x3
    eor x8, x4, x5
    
continue:
    // Load/store with shifted register
    str x9, [x0, x1, lsl #3]
    
    // Bit manipulation
    rev x10, x0
    clz x11, x1
    
    // Floating point
    fmov d0, #1.0
    fadd d1, d0, d0
    
    // System registers
    mrs x12, nzcv
    msr nzcv, x12
    
    // Vector operations
    dup v0.4s, w0
    
    // Conditional execution
    cmp x0, #42
    b.eq equal_branch
    b.ne not_equal_branch
    
equal_branch:
    // Function call
    bl function_example
    
not_equal_branch:
    // Exit program
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret

// Example function
function_example:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Function body
    mov x0, #100
    
    ldp x29, x30, [sp], #16
    ret

.section .data
// Data section
number: .word 42
message: .ascii "Hello, ARM64!\n"
alignment: .align 4 