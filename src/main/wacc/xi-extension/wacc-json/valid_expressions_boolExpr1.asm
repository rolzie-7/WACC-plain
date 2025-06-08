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
	mov w8, #1
	cmp w8, #1
	b.ne .L0
	mov w8, #0
	cmp w8, #1
.L0:
	cset w8, eq
	cmp w8, #1
	b.eq .L1
	mov w8, #1
	cmp w8, #1
	b.ne .L2
	mov w8, #0
	cmp w8, #1
.L2:
	cset w8, eq
	cmp w8, #1
.L1:
	cset w8, ne
	mov w19, w8
	cmp w19, #1
	b.eq .L3
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	b .L4
.L3:
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
.L4:
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

