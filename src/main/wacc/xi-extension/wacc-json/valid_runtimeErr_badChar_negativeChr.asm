.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w8, #-1
	tst w8, #0xffffff80
	csel x1, x8, x1, ne // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.ne _errBadChar
	mov w19, w8
	mov x0, #0
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
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

