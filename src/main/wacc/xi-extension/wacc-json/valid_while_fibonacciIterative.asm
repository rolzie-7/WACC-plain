// length of .L.str0
	.word 35
.L.str0:
	.asciz "The first 20 fibonacci numbers are:"
// length of .L.str1
	.word 2
.L.str1:
	.asciz ", "
// length of .L.str2
	.word 3
.L.str2:
	.asciz "..."
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
	mov w19, #0
	mov w20, #0
	mov w21, #1
	mov w22, #0
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	b .L0
.L1:
	mov w0, w20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w22, w20
	mov w20, w21
	adds w21, w22, w21
	b.vs _errOverflow
	adds w19, w19, #1
	b.vs _errOverflow
.L0:
	cmp w19, #20
	b.lt .L1
	adrp x0, .L.str2
	add x0, x0, :lo12:.L.str2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
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

