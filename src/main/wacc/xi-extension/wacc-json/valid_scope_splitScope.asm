.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	mov w19, #1
	mov w19, #3
	mov w21, #1
	mov w20, #2
	mov w0, w19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	mov w0, w20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	mov x0, #0
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
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

