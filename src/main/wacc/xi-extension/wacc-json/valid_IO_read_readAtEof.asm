.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	mov w19, #90
	// load the current value in the destination of the read so it supports defaults
	mov w0, w19
	bl _readc
	mov w19, w0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	mov w20, #90
	// load the current value in the destination of the read so it supports defaults
	mov w0, w20
	bl _readc
	mov w20, w0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	mov x0, #0
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

// length of .L._printc_str0
	.word 2
.L._printc_str0:
	.asciz "%c"
.align 4
_printc:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	mov x1, x0
	adr x0, .L._printc_str0
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

// length of .L._readc_str0
	.word 3
.L._readc_str0:
	.asciz " %c"
.align 4
_readc:
	// X0 contains the "original" value of the destination of the read
	// allocate space on the stack to store the read: preserve alignment!
	// the passed default argument should be stored in case of EOF
	// aarch64 mandates 16-byte SP alignment at all times, might as well merge the stores
	// push {x0, lr}
	stp x0, lr, [sp, #-16]!
	mov x1, sp
	adr x0, .L._readc_str0
	bl scanf
	// pop {x0, lr}
	ldp x0, lr, [sp], #16
	ret

