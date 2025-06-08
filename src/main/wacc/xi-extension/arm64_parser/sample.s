// Sample ARM64 assembly program
.global _start      // Global start symbol

.text               // Start of code section
_start:
    // Setup stack frame
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Example calculation
    mov x0, #42     // Load immediate value
    add x0, x0, #10 // Add 10
    
    // Call a function
    bl print_result
    
    // Clean up and exit
    mov x0, #0      // Exit code 0
    ldp x29, x30, [sp], #16
    ret

print_result:
    // Function prologue
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Save x0 temporarily
    str x0, [sp, #-16]!
    
    // Print the result (this is pseudo-code)
    // In a real program, you would call syscalls here
    
    // Restore x0
    ldr x0, [sp], #16
    
    // Function epilogue
    ldp x29, x30, [sp], #16
    ret
