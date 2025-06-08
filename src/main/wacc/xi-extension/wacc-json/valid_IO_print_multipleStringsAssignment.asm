// length of .L.str0
	.word 2
.L.str0:
	.asciz "Hi"
// length of .L.str1
	.word 5
.L.str1:
	.asciz "Hello"
// length of .L.str2
	.word 6
.L.str2:
	.asciz "s1 is "
// length of .L.str3
	.word 6
.L.str3:
	.asciz "s2 is "
// length of .L.str4
	.word 29
.L.str4:
	.asciz "They are not the same string."
// length of .L.str5
	.word 25
.L.str5:
	.asciz "They are the same string."
// length of .L.str6
	.word 16
.L.str6:
	.asciz "Now make s1 = s2"
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	adrp x19, .L.str0
	add x19, x19, :lo12:.L.str0
	adrp x20, .L.str1
	add x20, x20, :lo12:.L.str1
	adrp x0, .L.str2
	add x0, x0, :lo12:.L.str2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str3
	add x0, x0, :lo12:.L.str3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov x0, x20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	cmp x19, x20
	b.eq .L0
	adrp x0, .L.str4
	add x0, x0, :lo12:.L.str4
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	b .L1
.L0:
	adrp x0, .L.str5
	add x0, x0, :lo12:.L.str5
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
.L1:
	adrp x0, .L.str6
	add x0, x0, :lo12:.L.str6
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov x19, x20
	adrp x0, .L.str2
	add x0, x0, :lo12:.L.str2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str3
	add x0, x0, :lo12:.L.str3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov x0, x20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	cmp x19, x20
	b.eq .L2
	adrp x0, .L.str4
	add x0, x0, :lo12:.L.str4
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	b .L3
.L2:
	adrp x0, .L.str5
	add x0, x0, :lo12:.L.str5
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
.L3:
	mov x0, #0
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
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

