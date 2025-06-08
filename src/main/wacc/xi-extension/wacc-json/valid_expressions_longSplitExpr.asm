.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25, x26, x27}
	stp x19, x20, [sp, #-80]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	stur x27, [sp, #64]
	mov fp, sp
	mov w8, #1
	adds w19, w8, #2
	b.vs _errOverflow
	mov w8, #3
	adds w20, w8, #4
	b.vs _errOverflow
	mov w8, #5
	adds w21, w8, #6
	b.vs _errOverflow
	mov w8, #7
	adds w22, w8, #8
	b.vs _errOverflow
	mov w8, #9
	adds w23, w8, #10
	b.vs _errOverflow
	mov w8, #11
	adds w24, w8, #12
	b.vs _errOverflow
	mov w8, #13
	adds w25, w8, #14
	b.vs _errOverflow
	mov w8, #15
	adds w26, w8, #16
	b.vs _errOverflow
	mov w27, #17
	adds w8, w19, w20
	b.vs _errOverflow
	adds w8, w8, w21
	b.vs _errOverflow
	adds w8, w8, w22
	b.vs _errOverflow
	adds w8, w8, w23
	b.vs _errOverflow
	adds w8, w8, w24
	b.vs _errOverflow
	adds w8, w8, w25
	b.vs _errOverflow
	adds w8, w8, w26
	b.vs _errOverflow
	adds w0, w8, w27
	b.vs _errOverflow
	// statement primitives do not return results (but will clobber r0/rax)
	bl exit
	mov x0, #0
	// pop {x19, x20, x21, x22, x23, x24, x25, x26, x27}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldur x27, [sp, #64]
	ldp x19, x20, [sp], #80
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

