.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	mov w19, #1
	mov w20, #0
	cmp w19, #1
	cset w8, ne
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	bl _println
	cmp w20, #1
	cset w8, ne
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	bl _println
	mov x0, #0
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
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

