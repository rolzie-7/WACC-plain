.data
// length of .L.str0
	.word 12
.L.str0:
	.asciz "Hello World!"
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov x0, #0
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

// length of .L._prints_str0
	.word 4
.L._prints_str0:
	.asciz "%.*s"
.align 4
_prints:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	mov x2, x0
	ldur w1, [x0, #-4]
	adr x0, .L._prints_str0
	bl printf
	mov x0, #0
	bl fflush
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

// Sample function with more complex instructions
sample_function:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	
	// Load/store examples
	ldr x0, [x1]
	ldr x2, [x3, #16]
	ldr x4, [x5, #32]!
	ldr x6, [x7], #48
	str x8, [x9]
	str x10, [x11, #64]
	str x12, [x13, #80]!
	str x14, [x15], #96
	
	// Arithmetic examples
	add x16, x17, x18
	add x19, x20, #100
	sub x21, x22, x23
	sub x24, x25, #200
	mul x26, x27, x28
	div x29, x30, x0
	
	// Shifted operands
	add x1, x2, x3, lsl #2
	sub x4, x5, x6, lsr #3
	and x7, x8, x9, asr #4
	orr x10, x11, x12, ror #5
	
	// Extended operands
	add x13, x14, w15, uxtb
	sub x16, x17, w18, uxth
	add x19, x20, w21, uxtw
	sub x22, x23, w24, sxtb
	
	// Conditional execution
	cmp x25, x26
	b.eq .L_equal
	b.ne .L_not_equal
	b.lt .L_less_than
	b.gt .L_greater_than
	
.L_equal:
	mov x0, #1
	b .L_exit
	
.L_not_equal:
	mov x0, #2
	b .L_exit
	
.L_less_than:
	mov x0, #3
	b .L_exit
	
.L_greater_than:
	mov x0, #4
	
.L_exit:
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret 