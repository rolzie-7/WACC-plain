// length of .L.str0
	.word 4
.L.str0:
	.asciz " is "
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	mov w19, #97
	mov w20, #99
	mov w0, w19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	mov w0, w20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w8, w20
	tst w8, #0xffffff80
	csel x1, x8, x1, ne // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.ne _errBadChar
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	mov x0, #0
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
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

