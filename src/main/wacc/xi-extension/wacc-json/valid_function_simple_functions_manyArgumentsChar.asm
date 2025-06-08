.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	mov w0, #0
	mov w1, #0
	mov w2, #3
	mov w3, #5
	mov w4, #1
	mov w5, #3
	mov w6, #97
	mov w7, #1
	bl wacc_f
	mov w19, w0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	mov w0, #0
	mov w1, #0
	mov w2, #3
	mov w3, #5
	mov w4, #1
	mov w5, #3
	mov w6, #98
	mov w7, #0
	bl wacc_f
	mov w20, w0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	mov x0, #0
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_f:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	adds w19, w2, w3
	b.vs _errOverflow
	adds w20, w4, w5
	b.vs _errOverflow
	cmp w7, #1
	b.eq .L0
	mov w0, w6
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L1
.L0:
	mov w8, w6
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	smull x8, w19, w20
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	mov w9, w8
	// pop {x8}
	ldp x8, xzr, [sp], #16
	subs w8, w8, w9
	b.vs _errOverflow
	tst w8, #0xffffff80
	csel x1, x8, x1, ne // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.ne _errBadChar
	mov w0, w8
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L1:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

// length of .L._printc_str0
	.word 2
.L._printc_str0:
	.asciz "%c"
.align 4
_printc:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	mov x1, x0
	adr x0, .L._printc_str0
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

// length of .L._errBadChar_str0
	.word 50
.L._errBadChar_str0:
	.asciz "fatal error: int %d is not ascii character 0-127 \n"
.align 4
_errBadChar:
	adr x0, .L._errBadChar_str0
	bl printf
	mov x0, #0
	bl fflush
	mov w0, #-1
	bl exit

