// length of .L.str0
	.word 5
.L.str0:
	.asciz "Wrong"
// length of .L.str1
	.word 7
.L.str1:
	.asciz "Correct"
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w9, #1
	mov w8, #10
	smull x8, w8, w9
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	mov w9, #15
	mov w8, #2
	smull x8, w8, w9
	// sign-extend the first 32-bits of the result to be 64-bit again
	// and compare this against the original 64-bit result
	cmp x8, w8, sxtw
	// if they are not equal then overflow occured
	b.ne _errOverflow
	mov w9, w8
	// pop {x8}
	ldp x8, xzr, [sp], #16
	adds w19, w8, w9
	b.vs _errOverflow
	cmp w19, #40
	b.eq .L0
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	b .L1
.L0:
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
.L1:
	mov x0, #0
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
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

