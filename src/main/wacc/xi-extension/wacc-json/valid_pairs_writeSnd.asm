.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	mov w0, #16
	bl _malloc
	mov x16, x0
	mov w8, #10
	str x8, [x16]
	mov w8, #97
	str x8, [x16, #8]
	mov x19, x16
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19, #8]
	mov w0, w20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	cmp x19, #0
	b.eq _errNull
	mov w8, #90
	str x8, [x19, #8]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19, #8]
	mov w0, w20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	mov x0, #0
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

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

