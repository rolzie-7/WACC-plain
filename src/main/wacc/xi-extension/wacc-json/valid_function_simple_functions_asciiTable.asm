// length of .L.str0
	.word 1
.L.str0:
	.asciz "-"
// length of .L.str1
	.word 0
.L.str1:
	.asciz ""
// length of .L.str2
	.word 3
.L.str2:
	.asciz "|  "
// length of .L.str3
	.word 1
.L.str3:
	.asciz " "
// length of .L.str4
	.word 3
.L.str4:
	.asciz " = "
// length of .L.str5
	.word 3
.L.str5:
	.asciz "  |"
// length of .L.str6
	.word 29
.L.str6:
	.asciz "Ascii character lookup table:"
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	adrp x0, .L.str6
	add x0, x0, :lo12:.L.str6
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov w0, #13
	bl wacc_printLine
	mov w19, w0
	mov w20, #32
	b .L4
.L5:
	mov w0, w20
	bl wacc_printMap
	mov w19, w0
	adds w20, w20, #1
	b.vs _errOverflow
.L4:
	cmp w20, #127
	b.lt .L5
	mov w0, #13
	bl wacc_printLine
	mov w19, w0
	mov x0, #0
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_printLine:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w19, #0
	b .L0
.L1:
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	// pop {x0}
	ldp x0, xzr, [sp], #16
	adds w19, w19, #1
	b.vs _errOverflow
.L0:
	cmp w19, w0
	b.lt .L1
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printMap:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str2
	add x0, x0, :lo12:.L.str2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	// pop {x0}
	ldp x0, xzr, [sp], #16
	cmp w0, #100
	b.lt .L2
	b .L3
.L2:
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str3
	add x0, x0, :lo12:.L.str3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	// pop {x0}
	ldp x0, xzr, [sp], #16
.L3:
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str4
	add x0, x0, :lo12:.L.str4
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w8, w0
	tst w8, #0xffffff80
	csel x1, x8, x1, ne // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.ne _errBadChar
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str5
	add x0, x0, :lo12:.L.str5
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w0, #1
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

// length of .L._errBadChar_str0
	.word 50
.L._errBadChar_str0:
	.asciz "fatal error: int %d is not ascii character 0-127 \n"
.align 4
_errBadChar:
	adr x0, .L._errBadChar_str0
	bl printf
	mov x0, #0
	bl fflush
	mov w0, #-1
	bl exit

