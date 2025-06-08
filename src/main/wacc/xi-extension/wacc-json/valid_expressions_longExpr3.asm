.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w8, #1
	subs w8, w8, #2
	b.vs _errOverflow
	adds w8, w8, #3
	b.vs _errOverflow
	subs w8, w8, #4
	b.vs _errOverflow
	adds w8, w8, #5
	b.vs _errOverflow
	subs w8, w8, #6
	b.vs _errOverflow
	adds w8, w8, #7
	b.vs _errOverflow
	subs w8, w8, #8
	b.vs _errOverflow
	adds w8, w8, #9
	b.vs _errOverflow
	subs w8, w8, #10
	b.vs _errOverflow
	adds w8, w8, #11
	b.vs _errOverflow
	subs w8, w8, #12
	b.vs _errOverflow
	adds w8, w8, #13
	b.vs _errOverflow
	subs w8, w8, #14
	b.vs _errOverflow
	adds w8, w8, #15
	b.vs _errOverflow
	subs w8, w8, #16
	b.vs _errOverflow
	adds w19, w8, #17
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

