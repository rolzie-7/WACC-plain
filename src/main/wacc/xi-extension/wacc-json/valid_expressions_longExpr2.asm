.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w8, #2
	adds w8, w8, #3
	b.vs _errOverflow
	adds w8, w8, #2
	b.vs _errOverflow
	adds w8, w8, #1
	b.vs _errOverflow
	adds w8, w8, #1
	b.vs _errOverflow
	adds w8, w8, #1
	b.vs _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	mov w8, #1
	adds w8, w8, #2
	b.vs _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	mov w9, #6
	cmp w9, #0
	b.eq _errDivZero
	mov w8, #4
	sdiv w9, w8, w9
	mov w8, #3
	subs w9, w8, w9
	b.vs _errOverflow
	// pop {x8}
	ldp x8, xzr, [sp], #16
	smull x8, w8, w9
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	mov w8, #18
	subs w9, w8, #17
	b.vs _errOverflow
	mov w8, #2
	smull x8, w8, w9
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	mov w9, #4
	mov w8, #3
	smull x8, w8, w9
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	mov w9, #4
	cmp w9, #0
	b.eq _errDivZero
	// pop {x8}
	ldp x8, xzr, [sp], #16
	sdiv w8, w8, w9
	adds w9, w8, #6
	b.vs _errOverflow
	// pop {x8}
	ldp x8, xzr, [sp], #16
	adds w9, w8, w9
	b.vs _errOverflow
	cmp w9, #0
	b.eq _errDivZero
	// pop {x8}
	ldp x8, xzr, [sp], #16
	sdiv w9, w8, w9
	// pop {x8}
	ldp x8, xzr, [sp], #16
	subs w19, w8, w9
	b.vs _errOverflow
	mov w0, w19
	// statement primitives do not return results (but will clobber r0/rax)
	bl exit
	mov x0, #0
	// pop {x19}
	ldp x19, xzr, [sp], #16
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

// length of .L._errDivZero_str0
	.word 40
.L._errDivZero_str0:
	.asciz "fatal error: division or modulo by zero\n"
.align 4
_errDivZero:
	adr x0, .L._errDivZero_str0
	bl _prints
	mov w0, #-1
	bl exit

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

