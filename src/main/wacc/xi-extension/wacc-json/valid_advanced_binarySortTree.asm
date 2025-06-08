// length of .L.str0
	.word 47
.L.str0:
	.asciz "Please enter the number of integers to insert: "
// length of .L.str1
	.word 10
.L.str1:
	.asciz "There are "
// length of .L.str2
	.word 10
.L.str2:
	.asciz " integers."
// length of .L.str3
	.word 36
.L.str3:
	.asciz "Please enter the number at position "
// length of .L.str4
	.word 3
.L.str4:
	.asciz " : "
// length of .L.str5
	.word 29
.L.str5:
	.asciz "Here are the numbers sorted: "
// length of .L.str6
	.word 0
.L.str6:
	.asciz ""
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	mov w19, #0
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	// load the current value in the destination of the read so it supports defaults
	mov w0, w19
	bl _readi
	mov w19, w0
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	adrp x0, .L.str2
	add x0, x0, :lo12:.L.str2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov w20, #0
	mov x21, #0
	b .L6
.L7:
	mov w22, #0
	adrp x0, .L.str3
	add x0, x0, :lo12:.L.str3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	adds w0, w20, #1
	b.vs _errOverflow
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	adrp x0, .L.str4
	add x0, x0, :lo12:.L.str4
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	// load the current value in the destination of the read so it supports defaults
	mov w0, w22
	bl _readi
	mov w22, w0
	mov x0, x21
	mov w1, w22
	bl wacc_insert
	mov x21, x0
	adds w20, w20, #1
	b.vs _errOverflow
.L6:
	cmp w20, w19
	b.lt .L7
	adrp x0, .L.str5
	add x0, x0, :lo12:.L.str5
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov x0, x21
	bl wacc_printTree
	mov w20, w0
	adrp x0, .L.str6
	add x0, x0, :lo12:.L.str6
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov x0, #0
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_createNewNode:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	str x1, [x16]
	str x2, [x16, #8]
	mov x19, x16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	str x0, [x16]
	str x19, [x16, #8]
	mov x20, x16
	mov x0, x20
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_insert:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	cmp x0, #0
	b.eq .L0
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x20, [x0]
	mov x21, #0
	cmp w1, w20
	b.lt .L2
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_insert
	mov x16, x0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	cmp x19, #0
	b.eq _errNull
	str x16, [x19, #8]
	b .L3
.L2:
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19]
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_insert
	mov x16, x0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	cmp x19, #0
	b.eq _errNull
	str x16, [x19]
.L3:
	b .L1
.L0:
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w1
	mov x1, #0
	mov x2, #0
	bl wacc_createNewNode
	mov x16, x0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov x0, x16
.L1:
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printTree:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	cmp x0, #0
	b.eq .L4
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0, #8]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_printTree
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w21, w16
	cmp x0, #0
	b.eq _errNull
	ldr x21, [x0]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w21
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, #32
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	// pop {x0}
	ldp x0, xzr, [sp], #16
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_printTree
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w21, w16
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L5
.L4:
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L5:
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

// length of .L._readi_str0
	.word 2
.L._readi_str0:
	.asciz "%d"
.align 4
_readi:
	// X0 contains the "original" value of the destination of the read
	// allocate space on the stack to store the read: preserve alignment!
	// the passed default argument should be stored in case of EOF
	// aarch64 mandates 16-byte SP alignment at all times, might as well merge the stores
	// push {x0, lr}
	stp x0, lr, [sp, #-16]!
	mov x1, sp
	adr x0, .L._readi_str0
	bl scanf
	// pop {x0, lr}
	ldp x0, lr, [sp], #16
	ret

_malloc:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	bl malloc
	cbz x0, _errOutOfMemory
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

// length of .L._errNull_str0
	.word 45
.L._errNull_str0:
	.asciz "fatal error: null pair dereferenced or freed\n"
.align 4
_errNull:
	adr x0, .L._errNull_str0
	bl _prints
	mov w0, #-1
	bl exit

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

