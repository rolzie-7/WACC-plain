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
	// 3 element array
	mov w0, #16
	bl _malloc
	mov x16, x0
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #3
	stur w8, [x16, #-4]
	mov w8, #2
	str w8, [x16]
	mov w8, #0
	str w8, [x16, #4]
	mov w8, #1
	str w8, [x16, #8]
	mov x19, x16
	// 3 element array
	mov w0, #16
	bl _malloc
	mov x16, x0
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #3
	stur w8, [x16, #-4]
	mov w8, #1
	str w8, [x16]
	mov w8, #2
	str w8, [x16, #4]
	mov w8, #0
	str w8, [x16, #8]
	mov x20, x16
	// 3 element array
	mov w0, #16
	bl _malloc
	mov x16, x0
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #3
	stur w8, [x16, #-4]
	mov w8, #5
	str w8, [x16]
	mov w8, #6
	str w8, [x16, #4]
	mov w8, #7
	str w8, [x16, #8]
	mov x21, x16
	mov w22, #0
	b .L0
.L1:
	mov w17, w22
	mov x7, x20
	bl _arrLoad4
	mov w17, w7
	mov x7, x19
	bl _arrLoad4
	mov w17, w7
	mov x7, x21
	bl _arrLoad4
	mov w8, w7
	adds w8, w8, #1
	b.vs _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	mov w17, w22
	mov x7, x20
	bl _arrLoad4
	mov w17, w7
	mov x7, x19
	bl _arrLoad4
	mov w17, w7
	// pop {x8}
	ldp x8, xzr, [sp], #16
	mov x7, x21
	bl _arrStore4
	mov w17, w22
	mov x7, x20
	bl _arrLoad4
	mov w17, w7
	mov x7, x19
	bl _arrLoad4
	mov w17, w7
	mov x7, x21
	bl _arrLoad4
	mov w0, w7
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	adds w22, w22, #1
	b.vs _errOverflow
.L0:
	cmp w22, #3
	b.ne .L1
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

_malloc:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	bl malloc
	cbz x0, _errOutOfMemory
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

_arrLoad4:
	// Special calling convention: array ptr passed in X7, index in X17, LR (W30) is used as general register, and return into X7
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	cmp w17, #0
	csel x1, x17, x1, lt // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.lt _errOutOfBounds
	ldur w30, [x7, #-4]
	cmp w17, w30
	csel x1, x17, x1, ge // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.ge _errOutOfBounds
	ldr w7, [x7, x17, lsl #2]
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

_arrStore4:
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
	str w8, [x7, x17, lsl #2]
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

