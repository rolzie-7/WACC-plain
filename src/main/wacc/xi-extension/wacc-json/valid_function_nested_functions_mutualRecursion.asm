// length of .L.str0
	.word 12
.L.str0:
	.asciz "r1: sending "
// length of .L.str1
	.word 13
.L.str1:
	.asciz "r2: received "
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w19, #0
	mov w0, #8
	bl wacc_r1
	mov w19, w0
	mov x0, #0
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_r1:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	cmp w0, #0
	b.eq .L0
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_r2
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	b .L1
.L0:
.L1:
	mov w0, #42
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_r2:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	subs w0, w0, #1
	b.vs _errOverflow
	bl wacc_r1
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	mov w0, #44
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
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

