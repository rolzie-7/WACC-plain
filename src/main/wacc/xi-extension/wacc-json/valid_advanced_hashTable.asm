// length of .L.str0
	.word 0
.L.str0:
	.asciz ""
// length of .L.str1
	.word 43
.L.str1:
	.asciz "==========================================="
// length of .L.str2
	.word 43
.L.str2:
	.asciz "========== Hash Table Program ============="
// length of .L.str3
	.word 43
.L.str3:
	.asciz "=                                         ="
// length of .L.str4
	.word 43
.L.str4:
	.asciz "= Please choose the following options:    ="
// length of .L.str5
	.word 43
.L.str5:
	.asciz "= a: insert an integer                    ="
// length of .L.str6
	.word 43
.L.str6:
	.asciz "= b: find an integer                      ="
// length of .L.str7
	.word 43
.L.str7:
	.asciz "= c: count the integers                   ="
// length of .L.str8
	.word 43
.L.str8:
	.asciz "= d: print all integers                   ="
// length of .L.str9
	.word 43
.L.str9:
	.asciz "= e: remove an integer                    ="
// length of .L.str10
	.word 43
.L.str10:
	.asciz "= f: remove all integers                  ="
// length of .L.str11
	.word 43
.L.str11:
	.asciz "= g: exit                                 ="
// length of .L.str12
	.word 15
.L.str12:
	.asciz "Your decision: "
// length of .L.str13
	.word 18
.L.str13:
	.asciz "You have entered: "
// length of .L.str14
	.word 36
.L.str14:
	.asciz " which is invalid, please try again."
// length of .L.str15
	.word 35
.L.str15:
	.asciz "Please enter an integer to insert: "
// length of .L.str16
	.word 51
.L.str16:
	.asciz "The integer is already there. No insertion is made."
// length of .L.str17
	.word 43
.L.str17:
	.asciz "Successfully insert it. The integer is new."
// length of .L.str18
	.word 33
.L.str18:
	.asciz "Please enter an integer to find: "
// length of .L.str19
	.word 25
.L.str19:
	.asciz "The integer is not found."
// length of .L.str20
	.word 17
.L.str20:
	.asciz "Find the integer."
// length of .L.str21
	.word 10
.L.str21:
	.asciz "There are "
// length of .L.str22
	.word 10
.L.str22:
	.asciz " integers."
// length of .L.str23
	.word 24
.L.str23:
	.asciz "There is only 1 integer."
// length of .L.str24
	.word 23
.L.str24:
	.asciz "Here are the integers: "
// length of .L.str25
	.word 35
.L.str25:
	.asciz "Please enter an integer to remove: "
// length of .L.str26
	.word 29
.L.str26:
	.asciz "The integer has been removed."
// length of .L.str27
	.word 31
.L.str27:
	.asciz "All integers have been removed."
// length of .L.str28
	.word 23
.L.str28:
	.asciz "Error: unknown choice ("
// length of .L.str29
	.word 1
.L.str29:
	.asciz ")"
// length of .L.str30
	.word 13
