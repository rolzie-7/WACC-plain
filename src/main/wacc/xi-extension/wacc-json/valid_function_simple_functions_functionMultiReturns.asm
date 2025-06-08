// length of .L.str0
	.word 29
.L.str0:
	.asciz "How on Earth did we get here?"
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	bl wacc_returnInWhile
	mov w19, w0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	mov x0, #0
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_returnInWhile:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	b .L0
.L1:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
.L0:
	mov w8, #1
	cmp w8, #1
	b.eq .L1
	mov w0, #2
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

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

