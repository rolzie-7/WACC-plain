// length of .L.str0
	.word 5
.L.str0:
	.asciz "a is "
// length of .L.str1
	.word 5
.L.str1:
	.asciz "b is "
// length of .L.str2
	.word 5
.L.str2:
	.asciz "c is "
// length of .L.str3
	.word 5
.L.str3:
	.asciz "d is "
// length of .L.str4
	.word 5
.L.str4:
	.asciz "e is "
// length of .L.str5
	.word 5
.L.str5:
	.asciz "f is "
// length of .L.str6
	.word 5
.L.str6:
	.asciz "hello"
// length of .L.str7
	.word 10
.L.str7:
	.asciz "answer is "
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	// 2 element array
	mov w0, #6
	bl _malloc
	mov x16, x0
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #2
	stur w8, [x16, #-4]
	mov w8, #0
	strb w8, [x16]
	mov w8, #1
	strb w8, [x16, #1]
	mov x19, x16
	// 2 element array
	mov w0, #12
	bl _malloc
	mov x16, x0
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #2
	stur w8, [x16, #-4]
	mov w8, #1
	str w8, [x16]
	mov w8, #2
	str w8, [x16, #4]
	mov x20, x16
	mov w0, #42
	mov w1, #1
	mov w2, #117
	adrp x3, .L.str6
	add x3, x3, :lo12:.L.str6
	mov x4, x19
	mov x5, x20
	bl wacc_doSomething
	mov w21, w0
	adrp x0, .L.str7
	add x0, x0, :lo12:.L.str7
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w21
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	mov x0, #0
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_doSomething:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	// push {x0, x1, x2, x3, x4, x5}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str2
	add x0, x0, :lo12:.L.str2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str3
	add x0, x0, :lo12:.L.str3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str4
	add x0, x0, :lo12:.L.str4
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x4
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printp
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str5
	add x0, x0, :lo12:.L.str5
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x5
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printp
	bl _println
	// pop {x0, x1, x2, x3, x4, x5}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w0, #103
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

// length of .L._printb_str0
	.word 5
.L._printb_str0:
	.asciz "false"
// length of .L._printb_str1
	.word 4
.L._printb_str1:
	.asciz "true"
// length of .L._printb_str2
	.word 4
.L._printb_str2:
	.asciz "%.*s"
.align 4
_printb:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	cmp w0, #0
	b.ne .L_printb0
	adr x2, .L._printb_str0
	b .L_printb1
.L_printb0:
	adr x2, .L._printb_str1
.L_printb1:
	ldur w1, [x2, #-4]
	adr x0, .L._printb_str2
	bl printf
	mov x0, #0
	bl fflush
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

// length of .L._printp_str0
	.word 2
.L._printp_str0:
	.asciz "%p"
.align 4
_printp:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	mov x1, x0
	adr x0, .L._printp_str0
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

_malloc:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	bl malloc
	cbz x0, _errOutOfMemory
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

// length of .L._errOutOfMemory_str0
	.word 27
.L._errOutOfMemory_str0:
	.asciz "fatal error: out of memory\n"
.align 4
_errOutOfMemory:
	adr x0, .L._errOutOfMemory_str0
	bl _prints
	mov w0, #-1
	bl exit

