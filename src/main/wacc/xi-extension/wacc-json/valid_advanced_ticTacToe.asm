// length of .L.str0
	.word 38
.L.str0:
	.asciz "========= Tic Tac Toe ================"
// length of .L.str1
	.word 38
.L.str1:
	.asciz "=  Because we know you want to win   ="
// length of .L.str2
	.word 38
.L.str2:
	.asciz "======================================"
// length of .L.str3
	.word 38
.L.str3:
	.asciz "=                                    ="
// length of .L.str4
	.word 38
.L.str4:
	.asciz "= Who would you like to be?          ="
// length of .L.str5
	.word 38
.L.str5:
	.asciz "=   x  (play first)                  ="
// length of .L.str6
	.word 38
.L.str6:
	.asciz "=   o  (play second)                 ="
// length of .L.str7
	.word 38
.L.str7:
	.asciz "=   q  (quit)                        ="
// length of .L.str8
	.word 39
.L.str8:
	.asciz "Which symbol you would like to choose: "
// length of .L.str9
	.word 16
.L.str9:
	.asciz "Invalid symbol: "
// length of .L.str10
	.word 17
.L.str10:
	.asciz "Please try again."
// length of .L.str11
	.word 15
.L.str11:
	.asciz "Goodbye safety."
// length of .L.str12
	.word 17
.L.str12:
	.asciz "You have chosen: "
// length of .L.str13
	.word 6
.L.str13:
	.asciz " 1 2 3"
// length of .L.str14
	.word 1
.L.str14:
	.asciz "1"
// length of .L.str15
	.word 6
.L.str15:
	.asciz " -+-+-"
// length of .L.str16
	.word 1
.L.str16:
	.asciz "2"
// length of .L.str17
	.word 1
.L.str17:
	.asciz "3"
// length of .L.str18
	.word 0
.L.str18:
	.asciz ""
// length of .L.str19
	.word 23
.L.str19:
	.asciz "What is your next move?"
// length of .L.str20
	.word 12
.L.str20:
	.asciz " row (1-3): "
// length of .L.str21
	.word 15
.L.str21:
	.asciz " column (1-3): "
// length of .L.str22
	.word 39
.L.str22:
	.asciz "Your move is invalid. Please try again."
// length of .L.str23
	.word 21
.L.str23:
	.asciz "The AI played at row "
// length of .L.str24
	.word 8
.L.str24:
	.asciz " column "
// length of .L.str25
	.word 31
.L.str25:
	.asciz "AI is cleaning up its memory..."
// length of .L.str26
	.word 52
.L.str26:
	.asciz "Internal Error: cannot find the next move for the AI"
// length of .L.str27
	.word 50
.L.str27:
	.asciz "Internal Error: symbol given is neither 'x' or 'o'"
// length of .L.str28
	.word 58
.L.str28:
	.asciz "Initialising AI. Please wait, this may take a few minutes."
// length of .L.str29
	.word 10
.L.str29:
	.asciz "Stalemate!"
// length of .L.str30
	.word 9
.L.str30:
	.asciz " has won!"
