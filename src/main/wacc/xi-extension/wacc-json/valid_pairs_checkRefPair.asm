.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	mov fp, sp
	mov w0, #16
	bl _malloc
	mov x16, x0
	mov w8, #10
	str x8, [x16]
	mov w8, #97
	str x8, [x16, #8]
	mov x19, x16
	mov x20, x19
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printp
	bl _println
	mov x0, x20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printp
	bl _println
	cmp x19, x20
	cset w8, eq
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	bl _println
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19]
	cmp x20, #0
	b.eq _errNull
	ldr x22, [x20]
	mov w0, w21
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	mov w0, w22
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	cmp w21, w22
	cset w8, eq
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	bl _println
	cmp x19, #0
	b.eq _errNull
	ldr x23, [x19, #8]
	cmp x20, #0
	b.eq _errNull
	ldr x24, [x20, #8]
	mov w0, w23
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	mov w0, w24
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	cmp w23, w24
	cset w8, eq
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	bl _println
	mov x0, #0
	// pop {x19, x20, x21, x22, x23, x24}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x19, x20, [sp], #48
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

// length of .L._printb_str0
	.word 5
.L._printb_str0:
	.asciz "false"
// length of .L._printb_str1
	.word 4
.L._printb_str1:
	.asciz "true"
// length of .L._printb_str2
	.word 4
.L._printb_str2:
	.asciz "%.*s"
.align 4
_printb:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	cmp w0, #0
	b.ne .L_printb0
	adr x2, .L._printb_str0
	b .L_printb1
.L_printb0:
	adr x2, .L._printb_str1
.L_printb1:
	ldur w1, [x2, #-4]
	adr x0, .L._printb_str2
	bl printf
	mov x0, #0
	bl fflush
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

// length of .L._printp_str0
	.word 2
.L._printp_str0:
	.asciz "%p"
.align 4
_printp:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	mov x1, x0
	adr x0, .L._printp_str0
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

