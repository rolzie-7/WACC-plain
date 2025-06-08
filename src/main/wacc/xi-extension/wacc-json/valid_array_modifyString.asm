.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// 12 element array
	mov w0, #16
	bl _malloc
	mov x16, x0
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #12
	stur w8, [x16, #-4]
	mov w8, #104
	strb w8, [x16]
	mov w8, #101
	strb w8, [x16, #1]
	mov w8, #108
	strb w8, [x16, #2]
	mov w8, #108
	strb w8, [x16, #3]
	mov w8, #111
	strb w8, [x16, #4]
	mov w8, #32
	strb w8, [x16, #5]
	mov w8, #119
	strb w8, [x16, #6]
	mov w8, #111
	strb w8, [x16, #7]
	mov w8, #114
	strb w8, [x16, #8]
	mov w8, #108
	strb w8, [x16, #9]
	mov w8, #100
	strb w8, [x16, #10]
	mov w8, #33
	strb w8, [x16, #11]
	mov x19, x16
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov w17, #0
	mov w8, #72
	mov x7, x19
	bl _arrStore1
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// 3 element array
	mov w0, #7
	bl _malloc
	mov x16, x0
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #3
	stur w8, [x16, #-4]
	mov w8, #72
	strb w8, [x16]
	mov w8, #105
	strb w8, [x16, #1]
	mov w8, #33
	strb w8, [x16, #2]
	mov x19, x16
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
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

_malloc:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	bl malloc
	cbz x0, _errOutOfMemory
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

_arrStore1:
	// Special calling convention: array ptr passed in X7, index in X17, value to store in X8, LR (W30) is used as general register
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	cmp w17, #0
	csel x1, x17, x1, lt // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.lt _errOutOfBounds
	ldur w30, [x7, #-4]
	cmp w17, w30
	csel x1, x17, x1, ge // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.ge _errOutOfBounds
	strb w8, [x7, x17]
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

// length of .L._errOutOfBounds_str0
	.word 42
.L._errOutOfBounds_str0:
	.asciz "fatal error: array index %d out of bounds\n"
.align 4
_errOutOfBounds:
	adr x0, .L._errOutOfBounds_str0
	bl printf
	mov x0, #0
	bl fflush
	mov w0, #-1
	bl exit

// length of .L._errOutOfMemory_str0
	.word 27
.L._errOutOfMemory_str0:
	.asciz "fatal error: out of memory\n"
.align 4
_errOutOfMemory:
	adr x0, .L._errOutOfMemory_str0
	bl _prints
	mov w0, #-1
	bl exit