.align 4
.text
.global main
main:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25, x26, x27, x28}
	stp x19, x20, [sp, #-80]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	stp x27, x28, [sp, #64]
	mov fp, sp
	bl wacc_chooseSymbol
	mov w19, w0
	bl wacc_oppositeSymbol
	mov w20, w0
	mov w21, #120
	bl wacc_allocateNewBoard
	mov x22, x0
	adrp x0, .L.str28
	add x0, x0, :lo12:.L.str28
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov w0, w20
	bl wacc_initAI
	mov x23, x0
	mov w24, #0
	mov w25, #0
	mov x0, x22
	bl wacc_printBoard
	mov w26, w0
	b .L135
.L136:
	// 2 element array
	mov w0, #12
	bl _malloc
	mov x16, x0
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #2
	stur w8, [x16, #-4]
	mov w8, #0
	str w8, [x16]
	mov w8, #0
	str w8, [x16, #4]
	mov x27, x16
	mov x0, x22
	mov w1, w21
	mov w2, w19
	mov x3, x23
	mov x4, x27
	bl wacc_askForAMove
	mov w26, w0
	mov x0, x22
	mov w1, w21
	mov w17, #0
	mov x7, x27
	bl _arrLoad4
	mov w2, w7
	mov w17, #1
	mov x7, x27
	bl _arrLoad4
	mov w3, w7
	bl wacc_placeMove
	mov w26, w0
	mov x0, x22
	mov w1, w21
	mov w2, w19
	mov x3, x23
	mov w17, #0
	mov x7, x27
	bl _arrLoad4
	mov w4, w7
	mov w17, #1
	mov x7, x27
	bl _arrLoad4
	mov w5, w7
	bl wacc_notifyMove
	mov w26, w0
	mov x0, x22
	bl wacc_printBoard
	mov w26, w0
	mov x0, x22
	mov w1, w21
	bl wacc_hasWon
	mov w28, w0
	cmp w28, #1
	b.eq .L137
	b .L138
.L137:
	mov w25, w21
.L138:
	mov w0, w21
	bl wacc_oppositeSymbol
	mov w21, w0
	adds w24, w24, #1
	b.vs _errOverflow
.L135:
	cmp w25, #0
	cset w8, eq
	cmp w8, #1
	b.ne .L139
	cmp w24, #9
	cset w8, lt
	cmp w8, #1
.L139:
	b.eq .L136
	mov x0, x22
	bl wacc_freeBoard
	mov w26, w0
	mov x0, x23
	bl wacc_destroyAI
	mov w26, w0
	cmp w25, #0
	b.ne .L140
	adrp x0, .L.str29
	add x0, x0, :lo12:.L.str29
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	b .L141
.L140:
	mov w0, w25
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	adrp x0, .L.str30
	add x0, x0, :lo12:.L.str30
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
.L141:
	mov x0, #0
	// pop {x19, x20, x21, x22, x23, x24, x25, x26, x27, x28}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldp x27, x28, [sp, #64]
	ldp x19, x20, [sp], #80
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret

wacc_chooseSymbol:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	adrp x0, .L.str0
	add x0, x0, :lo12:.L.str0
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
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
	adrp x0, .L.str3
	add x0, x0, :lo12:.L.str3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	adrp x0, .L.str2
	add x0, x0, :lo12:.L.str2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov w19, #0
	b .L0
.L1:
	adrp x0, .L.str8
	add x0, x0, :lo12:.L.str8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w20, #0
	// load the current value in the destination of the read so it supports defaults
	mov w0, w20
	bl _readc
	mov w20, w0
	cmp w20, #120
	cset w8, eq
	cmp w8, #1
	b.eq .L4
	cmp w20, #88
	cset w8, eq
	cmp w8, #1
.L4:
	b.eq .L2
	cmp w20, #111
	cset w8, eq
	cmp w8, #1
	b.eq .L7
	cmp w20, #79
	cset w8, eq
	cmp w8, #1
.L7:
	b.eq .L5
	cmp w20, #113
	cset w8, eq
	cmp w8, #1
	b.eq .L10
	cmp w20, #81
	cset w8, eq
	cmp w8, #1
.L10:
	b.eq .L8
	adrp x0, .L.str9
	add x0, x0, :lo12:.L.str9
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	adrp x0, .L.str10
	add x0, x0, :lo12:.L.str10
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	b .L9
.L8:
	adrp x0, .L.str11
	add x0, x0, :lo12:.L.str11
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	mov w0, #0
	// statement primitives do not return results (but will clobber r0/rax)
	bl exit
.L9:
	b .L6
.L5:
	mov w19, #111
.L6:
	b .L3
.L2:
	mov w19, #120
.L3:
.L0:
	cmp w19, #0
	b.eq .L1
	adrp x0, .L.str12
	add x0, x0, :lo12:.L.str12
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	mov w0, w19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	mov w0, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printBoard:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str13
	add x0, x0, :lo12:.L.str13
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str14
	add x0, x0, :lo12:.L.str14
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_printRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str15
	add x0, x0, :lo12:.L.str15
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str16
	add x0, x0, :lo12:.L.str16
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_printRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str15
	add x0, x0, :lo12:.L.str15
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str17
	add x0, x0, :lo12:.L.str17
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_printRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str18
	add x0, x0, :lo12:.L.str18
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w20
	bl wacc_printCell
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, #124
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w21
	bl wacc_printCell
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, #124
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w22
	bl wacc_printCell
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str18
	add x0, x0, :lo12:.L.str18
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printCell:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	cmp w0, #0
	b.eq .L11
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	// pop {x0}
	ldp x0, xzr, [sp], #16
	b .L12
.L11:
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, #32
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	// pop {x0}
	ldp x0, xzr, [sp], #16
.L12:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_askForAMoveHuman:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	mov w19, #0
	mov w20, #0
	mov w21, #0
	b .L13
.L14:
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str19
	add x0, x0, :lo12:.L.str19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0, x1}
	ldp x0, x1, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str20
	add x0, x0, :lo12:.L.str20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1}
	ldp x0, x1, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// load the current value in the destination of the read so it supports defaults
	mov w0, w20
	bl _readi
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w20, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str21
	add x0, x0, :lo12:.L.str21
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1}
	ldp x0, x1, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// load the current value in the destination of the read so it supports defaults
	mov w0, w21
	bl _readi
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w21, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, w20
	mov w2, w21
	bl wacc_validateMove
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w19, w16
	cmp w19, #1
	b.eq .L15
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str22
	add x0, x0, :lo12:.L.str22
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	b .L16
.L15:
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str18
	add x0, x0, :lo12:.L.str18
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w17, #0
	mov w8, w20
	mov x7, x1
	bl _arrStore4
	mov w17, #1
	mov w8, w21
	mov x7, x1
	bl _arrStore4
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L16:
.L13:
	cmp w19, #1
	b.ne .L14
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

