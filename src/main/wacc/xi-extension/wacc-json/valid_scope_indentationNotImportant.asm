.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	b .L0
.L1:
.L0:
	mov w8, #0
	cmp w8, #1
	b.eq .L1
	mov x0, #0
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

