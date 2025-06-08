// length of .L.str0
	.word 24
.L.str0:
	.asciz "Using fixed-point real: "
// length of .L.str1
	.word 3
.L.str1:
	.asciz " / "
// length of .L.str2
	.word 3
.L.str2:
	.asciz " * "
// length of .L.str3
	.word 3
.L.str3:
	.asciz " = "
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
	mov w19, #10
	mov w20, #3
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	adrp x0, .L.str2
	add x0, x0, :lo12:.L.str2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	adrp x0, .L.str3
	add x0, x0, :lo12:.L.str3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w19
	bl wacc_intToFixedPoint
	mov w21, w0
	mov w1, w20
	bl wacc_divideByInt
	mov w21, w0
	mov w1, w20
	bl wacc_multiplyByInt
	mov w21, w0
	bl wacc_fixedPointToIntRoundNear
	mov w22, w0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	mov x0, #0
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_q:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	mov w0, #14
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_power:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w19, #1
	b .L0
.L1:
	smull x8, w19, w0
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	mov w19, w8
	subs w1, w1, #1
	b.vs _errOverflow
.L0:
	cmp w1, #0
	b.gt .L1
	mov w0, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_f:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	bl wacc_q
	mov w19, w0
	mov w0, #2
	mov w1, w19
	bl wacc_power
	mov w20, w0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_intToFixedPoint:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_f
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	smull x8, w0, w19
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	mov w0, w8
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_fixedPointToIntRoundDown:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_f
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	cmp w19, #0
	b.eq _errDivZero
	sdiv w0, w0, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_fixedPointToIntRoundNear:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_f
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	cmp w0, #0
	b.ge .L2
	mov w9, #2
	cmp w9, #0
	b.eq _errDivZero
	sdiv w9, w19, w9
	subs w8, w0, w9
	b.vs _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	cmp w19, #0
	b.eq _errDivZero
	// pop {x8}
	ldp x8, xzr, [sp], #16
	sdiv w0, w8, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L3
.L2:
	mov w9, #2
	cmp w9, #0
	b.eq _errDivZero
	sdiv w9, w19, w9
	adds w8, w0, w9
	b.vs _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	cmp w19, #0
	b.eq _errDivZero
	// pop {x8}
	ldp x8, xzr, [sp], #16
	sdiv w0, w8, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L3:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_add:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	adds w0, w0, w1
	b.vs _errOverflow
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_subtract:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	subs w0, w0, w1
	b.vs _errOverflow
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_addByInt:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_f
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w19, w16
	smull x8, w1, w19
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	mov w9, w8
	adds w0, w0, w9
	b.vs _errOverflow
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_subtractByInt:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_f
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w19, w16
	smull x8, w1, w19
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	mov w9, w8
	subs w0, w0, w9
	b.vs _errOverflow
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_multiply:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_f
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w19, w16
	smull x8, w0, w1
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	cmp w19, #0
	b.eq _errDivZero
	// pop {x8}
	ldp x8, xzr, [sp], #16
	sdiv w0, w8, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_multiplyByInt:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	smull x8, w0, w1
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	mov w0, w8
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_divide:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_f
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w19, w16
	smull x8, w0, w19
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	cmp w1, #0
	b.eq _errDivZero
	// pop {x8}
	ldp x8, xzr, [sp], #16
	sdiv w0, w8, w1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_divideByInt:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	cmp w1, #0
	b.eq _errDivZero
	sdiv w0, w0, w1
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

// length of .L._errDivZero_str0
	.word 40
.L._errDivZero_str0:
	.asciz "fatal error: division or modulo by zero\n"
.align 4
_errDivZero:
	adr x0, .L._errDivZero_str0
	bl _prints
	mov w0, #-1
	bl exit

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