wacc_validateMove:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w8, #1
	cmp w8, w1
	cset w8, le
	cmp w8, #1
	b.ne .L19
	cmp w1, #3
	cset w8, le
	cmp w8, #1
	b.ne .L20
	mov w8, #1
	cmp w8, w2
	cset w8, le
	cmp w8, #1
	b.ne .L21
	cmp w2, #3
	cset w8, le
	cmp w8, #1
.L21:
	cset w8, eq
	cmp w8, #1
.L20:
	cset w8, eq
	cmp w8, #1
.L19:
	b.eq .L17
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L18
.L17:
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_symbolAt
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w19, w16
	cmp w19, #0
	cset w8, eq
	mov w0, w8
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L18:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_notifyMoveHuman:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str23
	add x0, x0, :lo12:.L.str23
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	# pop/peek {x0, x1, x2, x3, x4}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str24
	add x0, x0, :lo12:.L.str24
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w4
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_initAI:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	str x0, [x16]
	mov x8, #0
	str x8, [x16, #8]
	mov x19, x16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_generateAllPossibleStates
	mov x16, x0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov x20, x16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	ldr x1, [x16]
	mov w2, #120
	bl wacc_setValuesForAllStates
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w21, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	str x19, [x16]
	str x20, [x16, #8]
	mov x22, x16
	mov x0, x22
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_generateAllPossibleStates:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_allocateNewBoard
	mov x16, x0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov x19, x16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	bl wacc_convertFromBoardToState
	mov x16, x0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov x20, x16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	mov w1, #120
	bl wacc_generateNextStates
	mov x16, x0
	// pop {x0}
	ldp x0, xzr, [sp], #16
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

wacc_convertFromBoardToState:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_generateEmptyPointerBoard
	mov x16, x0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov x19, x16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	str x0, [x16]
	str x19, [x16, #8]
	mov x20, x16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	str x20, [x16]
	mov w8, #0
	str x8, [x16, #8]
	mov x21, x16
	mov x0, x21
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_generateEmptyPointerBoard:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	bl wacc_generateEmptyPointerRow
	mov x19, x0
	bl wacc_generateEmptyPointerRow
	mov x20, x0
	bl wacc_generateEmptyPointerRow
	mov x21, x0
	mov w0, #16
	bl _malloc
	mov x16, x0
	str x19, [x16]
	str x20, [x16, #8]
	mov x22, x16
	mov w0, #16
	bl _malloc
	mov x16, x0
	str x22, [x16]
	str x21, [x16, #8]
	mov x23, x16
	mov x0, x23
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_generateEmptyPointerRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	mov w0, #16
	bl _malloc
	mov x16, x0
	mov x8, #0
	str x8, [x16]
	mov x8, #0
	str x8, [x16, #8]
	mov x19, x16
	mov w0, #16
	bl _malloc
	mov x16, x0
	str x19, [x16]
	mov x8, #0
	str x8, [x16, #8]
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

wacc_generateNextStates:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w1
	bl wacc_oppositeSymbol
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w22, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	mov w1, w22
	bl wacc_hasWon
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w23, w16
	cmp w23, #1
	b.eq .L22
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	mov x1, x21
	ldr x2, [x16, #8]
	bl wacc_generateNextStatesBoard
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w24, w16
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L23
.L22:
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L23:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_generateNextStatesBoard:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25, x26, x27}
	stp x19, x20, [sp, #-80]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	stur x27, [sp, #64]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	cmp x1, #0
	b.eq _errNull
	ldr x23, [x1]
	cmp x23, #0
	b.eq _errNull
	ldr x24, [x23]
	cmp x23, #0
	b.eq _errNull
	ldr x25, [x23, #8]
	cmp x1, #0
	b.eq _errNull
	ldr x26, [x1, #8]
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x1, x20
	mov x2, x24
	ldr x3, [x16, #16]
	mov w4, #1
	bl wacc_generateNextStatesRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w27, w16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x1, x21
	mov x2, x25
	ldr x3, [x16, #16]
	mov w4, #2
	bl wacc_generateNextStatesRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w27, w16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x1, x22
	mov x2, x26
	ldr x3, [x16, #16]
	mov w4, #3
	bl wacc_generateNextStatesRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w27, w16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24, x25, x26, x27}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldur x27, [sp, #64]
	ldp x19, x20, [sp], #80
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_generateNextStatesRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x1, #0
	b.eq _errNull
	ldr x19, [x1]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x1, #0
	b.eq _errNull
	ldr x22, [x1, #8]
	cmp x2, #0
	b.eq _errNull
	ldr x23, [x2]
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, w20
	mov w2, w3
	mov w3, w4
	mov w4, #1
	bl wacc_generateNextStatesCell
	mov x16, x0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	cmp x23, #0
	b.eq _errNull
	str x16, [x23]
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, w21
	mov w2, w3
	mov w3, w4
	mov w4, #2
	bl wacc_generateNextStatesCell
	mov x16, x0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	cmp x23, #0
	b.eq _errNull
	str x16, [x23, #8]
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, w22
	mov w2, w3
	mov w3, w4
	mov w4, #3
	bl wacc_generateNextStatesCell
	mov x16, x0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	cmp x2, #0
	b.eq _errNull
	str x16, [x2, #8]
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_generateNextStatesCell:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	cmp w1, #0
	b.eq .L24
	mov x0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L25
.L24:
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_cloneBoard
	mov x16, x0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov x19, x16
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	mov w1, w2
	mov w2, w3
	mov w3, w4
	bl wacc_placeMove
	mov w16, w0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w20, w16
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	bl wacc_convertFromBoardToState
	mov x16, x0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov x21, x16
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w2
	bl wacc_oppositeSymbol
	mov w16, w0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w22, w16
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	mov w1, w22
	bl wacc_generateNextStates
	mov x16, x0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov x21, x16
	mov x0, x21
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L25:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_cloneBoard:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_allocateNewBoard
	mov x16, x0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov x19, x16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x1, x19
	bl wacc_copyBoard
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w20, w16
	mov x0, x19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_copyBoard:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25, x26, x27}
	stp x19, x20, [sp, #-80]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	stur x27, [sp, #64]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	cmp x1, #0
	b.eq _errNull
	ldr x23, [x1]
	cmp x23, #0
	b.eq _errNull
	ldr x24, [x23]
	cmp x23, #0
	b.eq _errNull
	ldr x25, [x23, #8]
	cmp x1, #0
	b.eq _errNull
	ldr x26, [x1, #8]
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	mov x1, x24
	bl wacc_copyRow
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w27, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	mov x1, x25
	bl wacc_copyRow
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w27, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	mov x1, x26
	bl wacc_copyRow
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w27, w16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24, x25, x26, x27}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldur x27, [sp, #64]
	ldp x19, x20, [sp], #80
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_copyRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x1, #0
	b.eq _errNull
	ldr x20, [x1]
	cmp x19, #0
	b.eq _errNull
	ldr x8, [x19]
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	cmp x20, #0
	b.eq _errNull
	// pop {x8}
	ldp x8, xzr, [sp], #16
	str x8, [x20]
	cmp x19, #0
	b.eq _errNull
	ldr x8, [x19, #8]
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	cmp x20, #0
	b.eq _errNull
	// pop {x8}
	ldp x8, xzr, [sp], #16
	str x8, [x20, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x8, [x0, #8]
	// push {x8}
	stp x8, xzr, [sp, #-16]!
	cmp x1, #0
	b.eq _errNull
	// pop {x8}
	ldp x8, xzr, [sp], #16
	str x8, [x1, #8]
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_setValuesForAllStates:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25}
	stp x19, x20, [sp, #-64]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stur x25, [sp, #48]
	mov fp, sp
	mov w19, #0
	cmp x0, #0
	b.eq .L26
	cmp x0, #0
	b.eq _errNull
	ldr x20, [x0]
	cmp x20, #0
	b.eq _errNull
	ldr x21, [x20]
	cmp x20, #0
	b.eq _errNull
	ldr x22, [x20, #8]
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w2
	bl wacc_oppositeSymbol
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w23, w16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	mov w1, w23
	bl wacc_hasWon
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w24, w16
	cmp w24, #1
	b.eq .L28
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_containEmptyCell
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w25, w16
	cmp w25, #1
	b.eq .L30
	mov w19, #0
	b .L31
.L30:
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	mov w2, w23
	bl wacc_calculateValuesFromNextStates
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w19, w16
	cmp w19, #100
	b.eq .L32
	b .L33
.L32:
	mov w19, #90
.L33:
.L31:
	b .L29
.L28:
	cmp w23, w1
	b.eq .L34
	mov w19, #-100
	b .L35
.L34:
	mov w19, #100
.L35:
.L29:
	cmp x0, #0
	b.eq _errNull
	str x19, [x0, #8]
	b .L27
.L26:
	cmp w2, w1
	b.eq .L36
	mov w19, #-101
	b .L37
.L36:
	mov w19, #101
.L37:
.L27:
	mov w0, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24, x25}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldur x25, [sp, #48]
	ldp x19, x20, [sp], #64
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_calculateValuesFromNextStates:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25, x26}
	stp x19, x20, [sp, #-64]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_calculateValuesFromNextStatesRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w23, w16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_calculateValuesFromNextStatesRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w24, w16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_calculateValuesFromNextStatesRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w25, w16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w1
	mov w1, w2
	mov w2, w23
	mov w3, w24
	mov w4, w25
	bl wacc_combineValue
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w26, w16
	mov w0, w26
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24, x25, x26}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldp x19, x20, [sp], #64
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_calculateValuesFromNextStatesRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25, x26}
	stp x19, x20, [sp, #-64]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_setValuesForAllStates
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w23, w16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_setValuesForAllStates
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w24, w16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_setValuesForAllStates
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w25, w16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w1
	mov w1, w2
	mov w2, w23
	mov w3, w24
	mov w4, w25
	bl wacc_combineValue
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w26, w16
	mov w0, w26
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24, x25, x26}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldp x19, x20, [sp], #64
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_combineValue:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	mov w19, #0
	cmp w0, w1
	b.eq .L38
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w2
	mov w1, w3
	mov w2, w4
	bl wacc_max3
	mov w16, w0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w19, w16
	b .L39
.L38:
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w2
	mov w1, w3
	mov w2, w4
	bl wacc_min3
	mov w16, w0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w19, w16
.L39:
	mov w0, w19
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_min3:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	cmp w0, w1
	b.lt .L40
	cmp w1, w2
	b.lt .L42
	mov w0, w2
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L43
.L42:
	mov w0, w1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L43:
	b .L41
.L40:
	cmp w0, w2
	b.lt .L44
	mov w0, w2
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L45
.L44:
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L45:
.L41:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_max3:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	cmp w0, w1
	b.gt .L46
	cmp w1, w2
	b.gt .L48
	mov w0, w2
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L49
.L48:
	mov w0, w1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L49:
	b .L47
.L46:
	cmp w0, w2
	b.gt .L50
	mov w0, w2
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L51
.L50:
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L51:
.L47:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_destroyAI:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x0, #0
	b.eq _errNull
	ldr x20, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_deleteStateTreeRecursively
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w21, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
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

wacc_askForAMoveAI:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	mov fp, sp
	cmp x3, #0
	b.eq _errNull
	ldr x19, [x3]
	cmp x3, #0
	b.eq _errNull
	ldr x20, [x3, #8]
	cmp x20, #0
	b.eq _errNull
	ldr x21, [x20]
	cmp x21, #0
	b.eq _errNull
	ldr x22, [x21, #8]
	cmp x20, #0
	b.eq _errNull
	ldr x23, [x20, #8]
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	mov w1, w23
	mov x2, x4
	bl wacc_findTheBestMove
	mov w16, w0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w24, w16
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str25
	add x0, x0, :lo12:.L.str25
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0, x1, x2, x3, x4}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	mov w17, #0
	mov x7, x4
	bl _arrLoad4
	mov w1, w7
	mov w17, #1
	mov x7, x4
	bl _arrLoad4
	mov w2, w7
	bl wacc_deleteAllOtherChildren
	mov x16, x0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	cmp x3, #0
	b.eq _errNull
	str x16, [x3, #8]
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_deleteThisStateOnly
	mov w16, w0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w24, w16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_findTheBestMove:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	cmp w1, #90
	b.eq .L52
	b .L53
.L52:
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, #100
	bl wacc_findMoveWithGivenValue
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w20, w16
	cmp w20, #1
	b.eq .L54
	b .L55
.L54:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L55:
.L53:
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_findMoveWithGivenValue
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w19, w16
	cmp w19, #1
	b.eq .L56
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str26
	add x0, x0, :lo12:.L.str26
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0, x1, x2}
	ldp x0, x1, [sp]
	ldur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, #-1
	// statement primitives do not return results (but will clobber r0/rax)
	bl exit
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	b .L57
.L56:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L57:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_findMoveWithGivenValue:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_findMoveWithGivenValueRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w23, w16
	cmp w23, #1
	b.eq .L58
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_findMoveWithGivenValueRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w23, w16
	cmp w23, #1
	b.eq .L60
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_findMoveWithGivenValueRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w23, w16
	cmp w23, #1
	b.eq .L62
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L63
.L62:
	mov w17, #0
	mov w8, #3
	mov x7, x2
	bl _arrStore4
.L63:
	b .L61
.L60:
	mov w17, #0
	mov w8, #2
	mov x7, x2
	bl _arrStore4
.L61:
	b .L59
.L58:
	mov w17, #0
	mov w8, #1
	mov x7, x2
	bl _arrStore4
.L59:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_findMoveWithGivenValueRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_hasGivenStateValue
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w23, w16
	cmp w23, #1
	b.eq .L64
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_hasGivenStateValue
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w23, w16
	cmp w23, #1
	b.eq .L66
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_hasGivenStateValue
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w23, w16
	cmp w23, #1
	b.eq .L68
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L69
.L68:
	mov w17, #1
	mov w8, #3
	mov x7, x2
	bl _arrStore4
.L69:
	b .L67
.L66:
	mov w17, #1
	mov w8, #2
	mov x7, x2
	bl _arrStore4
.L67:
	b .L65
.L64:
	mov w17, #1
	mov w8, #1
	mov x7, x2
	bl _arrStore4
.L65:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_hasGivenStateValue:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	cmp x0, #0
	b.eq .L70
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0, #8]
	cmp w19, w1
	cset w8, eq
	mov w0, w8
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L71
.L70:
	mov w0, #0
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L71:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_notifyMoveAI:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	cmp x3, #0
	b.eq _errNull
	ldr x19, [x3, #8]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x20, #0
	b.eq _errNull
	ldr x21, [x20, #8]
	// push {x0, x1, x2, x3, x4, x5}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str25
	add x0, x0, :lo12:.L.str25
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	mov w1, w4
	mov w2, w5
	bl wacc_deleteAllOtherChildren
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x0, x1, [sp], #48
	cmp x3, #0
	b.eq _errNull
	str x16, [x3, #8]
	// push {x0, x1, x2, x3, x4, x5}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	bl wacc_deleteThisStateOnly
	mov w16, w0
	// pop {x0, x1, x2, x3, x4, x5}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w22, w16
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

wacc_deleteAllOtherChildren:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25, x26, x27}
	stp x19, x20, [sp, #-80]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	stur x27, [sp, #64]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	mov x23, #0
	mov x24, #0
	mov x25, #0
	cmp w1, #1
	b.eq .L72
	mov x24, x20
	cmp w1, #2
	b.eq .L74
	mov x23, x22
	mov x25, x21
	b .L75
.L74:
	mov x23, x21
	mov x25, x22
.L75:
	b .L73
.L72:
	mov x23, x20
	mov x24, x21
	mov x25, x22
.L73:
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x23
	mov w1, w2
	bl wacc_deleteAllOtherChildrenRow
	mov x16, x0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov x26, x16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x24
	bl wacc_deleteChildrenStateRecursivelyRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w27, w16
	// push {x0, x1, x2}
	stp x0, x1, [sp, #-32]!
	stur x2, [sp, #16]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x25
	bl wacc_deleteChildrenStateRecursivelyRow
	mov w16, w0
	// pop {x0, x1, x2}
	ldur x2, [sp, #16]
	ldp x0, x1, [sp], #32
	mov w27, w16
	mov x0, x26
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24, x25, x26, x27}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldur x27, [sp, #64]
	ldp x19, x20, [sp], #80
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_deleteAllOtherChildrenRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25, x26}
	stp x19, x20, [sp, #-64]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	mov x23, #0
	mov x24, #0
	mov x25, #0
	cmp w1, #1
	b.eq .L76
	mov x24, x20
	cmp w1, #2
	b.eq .L78
	mov x23, x22
	mov x25, x21
	b .L79
.L78:
	mov x23, x21
	mov x25, x22
.L79:
	b .L77
.L76:
	mov x23, x20
	mov x24, x21
	mov x25, x22
.L77:
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x24
	bl wacc_deleteStateTreeRecursively
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w26, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x25
	bl wacc_deleteStateTreeRecursively
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w26, w16
	mov x0, x23
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24, x25, x26}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldp x19, x20, [sp], #64
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_deleteStateTreeRecursively:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	cmp x0, #0
	b.eq .L80
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_deleteChildrenStateRecursively
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w22, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_deleteThisStateOnly
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w22, w16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L81
.L80:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L81:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_deleteThisStateOnly:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_freeBoard
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w22, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_freePointers
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w22, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	// pop {x0}
	ldp x0, xzr, [sp], #16
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

wacc_freePointers:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_freePointersRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_freePointersRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_freePointersRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_freePointersRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
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

wacc_deleteChildrenStateRecursively:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_deleteChildrenStateRecursivelyRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_deleteChildrenStateRecursivelyRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_deleteChildrenStateRecursivelyRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_deleteChildrenStateRecursivelyRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_deleteStateTreeRecursively
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_deleteStateTreeRecursively
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_deleteStateTreeRecursively
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_askForAMove:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	cmp w1, w2
	b.eq .L82
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_askForAMoveAI
	mov w16, w0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w19, w16
	b .L83
.L82:
	// push {x0, x1, x2, x3, x4}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stur x4, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x1, x4
	bl wacc_askForAMoveHuman
	mov w16, w0
	// pop {x0, x1, x2, x3, x4}
	ldp x2, x3, [sp, #16]
	ldur x4, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w19, w16
.L83:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_placeMove:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	mov x19, #0
	cmp w2, #2
	b.le .L84
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0, #8]
	b .L85
.L84:
	cmp x0, #0
	b.eq _errNull
	ldr x20, [x0]
	cmp w2, #1
	b.eq .L86
	cmp x20, #0
	b.eq _errNull
	ldr x19, [x20, #8]
	b .L87
.L86:
	cmp x20, #0
	b.eq _errNull
	ldr x19, [x20]
.L87:
.L85:
	cmp w3, #2
	b.le .L88
	cmp x19, #0
	b.eq _errNull
	str x1, [x19, #8]
	b .L89
.L88:
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp w3, #1
	b.eq .L90
	cmp x20, #0
	b.eq _errNull
	str x1, [x20, #8]
	b .L91
.L90:
	cmp x20, #0
	b.eq _errNull
	str x1, [x20]
.L91:
.L89:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20}
	ldp x19, x20, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_notifyMove:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	cmp w1, w2
	b.eq .L92
	// push {x0, x1, x2, x3, x4, x5}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w3, w4
	mov w4, w5
	bl wacc_notifyMoveHuman
	mov w16, w0
	// pop {x0, x1, x2, x3, x4, x5}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w19, w16
	b .L93
.L92:
	// push {x0, x1, x2, x3, x4, x5}
	stp x0, x1, [sp, #-48]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	bl wacc_notifyMoveAI
	mov w16, w0
	// pop {x0, x1, x2, x3, x4, x5}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x0, x1, [sp], #48
	mov w19, w16
.L93:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19}
	ldp x19, xzr, [sp], #16
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_oppositeSymbol:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	mov fp, sp
	cmp w0, #120
	b.eq .L94
	cmp w0, #111
	b.eq .L96
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str27
	add x0, x0, :lo12:.L.str27
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, #-1
	// statement primitives do not return results (but will clobber r0/rax)
	bl exit
	// pop {x0}
	ldp x0, xzr, [sp], #16
	b .L97
.L96:
	mov w0, #120
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L97:
	b .L95
.L94:
	mov w0, #111
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L95:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_symbolAt:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	mov x19, #0
	cmp w1, #2
	b.le .L98
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0, #8]
	b .L99
.L98:
	cmp x0, #0
	b.eq _errNull
	ldr x21, [x0]
	cmp w1, #1
	b.eq .L100
	cmp x21, #0
	b.eq _errNull
	ldr x19, [x21, #8]
	b .L101
.L100:
	cmp x21, #0
	b.eq _errNull
	ldr x19, [x21]
.L101:
.L99:
	mov w20, #0
	cmp w2, #2
	b.le .L102
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19, #8]
	b .L103
.L102:
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19]
	cmp w2, #1
	b.eq .L104
	cmp x21, #0
	b.eq _errNull
	ldr x20, [x21, #8]
	b .L105
.L104:
	cmp x21, #0
	b.eq _errNull
	ldr x20, [x21]
.L105:
.L103:
	mov w0, w20
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21}
	ldur x21, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_containEmptyCell:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25}
	stp x19, x20, [sp, #-64]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stur x25, [sp, #48]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_containEmptyCellRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_containEmptyCellRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w24, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_containEmptyCellRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w25, w16
	cmp w23, #1
	b.eq .L106
	cmp w24, #1
	b.eq .L107
	cmp w25, #1
.L107:
	cset w8, eq
	cmp w8, #1
.L106:
	cset w8, eq
	mov w0, w8
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24, x25}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldur x25, [sp, #48]
	ldp x19, x20, [sp], #64
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_containEmptyCellRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22}
	stp x19, x20, [sp, #-32]!
	stp x21, x22, [sp, #16]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	cmp w20, #0
	cset w8, eq
	cmp w8, #1
	b.eq .L108
	cmp w21, #0
	cset w8, eq
	cmp w8, #1
	b.eq .L109
	cmp w22, #0
	cset w8, eq
	cmp w8, #1
.L109:
	cset w8, eq
	cmp w8, #1
.L108:
	cset w8, eq
	mov w0, w8
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22}
	ldp x21, x22, [sp, #16]
	ldp x19, x20, [sp], #32
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_hasWon:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23, x24, x25, x26, x27}
	stp x19, x20, [sp, #-80]!
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	stur x27, [sp, #64]
	mov fp, sp
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, #1
	mov w2, #1
	bl wacc_symbolAt
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w19, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, #1
	mov w2, #2
	bl wacc_symbolAt
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w20, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, #1
	mov w2, #3
	bl wacc_symbolAt
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w21, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, #2
	mov w2, #1
	bl wacc_symbolAt
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w22, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, #2
	mov w2, #2
	bl wacc_symbolAt
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w23, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, #2
	mov w2, #3
	bl wacc_symbolAt
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w24, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, #3
	mov w2, #1
	bl wacc_symbolAt
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w25, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, #3
	mov w2, #2
	bl wacc_symbolAt
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w26, w16
	// push {x0, x1}
	stp x0, x1, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w1, #3
	mov w2, #3
	bl wacc_symbolAt
	mov w16, w0
	// pop {x0, x1}
	ldp x0, x1, [sp], #16
	mov w27, w16
	cmp w19, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L110
	cmp w20, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L111
	cmp w21, w1
	cset w8, eq
	cmp w8, #1
.L111:
	cset w8, eq
	cmp w8, #1
.L110:
	cset w8, eq
	cmp w8, #1
	b.eq .L112
	cmp w22, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L113
	cmp w23, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L114
	cmp w24, w1
	cset w8, eq
	cmp w8, #1
.L114:
	cset w8, eq
	cmp w8, #1
.L113:
	cset w8, eq
	cmp w8, #1
	b.eq .L115
	cmp w25, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L116
	cmp w26, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L117
	cmp w27, w1
	cset w8, eq
	cmp w8, #1
.L117:
	cset w8, eq
	cmp w8, #1
.L116:
	cset w8, eq
	cmp w8, #1
	b.eq .L118
	cmp w19, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L119
	cmp w22, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L120
	cmp w25, w1
	cset w8, eq
	cmp w8, #1
.L120:
	cset w8, eq
	cmp w8, #1
.L119:
	cset w8, eq
	cmp w8, #1
	b.eq .L121
	cmp w20, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L122
	cmp w23, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L123
	cmp w26, w1
	cset w8, eq
	cmp w8, #1
.L123:
	cset w8, eq
	cmp w8, #1
.L122:
	cset w8, eq
	cmp w8, #1
	b.eq .L124
	cmp w21, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L125
	cmp w24, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L126
	cmp w27, w1
	cset w8, eq
	cmp w8, #1
.L126:
	cset w8, eq
	cmp w8, #1
.L125:
	cset w8, eq
	cmp w8, #1
	b.eq .L127
	cmp w19, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L128
	cmp w23, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L129
	cmp w27, w1
	cset w8, eq
	cmp w8, #1
.L129:
	cset w8, eq
	cmp w8, #1
.L128:
	cset w8, eq
	cmp w8, #1
	b.eq .L130
	cmp w21, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L131
	cmp w23, w1
	cset w8, eq
	cmp w8, #1
	b.ne .L132
	cmp w25, w1
	cset w8, eq
	cmp w8, #1
.L132:
	cset w8, eq
	cmp w8, #1
.L131:
	cset w8, eq
	cmp w8, #1
.L130:
	cset w8, eq
	cmp w8, #1
.L127:
	cset w8, eq
	cmp w8, #1
.L124:
	cset w8, eq
	cmp w8, #1
.L121:
	cset w8, eq
	cmp w8, #1
.L118:
	cset w8, eq
	cmp w8, #1
.L115:
	cset w8, eq
	cmp w8, #1
.L112:
	cset w8, eq
	mov w0, w8
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23, x24, x25, x26, x27}
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldur x27, [sp, #64]
	ldp x19, x20, [sp], #80
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_allocateNewBoard:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	bl wacc_allocateNewRow
	mov x19, x0
	bl wacc_allocateNewRow
	mov x20, x0
	bl wacc_allocateNewRow
	mov x21, x0
	mov w0, #16
	bl _malloc
	mov x16, x0
	str x19, [x16]
	str x20, [x16, #8]
	mov x22, x16
	mov w0, #16
	bl _malloc
	mov x16, x0
	str x22, [x16]
	str x21, [x16, #8]
	mov x23, x16
	mov x0, x23
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_allocateNewRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20}
	stp x19, x20, [sp, #-16]!
	mov fp, sp
	mov w0, #16
	bl _malloc
	mov x16, x0
	mov w8, #0
	str x8, [x16]
	mov w8, #0
	str x8, [x16, #8]
	mov x19, x16
	mov w0, #16
	bl _malloc
	mov x16, x0
	str x19, [x16]
	mov w8, #0
	str x8, [x16, #8]
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

wacc_freeBoard:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_freeRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_freeRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_freeRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_freeRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19}
	stp x19, xzr, [sp, #-16]!
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	// statement primitives do not return results (but will clobber r0/rax)
	bl _freepair
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

wacc_printAiData:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21}
	stp x19, x20, [sp, #-32]!
	stur x21, [sp, #16]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x0, #0
	b.eq _errNull
	ldr x20, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_printStateTreeRecursively
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w21, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, #0
	// statement primitives do not return results (but will clobber r0/rax)
	bl exit
	// pop {x0}
	ldp x0, xzr, [sp], #16
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printStateTreeRecursively:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq .L133
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, #118
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, #61
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w22
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	# pop/peek {x0}
	ldur x0, [sp]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_printBoard
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_printChildrenStateTree
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, #112
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	b .L134
.L133:
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
.L134:
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printChildrenStateTree:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_printChildrenStateTreeRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_printChildrenStateTreeRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_printChildrenStateTreeRow
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
	// pop {fp, lr}
	ldp fp, lr, [sp], #16
	ret
	// 'ere be dragons: this is 100% dead code, functions always end in returns!

wacc_printChildrenStateTreeRow:
	// push {fp, lr}
	stp fp, lr, [sp, #-16]!
	// push {x19, x20, x21, x22, x23}
	stp x19, x20, [sp, #-48]!
	stp x21, x22, [sp, #16]
	stur x23, [sp, #32]
	mov fp, sp
	cmp x0, #0
	b.eq _errNull
	ldr x19, [x0]
	cmp x19, #0
	b.eq _errNull
	ldr x20, [x19]
	cmp x19, #0
	b.eq _errNull
	ldr x21, [x19, #8]
	cmp x0, #0
	b.eq _errNull
	ldr x22, [x0, #8]
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x20
	bl wacc_printStateTreeRecursively
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x21
	bl wacc_printStateTreeRecursively
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	// push {x0}
	stp x0, xzr, [sp, #-16]!
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x22
	bl wacc_printStateTreeRecursively
	mov w16, w0
	// pop {x0}
	ldp x0, xzr, [sp], #16
	mov w23, w16
	mov w0, #1
	// reset the stack pointer, undoing any pushes: this is often unnecessary, but is cheap
	mov sp, fp
	// pop {x19, x20, x21, x22, x23}
	ldp x21, x22, [sp, #16]
	ldur x23, [sp, #32]
	ldp x19, x20, [sp], #48
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

_arrLoad4:
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
	ldr w7, [x7, x17, lsl #2]
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

_arrStore4:
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
	str w8, [x7, x17, lsl #2]
	// pop {lr}
	ldp lr, xzr, [sp], #16
	ret

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

