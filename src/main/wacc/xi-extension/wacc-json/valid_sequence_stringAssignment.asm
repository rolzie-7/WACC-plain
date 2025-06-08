// length of .L.str0
	.word 3
.L.str0:
	.asciz "foo"
// length of .L.str1
	.word 3
.L.str1:
	.asciz "bar"
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	adrp x19, .L.str0
	add x19, x19, :lo12:.L.str0
	adrp x19, .L.str1
	add x19, x19, :lo12:.L.str1
	mov x0, #0
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

