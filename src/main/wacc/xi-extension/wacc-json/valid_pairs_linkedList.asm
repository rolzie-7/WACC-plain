// length of .L.str0
	.word 8
.L.str0:
	.asciz "list = {"
// length of .L.str1
	.word 2
.L.str1:
	.asciz ", "
// length of .L.str2
	.word 1
.L.str2:
	.asciz "}"
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25}
	stp x19, x20, [sp, #-64]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stur x25, [sp, #48]
	mov fp, sp
	mov w0, #16
	bl _malloc
	mov x16, x0
	mov w8, #11
	str x8, [x16]
	mov x8, #0
	str x8, [x16, #8]
	mov x19, x16
	mov w0, #16
	bl _malloc
	mov x16, x0
	mov w8, #4
	str x8, [x16]
	str x19, [x16, #8]
	mov x20, x16
	mov w0, #16
	bl _malloc
	mov x16, x0
	mov w8, #2
	str x8, [x16]
	str x20, [x16, #8]
	mov x21, x16
	mov w0, #16
	bl _malloc
	mov x16, x0
	mov w8, #1
	str x8, [x16]
	str x21, [x16, #8]
	mov x22, x16
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov x23, x22
	cmp x23, #0
	b.eq _errNull
	ldr x24, [x23, #8]
	mov w25, #0
	b .L0
.L1:
	cmp x23, #0
	b.eq _errNull
	ldr x25, [x23]
	mov w0, w25
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov x23, x24
	cmp x23, #0
	b.eq _errNull
	ldr x24, [x23, #8]
.L0:
	cmp x24, #0
	b.ne .L1
	cmp x23, #0
	b.eq _errNull
	ldr x25, [x23]
	mov w0, w25
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	adrp x0, .L.str2
	add x0, x0, :lo12:.L.str2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov x0, #0
	// pop {x19, x20, x21, x22, x23, x24, x25}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldur x25, [sp, #48]
	ldp x19, x20, [sp], #64
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

// length of .L._errNull_str0
	.word 45
.L._errNull_str0:
	.asciz "fatal error: null pair dereferenced or freed\n"
.align 4
_errNull:
	adr x0, .L._errNull_str0
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