.L.str30:
	.asciz "Goodbye Human"
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	// 13 element array
	mov w0, #108
	bl _malloc
	mov x16, x0
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #13
	stur w8, [x16, #-4]
	mov x8, #0
	str x8, [x16]
	mov x8, #0
	str x8, [x16, #8]
	mov x8, #0
	str x8, [x16, #16]
	mov x8, #0
	str x8, [x16, #24]
	mov x8, #0
	str x8, [x16, #32]
	mov x8, #0
	str x8, [x16, #40]
	mov x8, #0
	str x8, [x16, #48]
	mov x8, #0
	str x8, [x16, #56]
	mov x8, #0
	str x8, [x16, #64]
	mov x8, #0
	str x8, [x16, #72]
	mov x8, #0
	str x8, [x16, #80]
	mov x8, #0
	str x8, [x16, #88]
	mov x8, #0
	str x8, [x16, #96]
	mov x19, x16
	mov x0, x19
	bl wacc_init
	mov w20, w0
	mov w21, #1
	b .L39
.L40:
	bl wacc_printMenu
	mov w22, w0
	cmp w22, #97
	b.eq .L41
	cmp w22, #98
	b.eq .L43
	cmp w22, #99
	b.eq .L45
	cmp w22, #100
	b.eq .L47
	cmp w22, #101
	b.eq .L49
	cmp w22, #102
	b.eq .L51
	cmp w22, #103
	b.eq .L53
	adrp x0, .L.str28
	add x0, x0, :lo12:.L.str28
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w22
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	adrp x0, .L.str29
	add x0, x0, :lo12:.L.str29
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov w0, #-1
	// statement primitives do not return results (but will clobber r0/rax)
	bl exit
	b .L54
.L53:
	adrp x0, .L.str30
	add x0, x0, :lo12:.L.str30
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov w21, #0
.L54:
	b .L52
.L51:
	mov x0, x19
	bl wacc_handleMenuRemoveAll
	mov w23, w0
.L52:
	b .L50
.L49:
	mov x0, x19
	bl wacc_handleMenuRemove
	mov w23, w0
.L50:
	b .L48
.L47:
	mov x0, x19
	bl wacc_handleMenuPrint
	mov w23, w0
.L48:
	b .L46
.L45:
	mov x0, x19
	bl wacc_handleMenuCount
	mov w23, w0
.L46:
	b .L44
.L43:
	mov x0, x19
	bl wacc_handleMenuFind
	mov w23, w0
.L44:
	b .L42
.L41:
	mov x0, x19
	bl wacc_handleMenuInsert
	mov w23, w0
.L42:
.L39:
	cmp w21, #1
	b.eq .L40
	mov x0, #0
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_init:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	ldur w19, [x0, #-4]
	mov w20, #0
	b .L0
.L1:
	mov w17, w20
	mov x8, #0
	mov x7, x0
	bl _arrStore8
	adds w20, w20, #1
	b.vs _errOverflow
.L0:
	cmp w20, w19
	b.lt .L1
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_contain:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_calculateIndex
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w19, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, w19
	mov x7, x0
	bl _arrLoad8
	mov x0, x7
	bl wacc_findNode
	mov x16, x0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov x20, x16
	cmp x20, #0
	cset w8, ne
	mov w0, w8
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_insertIfNotContain:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_calculateIndex
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w19, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, w19
	mov x7, x0
	bl _arrLoad8
	mov x0, x7
	bl wacc_findNode
	mov x16, x0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov x20, x16
	cmp x20, #0
	b.ne .L2
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	str x1, [x16]
	mov w17, w19
	mov x7, x0
	bl _arrLoad8
	str x7, [x16, #8]
	mov x21, x16
	mov w17, w19
	mov x8, x21
	mov x7, x0
	bl _arrStore8
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L3
.L2:
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L3:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_remove:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_calculateIndex
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w19, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, w19
	mov x7, x0
	bl _arrLoad8
	mov x0, x7
	bl wacc_findNode
	mov x16, x0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov x20, x16
	cmp x20, #0
	b.eq .L4
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, w19
	mov x7, x0
	bl _arrLoad8
	mov x0, x7
	mov x1, x20
	bl wacc_removeNode
	mov x16, x0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w17, w19
	mov x8, x16
	mov x7, x0
	bl _arrStore8
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L5
.L4:
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L5:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_removeAll:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	ldur w19, [x0, #-4]
	mov w20, #0
	b .L6
.L7:
	mov w17, w20
	mov x7, x0
	bl _arrLoad8
	mov x21, x7
	b .L8
.L9:
	cmp x21, #0
	b.eq _errNull
	ldr x22, [x21, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov x21, x22
.L8:
	cmp x21, #0
	b.ne .L9
	mov w17, w20
	mov x8, #0
	mov x7, x0
	bl _arrStore8
	adds w20, w20, #1
	b.vs _errOverflow
.L6:
	cmp w20, w19
	b.lt .L7
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_count:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	ldur w19, [x0, #-4]
	mov w20, #0
	mov w21, #0
	b .L10
.L11:
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, w21
	mov x7, x0
	bl _arrLoad8
	mov x0, x7
	bl wacc_countNodes
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w22, w16
	adds w20, w20, w22
	b.vs _errOverflow
	adds w21, w21, #1
	b.vs _errOverflow
.L10:
	cmp w21, w19
	b.lt .L11
	mov w0, w20
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printAll:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	ldur w19, [x0, #-4]
	mov w20, #0
	b .L12
.L13:
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, w20
	mov x7, x0
	bl _arrLoad8
	mov x0, x7
	bl wacc_printAllNodes
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w21, w16
	adds w20, w20, #1
	b.vs _errOverflow
.L12:
	cmp w20, w19
	b.lt .L13
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_calculateIndex:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	ldur w19, [x0, #-4]
	cmp w19, #0
	b.eq _errDivZero
	sdiv w17, w1, w19
	msub w0, w17, w19, w1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_findNode:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	b .L14
.L15:
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp w19, w1
	b.eq .L16
	cmp x0, #0
	b.eq _errNull
	ldr x0, [x0, #8]
	b .L17
.L16:
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L17:
.L14:
	cmp x0, #0
	b.ne .L15
	mov x0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_removeNode:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	cmp x0, #0
	b.eq .L18
	cmp x0, x1
	b.eq .L20
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0, #8]
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	bl wacc_removeNode
	mov x16, x0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	cmp x0, #0
	b.eq _errNull
	str x16, [x0, #8]
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L21
.L20:
	cmp x0, #0
	b.eq _errNull
	ldr x0, [x0, #8]
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L21:
	b .L19
.L18:
	mov x0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L19:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_countNodes:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w19, #0
	b .L22
.L23:
	adds w19, w19, #1
	b.vs _errOverflow
	cmp x0, #0
	b.eq _errNull
	ldr x0, [x0, #8]
.L22:
	cmp x0, #0
	b.ne .L23
	mov w0, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printAllNodes:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	b .L24
.L25:
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w19
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
	cmp x0, #0
	b.eq _errNull
	ldr x0, [x0, #8]
.L24:
	cmp x0, #0
	b.ne .L25
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printMenu:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str2
	add x0, x0, :lo12:.L.str2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str3
	add x0, x0, :lo12:.L.str3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str4
	add x0, x0, :lo12:.L.str4
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str3
	add x0, x0, :lo12:.L.str3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str5
	add x0, x0, :lo12:.L.str5
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str6
	add x0, x0, :lo12:.L.str6
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str7
	add x0, x0, :lo12:.L.str7
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str8
	add x0, x0, :lo12:.L.str8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str9
	add x0, x0, :lo12:.L.str9
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str10
	add x0, x0, :lo12:.L.str10
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str11
	add x0, x0, :lo12:.L.str11
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str3
	add x0, x0, :lo12:.L.str3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str1
	add x0, x0, :lo12:.L.str1
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov w19, #97
	mov w20, #103
	b .L26
.L27:
	adrp x0, .L.str12
	add x0, x0, :lo12:.L.str12
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w21, #0
	// load the current value in the destination of the read so it supports defaults
	mov w0, w21
	bl _readc
	mov w21, w0
	mov w22, w21
	cmp w19, w22
	cset w8, le
	cmp w8, #1
	b.ne .L30
	cmp w22, w20
	cset w8, le
	cmp w8, #1
.L30:
	b.eq .L28
	adrp x0, .L.str13
	add x0, x0, :lo12:.L.str13
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w21
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	adrp x0, .L.str14
	add x0, x0, :lo12:.L.str14
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	b .L29
.L28:
	mov w0, w21
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L29:
.L26:
	mov w8, #1
	cmp w8, #1
	b.eq .L27
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_askForInt:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, #0
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// load the current value in the destination of the read so it supports defaults
	mov w0, w19
	bl _readi
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str13
	add x0, x0, :lo12:.L.str13
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w0, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_handleMenuInsert:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str15
	add x0, x0, :lo12:.L.str15
	bl wacc_askForInt
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, w19
	bl wacc_insertIfNotContain
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w20, w16
	cmp w20, #1
	b.eq .L31
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str16
	add x0, x0, :lo12:.L.str16
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	b .L32
.L31:
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str17
	add x0, x0, :lo12:.L.str17
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
.L32:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_handleMenuFind:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str18
	add x0, x0, :lo12:.L.str18
	bl wacc_askForInt
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, w19
	bl wacc_contain
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w20, w16
	cmp w20, #1
	b.eq .L33
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str19
	add x0, x0, :lo12:.L.str19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	b .L34
.L33:
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str20
	add x0, x0, :lo12:.L.str20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
.L34:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_handleMenuCount:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_count
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	cmp w19, #1
	b.eq .L35
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str21
	add x0, x0, :lo12:.L.str21
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str22
	add x0, x0, :lo12:.L.str22
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	b .L36
.L35:
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str23
	add x0, x0, :lo12:.L.str23
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
.L36:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_handleMenuPrint:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str24
	add x0, x0, :lo12:.L.str24
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_printAll
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_handleMenuRemove:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str25
	add x0, x0, :lo12:.L.str25
	bl wacc_askForInt
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, w19
	bl wacc_remove
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w20, w16
	cmp w20, #1
	b.eq .L37
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str19
	add x0, x0, :lo12:.L.str19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	b .L38
.L37:
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str26
	add x0, x0, :lo12:.L.str26
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
.L38:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_handleMenuRemoveAll:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_removeAll
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w19, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str27
	add x0, x0, :lo12:.L.str27
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

_freepair:
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	cbz x0, _errNull
	bl free
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

_arrLoad8:
	// Special calling convention: array ptr passed in X7, index in X17, LR (W30) is used as general register, and return into X7
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	cmp w17, #0
	csel x1, x17, x1, lt // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.lt _errOutOfBounds
	ldur w30, [x7, #-4]
	cmp w17, w30
	csel x1, x17, x1, ge // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.ge _errOutOfBounds
	ldr x7, [x7, x17, lsl #3]
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

_arrStore8:
	// Special calling convention: array ptr passed in X7, index in X17, value to store in X8, LR (W30) is used as general register
	// push {lr}
	stp lr, xzr, [sp, #-16]!
	cmp w17, #0
	csel x1, x17, x1, lt // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.lt _errOutOfBounds
	ldur w30, [x7, #-4]
	cmp w17, w30
	csel x1, x17, x1, ge // this must be a 64-bit move so that it doesn't truncate if the move fails
	b.ge _errOutOfBounds
	str x8, [x7, x17, lsl #3]
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

// length of .L._errDivZero_str0
	.word 40
.L._errDivZero_str0:
	.asciz "fatal error: division or modulo by zero\n"
.align 4
_errDivZero:
	adr x0, .L._errDivZero_str0
	bl _prints
	mov w0, #-1
	bl exit

// length of .L._errOutOfBounds_str0
	.word 42
.L._errOutOfBounds_str0:
	.asciz "fatal error: array index %d out of bounds\n"
.align 4
_errOutOfBounds:
	adr x0, .L._errOutOfBounds_str0
	bl printf
	mov x0, #0
	bl fflush
	mov w0, #-1
	bl exit

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

