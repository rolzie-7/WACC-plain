.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	mov w8, #1
	adds w8, w8, #2
	b.vs _errOverflow
	adds w8, w8, #3
	b.vs _errOverflow
	adds w8, w8, #4
	b.vs _errOverflow
	adds w8, w8, #5
	b.vs _errOverflow
	adds w8, w8, #6
	b.vs _errOverflow
	adds w8, w8, #7
	b.vs _errOverflow
	adds w8, w8, #8
	b.vs _errOverflow
	adds w8, w8, #9
	b.vs _errOverflow
	adds w8, w8, #10
	b.vs _errOverflow
	adds w8, w8, #11
	b.vs _errOverflow
	adds w8, w8, #12
	b.vs _errOverflow
	adds w8, w8, #13
	b.vs _errOverflow
	adds w8, w8, #14
	b.vs _errOverflow
	adds w8, w8, #15
	b.vs _errOverflow
	adds w8, w8, #16
	b.vs _errOverflow
	adds w19, w8, #17
	b.vs _errOverflow
	mov w8, #-1
	subs w8, w8, #2
	b.vs _errOverflow
	subs w8, w8, #3
	b.vs _errOverflow
	subs w8, w8, #4
	b.vs _errOverflow
	subs w8, w8, #5
	b.vs _errOverflow
	subs w8, w8, #6
	b.vs _errOverflow
	subs w8, w8, #7
	b.vs _errOverflow
	subs w8, w8, #8
	b.vs _errOverflow
	subs w8, w8, #9
	b.vs _errOverflow
	subs w8, w8, #10
	b.vs _errOverflow
	subs w8, w8, #11
	b.vs _errOverflow
	subs w8, w8, #12
	b.vs _errOverflow
	subs w8, w8, #13
	b.vs _errOverflow
	subs w8, w8, #14
	b.vs _errOverflow
	subs w8, w8, #15
	b.vs _errOverflow
	subs w8, w8, #16
	b.vs _errOverflow
	subs w20, w8, #17
	b.vs _errOverflow
	mov w9, #2
	mov w8, #1
	smull x8, w8, w9
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	mov w9, #3
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
	mov w9, #4
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
	mov w9, #5
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
	mov w9, #6
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
	mov w9, #7
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
	mov w9, #8
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
	mov w9, #9
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
	mov w9, #10
	// pop {x8}
	ldp x8, xzr, [sp], #16
	smull x8, w8, w9
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	mov w21, w8
	mov w22, #10
	adds w8, w19, w20
	b.vs _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	cmp w22, #0
	b.eq _errDivZero
	sdiv w9, w21, w22
	// pop {x8}
	ldp x8, xzr, [sp], #16
	adds w0, w8, w9
	b.vs _errOverflow
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	adds w8, w19, w20
	b.vs _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	cmp w22, #0
	b.eq _errDivZero
	sdiv w9, w21, w22
	// pop {x8}
	ldp x8, xzr, [sp], #16
	adds w8, w8, w9
	b.vs _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	mov w9, #256
	cmp w9, #0
	b.eq _errDivZero
	// pop {x8}
	ldp x8, xzr, [sp], #16
	sdiv w17, w8, w9
	msub w0, w17, w9, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	adds w8, w19, w20
	b.vs _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	cmp w22, #0
	b.eq _errDivZero
	sdiv w9, w21, w22
	// pop {x8}
	ldp x8, xzr, [sp], #16
	adds w0, w8, w9
	b.vs _errOverflow
	// statement primitives do not return results (but will clobber r0/rax)
	bl exit
	mov x0, #0
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

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

