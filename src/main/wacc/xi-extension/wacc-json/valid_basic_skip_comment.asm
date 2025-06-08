.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	mov x0, #0
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

