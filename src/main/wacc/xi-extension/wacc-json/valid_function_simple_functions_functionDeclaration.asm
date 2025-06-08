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

wacc_f:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

