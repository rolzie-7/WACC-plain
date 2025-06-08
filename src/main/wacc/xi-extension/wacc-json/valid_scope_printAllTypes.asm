// length of .L.str0
	.word 2
.L.str0:
	.asciz ", "
// length of .L.str1
	.word 16
.L.str1:
	.asciz "this is a string"
// length of .L.str2
	.word 5
.L.str2:
	.asciz "array"
// length of .L.str3
	.word 2
.L.str3:
	.asciz "of"
// length of .L.str4
	.word 7
.L.str4:
	.asciz "strings"
// length of .L.str5
	.word 3
.L.str5:
	.asciz "( ["
// length of .L.str6
	.word 5
.L.str6:
	.asciz "] , ["
// length of .L.str7
	.word 3
.L.str7:
	.asciz "] )"
// length of .L.str8
	.word 2
.L.str8:
	.asciz "[ "
// length of .L.str9
	.word 4
.L.str9:
	.asciz " = ("
// length of .L.str10
	.word 3
.L.str10:
	.asciz "), "
// length of .L.str11
	.word 3
.L.str11:
	.asciz ") ]"
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
	adrp x19, .L.str0
	add x19, x19, :lo12:.L.str0
	mov w20, #5
	mov w21, #120
	mov w22, #1
	adrp x23, .L.str1
	add x23, x23, :lo12:.L.str1
	// 3 element array
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #3
	stur w8, [x16, #-4]
	mov w8, #1
	str w8, [x16]
	mov w8, #2
	str w8, [x16, #4]
	mov w8, #3
	str w8, [x16, #8]
	mov x24, x16
	// 3 element array
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #7
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #3
	stur w8, [x16, #-4]
	mov w8, #120
	strb w8, [x16]
	mov w8, #121
	strb w8, [x16, #1]
	mov w8, #122
	strb w8, [x16, #2]
	mov x28, x16
	// 3 element array
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #7
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #3
	stur w8, [x16, #-4]
	mov w8, #1
	strb w8, [x16]
	mov w8, #0
	strb w8, [x16, #1]
	mov w8, #1
	strb w8, [x16, #2]
	mov x0, x16
	// 3 element array
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #28
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #3
	stur w8, [x16, #-4]
	adrp x8, .L.str2
	add x8, x8, :lo12:.L.str2
	str x8, [x16]
	adrp x8, .L.str3
	add x8, x8, :lo12:.L.str3
	str x8, [x16, #8]
	adrp x8, .L.str4
	add x8, x8, :lo12:.L.str4
	str x8, [x16, #16]
	mov x1, x16
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	mov w8, #1
	str x8, [x16]
	mov w8, #2
	str x8, [x16, #8]
	mov x5, x16
	// Stack padded to a multiple of the required alignment
	sub sp, sp, #16
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	mov w8, #97
	str x8, [x16]
	mov w8, #1
	str x8, [x16, #8]
	mov x10, x16
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	mov w8, #98
	str x8, [x16]
	mov w8, #0
	str x8, [x16, #8]
	mov x11, x16
	// 2 element array
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #20
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #2
	stur w8, [x16, #-4]
	str x10, [x16]
	str x11, [x16, #8]
	mov x12, x16
	// Stack padded to a multiple of the required alignment
	sub sp, sp, #32
	// 3 element array
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #3
	stur w8, [x16, #-4]
	mov w8, #1
	str w8, [x16]
	mov w8, #2
	str w8, [x16, #4]
	mov w8, #3
	str w8, [x16, #8]
	stur x16, [fp, #-42]
	// 3 element array
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #7
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	// array pointers are shifted forwards by 4 bytes (to account for size)
	add x16, x16, #4
	mov w8, #3
	stur w8, [x16, #-4]
	mov w8, #97
	strb w8, [x16]
	mov w8, #98
	strb w8, [x16, #1]
	mov w8, #99
	strb w8, [x16, #2]
	stur x16, [fp, #-34]
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	mov w0, #16
	bl _malloc
	mov x16, x0
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	ldur x8, [fp, #-42]
	str x8, [x16]
	ldur x8, [fp, #-34]
	str x8, [x16, #8]
	stur x16, [fp, #-26]
	ldur x8, [fp, #-26]
	cmp x8, #0
	b.eq _errNull
	ldr x8, [x8]
	stur x8, [fp, #-18]
	ldur x8, [fp, #-26]
	cmp x8, #0
	b.eq _errNull
	ldr x8, [x8, #8]
	stur x8, [fp, #-10]
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str5
	add x0, x0, :lo12:.L.str5
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, #0
	ldur x8, [fp, #-18]
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x8
	bl _arrLoad4
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, #1
	ldur x8, [fp, #-18]
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x8
	bl _arrLoad4
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, #2
	ldur x8, [fp, #-18]
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x8
	bl _arrLoad4
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str6
	add x0, x0, :lo12:.L.str6
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, #0
	ldur x8, [fp, #-10]
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x8
	bl _arrLoad1
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, #1
	ldur x8, [fp, #-10]
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x8
	bl _arrLoad1
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, #2
	ldur x8, [fp, #-10]
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x8
	bl _arrLoad1
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str7
	add x0, x0, :lo12:.L.str7
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	// Stack padded to a multiple of the required alignment
	add sp, sp, #32
	mov w17, #0
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x12
	bl _arrLoad8
	mov x8, x7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov x13, x8
	cmp x13, #0
	b.eq _errNull
	ldr x14, [x13]
	cmp x13, #0
	b.eq _errNull
	ldr x15, [x13, #8]
	mov w17, #1
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x12
	bl _arrLoad8
	mov x8, x7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov x18, x8
	cmp x18, #0
	b.eq _errNull
	ldr x8, [x18]
	sturb w8, [fp, #-2]
	cmp x18, #0
	b.eq _errNull
	ldr x8, [x18, #8]
	sturb w8, [fp, #-1]
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str8
	add x0, x0, :lo12:.L.str8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x13
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printp
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str9
	add x0, x0, :lo12:.L.str9
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w14
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w15
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str10
	add x0, x0, :lo12:.L.str10
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x18
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printp
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str9
	add x0, x0, :lo12:.L.str9
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	ldurb w0, [fp, #-2]
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	ldurb w0, [fp, #-1]
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	adrp x0, .L.str11
	add x0, x0, :lo12:.L.str11
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	// Stack padded to a multiple of the required alignment
	add sp, sp, #16
	cmp x5, #0
	b.eq _errNull
	ldr x6, [x5]
	cmp x5, #0
	b.eq _errNull
	ldr x7, [x5, #8]
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w6
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w7
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	mov w17, #0
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x1
	bl _arrLoad8
	mov x8, x7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov x2, x8
	mov w17, #1
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x1
	bl _arrLoad8
	mov x8, x7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov x3, x8
	mov w17, #2
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x1
	bl _arrLoad8
	mov x8, x7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov x4, x8
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x2
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x3
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x4
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, #0
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x0
	bl _arrLoad1
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, #1
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x0
	bl _arrLoad1
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w17, #2
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x0
	bl _arrLoad1
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w0, w8
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x28
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
	mov w17, #0
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x24
	bl _arrLoad4
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w25, w8
	mov w17, #1
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x24
	bl _arrLoad4
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w26, w8
	mov w17, #2
	// push {x7}
	stp x7, xzr, [sp, #-16]!
	mov x7, x24
	bl _arrLoad4
	mov w8, w7
	// pop {x7}
	ldp x7, xzr, [sp], #16
	mov w27, w8
	// push {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	stp x0, x1, [sp, #-128]!
	stp x2, x3, [sp, #16]
	stp x4, x5, [sp, #32]
	stp x6, x7, [sp, #48]
	stp x10, x11, [sp, #64]
	stp x12, x13, [sp, #80]
	stp x14, x15, [sp, #96]
	stur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w25
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w26
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x19
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w27
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov x0, x23
	// statement primitives do not return results (but will clobber r0/rax)
	bl _prints
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w22
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printb
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w21
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printc
	bl _println
	# pop/peek {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	// Set up X16 as a temporary second base pointer for the caller saved things
	mov x16, sp
	mov w0, w20
	// statement primitives do not return results (but will clobber r0/rax)
	bl _printi
	bl _println
	// pop {x0, x1, x2, x3, x4, x5, x6, x7, x10, x11, x12, x13, x14, x15, x18}
	ldp x2, x3, [sp, #16]
	ldp x4, x5, [sp, #32]
	ldp x6, x7, [sp, #48]
	ldp x10, x11, [sp, #64]
	ldp x12, x13, [sp, #80]
	ldp x14, x15, [sp, #96]
	ldur x18, [sp, #112]
	ldp x0, x1, [sp], #128
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

_arrLoad1:
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
	ldrb w7, [x7, x17]
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

