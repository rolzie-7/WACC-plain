.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w0, #4
	mov w1, #8
	bl wacc_f
	mov w19, w0
	mov x0, #0
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_f:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adds w0, w0, w1
	b.vs _errOverflow
	ldr x8, [x16]
	subs w1, w8, w1
	b.vs _errOverflow
	ldr x9, [x16, #8]
	ldr x8, [x16]
	smull x8, w8, w9
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	mov w2, w8
	bl wacc_g
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w19, w16
	mov w0, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_g:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	# pop/peek {x0, x1, x2}
	ldp x0, x1, [sp]
	ldur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	# pop/peek {x0, x1, x2}
	ldp x0, x1, [sp]
	ldur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
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

// length of .L._errOverflow_str0
	.word 52
.L._errOverflow_str0:
	.asciz "fatal error: integer overflow or underflow occurred\n"
.align 4
_errOverflow:
	adr x0, .L._errOverflow_str0
	bl _prints
	mov w0, #-1
	bl exit

