.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w0, #1
	mov w1, #2
	mov w2, #3
	mov w3, #4
	mov w4, #5
	mov w5, #6
	bl wacc_f
	mov w19, w0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	mov x0, #0
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_f:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25, x26, x27, x28}
	stp x19, x20, [sp, #-80]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	stp x27, x28, [sp, #64]
	mov fp, sp
	mov w19, #1
	mov w20, #2
	mov w21, #3
	mov w22, #4
	mov w23, #53
	mov w24, #54
	mov w25, #55
	mov w26, #8
	mov w27, #97
	mov w28, #98
	mov w6, #5
	// push {x0, x1, x2, x3, x4, x5, x6}
	stp x0, x1, [sp, #-64]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stur x6, [sp, #48]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w6
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	// pop {x0, x1, x2, x3, x4, x5, x6}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldur x6, [sp, #48]
	ldp x0, x1, [sp], #64
	mov w0, w26
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24, x25, x26, x27, x28}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldp x27, x28, [sp, #64]
	ldp x19, x20, [sp], #80
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

// length of .L._printi_str0
	.word 2
.L._printi_str0:
	.asciz "%d"
.align 4
_printi:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	mov x1, x0
	adr x0, .L._printi_str0
	bl printf
	mov x0, #0
	bl fflush
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

// length of .L._println_str0
	.word 0
.L._println_str0:
	.asciz ""
.align 4
_println:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	adr x0, .L._println_str0
	bl puts
	mov x0, #0
	bl fflush
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

