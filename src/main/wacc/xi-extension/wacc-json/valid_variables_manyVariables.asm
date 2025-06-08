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
	sub sp, sp, #928
	mov w19, #0
	mov w20, #1
	mov w21, #2
	mov w22, #3
	mov w23, #4
	mov w24, #5
	mov w25, #6
	mov w26, #7
	mov w27, #8
	mov w28, #9
	mov w0, #10
	mov w1, #11
	mov w2, #12
	mov w3, #13
	mov w4, #14
	mov w5, #15
	mov w6, #16
	mov w7, #17
	mov w10, #18
	mov w11, #19
	mov w12, #20
	mov w13, #21
	mov w14, #22
	mov w15, #23
	mov w18, #24
	mov w8, #25
	mov x17, #-928
	str w8, [fp, x17]
	mov w8, #26
	mov x17, #-924
	str w8, [fp, x17]
	mov w8, #27
	mov x17, #-920
	str w8, [fp, x17]
	mov w8, #28
	mov x17, #-916
	str w8, [fp, x17]
	mov w8, #29
	mov x17, #-912
	str w8, [fp, x17]
	mov w8, #30
	mov x17, #-908
	str w8, [fp, x17]
	mov w8, #31
	mov x17, #-904
	str w8, [fp, x17]
	mov w8, #32
	mov x17, #-900
	str w8, [fp, x17]
	mov w8, #33
	mov x17, #-896
	str w8, [fp, x17]
	mov w8, #34
	mov x17, #-892
	str w8, [fp, x17]
	mov w8, #35
	mov x17, #-888
	str w8, [fp, x17]
	mov w8, #36
	mov x17, #-884
	str w8, [fp, x17]
	mov w8, #37
	mov x17, #-880
	str w8, [fp, x17]
	mov w8, #38
	mov x17, #-876
	str w8, [fp, x17]
	mov w8, #39
	mov x17, #-872
	str w8, [fp, x17]
	mov w8, #40
	mov x17, #-868
	str w8, [fp, x17]
	mov w8, #41
	mov x17, #-864
	str w8, [fp, x17]
	mov w8, #42
	mov x17, #-860
	str w8, [fp, x17]
	mov w8, #43
	mov x17, #-856
	str w8, [fp, x17]
	mov w8, #44
	mov x17, #-852
	str w8, [fp, x17]
	mov w8, #45
	mov x17, #-848
	str w8, [fp, x17]
	mov w8, #46
	mov x17, #-844
	str w8, [fp, x17]
	mov w8, #47
	mov x17, #-840
	str w8, [fp, x17]
	mov w8, #48
	mov x17, #-836
	str w8, [fp, x17]
	mov w8, #49
	mov x17, #-832
	str w8, [fp, x17]
	mov w8, #50
	mov x17, #-828
	str w8, [fp, x17]
	mov w8, #51
	mov x17, #-824
	str w8, [fp, x17]
	mov w8, #52
	mov x17, #-820
	str w8, [fp, x17]
	mov w8, #53
	mov x17, #-816
	str w8, [fp, x17]
	mov w8, #54
	mov x17, #-812
	str w8, [fp, x17]
	mov w8, #55
	mov x17, #-808
	str w8, [fp, x17]
	mov w8, #56
	mov x17, #-804
	str w8, [fp, x17]
	mov w8, #57
	mov x17, #-800
	str w8, [fp, x17]
	mov w8, #58
	mov x17, #-796
	str w8, [fp, x17]
	mov w8, #59
	mov x17, #-792
	str w8, [fp, x17]
	mov w8, #60
	mov x17, #-788
	str w8, [fp, x17]
	mov w8, #61
	mov x17, #-784
	str w8, [fp, x17]
	mov w8, #62
	mov x17, #-780
	str w8, [fp, x17]
	mov w8, #63
	mov x17, #-776
	str w8, [fp, x17]
	mov w8, #64
	mov x17, #-772
	str w8, [fp, x17]
	mov w8, #65
	mov x17, #-768
	str w8, [fp, x17]
	mov w8, #66
	mov x17, #-764
	str w8, [fp, x17]
	mov w8, #67
	mov x17, #-760
	str w8, [fp, x17]
	mov w8, #68
	mov x17, #-756
	str w8, [fp, x17]
	mov w8, #69
	mov x17, #-752
	str w8, [fp, x17]
	mov w8, #70
	mov x17, #-748
	str w8, [fp, x17]
	mov w8, #71
	mov x17, #-744
	str w8, [fp, x17]
	mov w8, #72
	mov x17, #-740
	str w8, [fp, x17]
	mov w8, #73
	mov x17, #-736
	str w8, [fp, x17]
	mov w8, #74
	mov x17, #-732
	str w8, [fp, x17]
	mov w8, #75
	mov x17, #-728
	str w8, [fp, x17]
	mov w8, #76
	mov x17, #-724
	str w8, [fp, x17]
	mov w8, #77
	mov x17, #-720
	str w8, [fp, x17]
	mov w8, #78
	mov x17, #-716
	str w8, [fp, x17]
	mov w8, #79
	mov x17, #-712
	str w8, [fp, x17]
	mov w8, #80
	mov x17, #-708
	str w8, [fp, x17]
	mov w8, #81
	mov x17, #-704
	str w8, [fp, x17]
	mov w8, #82
	mov x17, #-700
	str w8, [fp, x17]
	mov w8, #83
	mov x17, #-696
	str w8, [fp, x17]
	mov w8, #84
	mov x17, #-692
	str w8, [fp, x17]
	mov w8, #85
	mov x17, #-688
	str w8, [fp, x17]
	mov w8, #86
	mov x17, #-684
	str w8, [fp, x17]
	mov w8, #87
	mov x17, #-680
	str w8, [fp, x17]
	mov w8, #88
	mov x17, #-676
	str w8, [fp, x17]
	mov w8, #89
	mov x17, #-672
	str w8, [fp, x17]
	mov w8, #90
	mov x17, #-668
	str w8, [fp, x17]
	mov w8, #91
	mov x17, #-664
	str w8, [fp, x17]
	mov w8, #92
	mov x17, #-660
	str w8, [fp, x17]
	mov w8, #93
	mov x17, #-656
	str w8, [fp, x17]
	mov w8, #94
	mov x17, #-652
	str w8, [fp, x17]
	mov w8, #95
	mov x17, #-648
	str w8, [fp, x17]
	mov w8, #96
	mov x17, #-644
	str w8, [fp, x17]
	mov w8, #97
	mov x17, #-640
	str w8, [fp, x17]
	mov w8, #98
	mov x17, #-636
	str w8, [fp, x17]
	mov w8, #99
	mov x17, #-632
	str w8, [fp, x17]
	mov w8, #100
	mov x17, #-628
	str w8, [fp, x17]
	mov w8, #101
	mov x17, #-624
	str w8, [fp, x17]
	mov w8, #102
	mov x17, #-620
	str w8, [fp, x17]
	mov w8, #103
	mov x17, #-616
	str w8, [fp, x17]
	mov w8, #104
	mov x17, #-612
	str w8, [fp, x17]
	mov w8, #105
	mov x17, #-608
	str w8, [fp, x17]
	mov w8, #106
	mov x17, #-604
	str w8, [fp, x17]
	mov w8, #107
	mov x17, #-600
	str w8, [fp, x17]
	mov w8, #108
	mov x17, #-596
	str w8, [fp, x17]
	mov w8, #109
	mov x17, #-592
	str w8, [fp, x17]
	mov w8, #110
	mov x17, #-588
	str w8, [fp, x17]
	mov w8, #111
	mov x17, #-584
	str w8, [fp, x17]
	mov w8, #112
	mov x17, #-580
	str w8, [fp, x17]
	mov w8, #113
	mov x17, #-576
	str w8, [fp, x17]
	mov w8, #114
	mov x17, #-572
	str w8, [fp, x17]
	mov w8, #115
	mov x17, #-568
	str w8, [fp, x17]
	mov w8, #116
	mov x17, #-564
	str w8, [fp, x17]
	mov w8, #117
	mov x17, #-560
	str w8, [fp, x17]
	mov w8, #118
	mov x17, #-556
	str w8, [fp, x17]
	mov w8, #119
	mov x17, #-552
	str w8, [fp, x17]
	mov w8, #120
	mov x17, #-548
	str w8, [fp, x17]
	mov w8, #121
	mov x17, #-544
	str w8, [fp, x17]
	mov w8, #122
	mov x17, #-540
	str w8, [fp, x17]
	mov w8, #123
	mov x17, #-536
	str w8, [fp, x17]
	mov w8, #124
	mov x17, #-532
	str w8, [fp, x17]
	mov w8, #125
	mov x17, #-528
	str w8, [fp, x17]
	mov w8, #126
	mov x17, #-524
	str w8, [fp, x17]
	mov w8, #127
	mov x17, #-520
	str w8, [fp, x17]
	mov w8, #128
	mov x17, #-516
	str w8, [fp, x17]
	mov w8, #129
	mov x17, #-512
	str w8, [fp, x17]
	mov w8, #130
	mov x17, #-508
	str w8, [fp, x17]
	mov w8, #131
	mov x17, #-504
	str w8, [fp, x17]
	mov w8, #132
	mov x17, #-500
	str w8, [fp, x17]
	mov w8, #133
	mov x17, #-496
	str w8, [fp, x17]
	mov w8, #134
	mov x17, #-492
	str w8, [fp, x17]
	mov w8, #135
	mov x17, #-488
	str w8, [fp, x17]
	mov w8, #136
	mov x17, #-484
	str w8, [fp, x17]
	mov w8, #137
	mov x17, #-480
	str w8, [fp, x17]
	mov w8, #138
	mov x17, #-476
	str w8, [fp, x17]
	mov w8, #139
	mov x17, #-472
	str w8, [fp, x17]
	mov w8, #140
	mov x17, #-468
	str w8, [fp, x17]
	mov w8, #141
	mov x17, #-464
	str w8, [fp, x17]
	mov w8, #142
	mov x17, #-460
	str w8, [fp, x17]
	mov w8, #143
	mov x17, #-456
	str w8, [fp, x17]
	mov w8, #144
	mov x17, #-452
	str w8, [fp, x17]
	mov w8, #145
	mov x17, #-448
	str w8, [fp, x17]
	mov w8, #146
	mov x17, #-444
	str w8, [fp, x17]
	mov w8, #147
	mov x17, #-440
	str w8, [fp, x17]
	mov w8, #148
	mov x17, #-436
	str w8, [fp, x17]
	mov w8, #149
	mov x17, #-432
	str w8, [fp, x17]
	mov w8, #150
	mov x17, #-428
	str w8, [fp, x17]
	mov w8, #151
	mov x17, #-424
	str w8, [fp, x17]
	mov w8, #152
	mov x17, #-420
	str w8, [fp, x17]
	mov w8, #153
	mov x17, #-416
	str w8, [fp, x17]
	mov w8, #154
	mov x17, #-412
	str w8, [fp, x17]
	mov w8, #155
	mov x17, #-408
	str w8, [fp, x17]
	mov w8, #156
	mov x17, #-404
	str w8, [fp, x17]
	mov w8, #157
	mov x17, #-400
	str w8, [fp, x17]
	mov w8, #158
	mov x17, #-396
	str w8, [fp, x17]
	mov w8, #159
	mov x17, #-392
	str w8, [fp, x17]
	mov w8, #160
	mov x17, #-388
	str w8, [fp, x17]
	mov w8, #161
	mov x17, #-384
	str w8, [fp, x17]
	mov w8, #162
	mov x17, #-380
	str w8, [fp, x17]
	mov w8, #163
	mov x17, #-376
	str w8, [fp, x17]
	mov w8, #164
	mov x17, #-372
	str w8, [fp, x17]
	mov w8, #165
	mov x17, #-368
	str w8, [fp, x17]
	mov w8, #166
	mov x17, #-364
	str w8, [fp, x17]
	mov w8, #167
	mov x17, #-360
	str w8, [fp, x17]
	mov w8, #168
	mov x17, #-356
	str w8, [fp, x17]
	mov w8, #169
	mov x17, #-352
	str w8, [fp, x17]
	mov w8, #170
	mov x17, #-348
	str w8, [fp, x17]
	mov w8, #171
	mov x17, #-344
	str w8, [fp, x17]
	mov w8, #172
	mov x17, #-340
	str w8, [fp, x17]
	mov w8, #173
	mov x17, #-336
	str w8, [fp, x17]
	mov w8, #174
	mov x17, #-332
	str w8, [fp, x17]
	mov w8, #175
	mov x17, #-328
	str w8, [fp, x17]
	mov w8, #176
	mov x17, #-324
	str w8, [fp, x17]
	mov w8, #177
	mov x17, #-320
	str w8, [fp, x17]
	mov w8, #178
	mov x17, #-316
	str w8, [fp, x17]
	mov w8, #179
	mov x17, #-312
	str w8, [fp, x17]
	mov w8, #180
	mov x17, #-308
	str w8, [fp, x17]
	mov w8, #181
	mov x17, #-304
	str w8, [fp, x17]
	mov w8, #182
	mov x17, #-300
	str w8, [fp, x17]
	mov w8, #183
	mov x17, #-296
	str w8, [fp, x17]
	mov w8, #184
	mov x17, #-292
	str w8, [fp, x17]
	mov w8, #185
	mov x17, #-288
	str w8, [fp, x17]
	mov w8, #186
	mov x17, #-284
	str w8, [fp, x17]
	mov w8, #187
	mov x17, #-280
	str w8, [fp, x17]
	mov w8, #188
	mov x17, #-276
	str w8, [fp, x17]
	mov w8, #189
	mov x17, #-272
	str w8, [fp, x17]
	mov w8, #190
	mov x17, #-268
	str w8, [fp, x17]
	mov w8, #191
	mov x17, #-264
	str w8, [fp, x17]
	mov w8, #192
	mov x17, #-260
	str w8, [fp, x17]
	mov w8, #193
	stur w8, [fp, #-256]
	mov w8, #194
	stur w8, [fp, #-252]
	mov w8, #195
	stur w8, [fp, #-248]
	mov w8, #196
	stur w8, [fp, #-244]
	mov w8, #197
	stur w8, [fp, #-240]
	mov w8, #198
	stur w8, [fp, #-236]
	mov w8, #199
	stur w8, [fp, #-232]
	mov w8, #200
	stur w8, [fp, #-228]
	mov w8, #201
	stur w8, [fp, #-224]
	mov w8, #202
	stur w8, [fp, #-220]
	mov w8, #203
	stur w8, [fp, #-216]
	mov w8, #204
	stur w8, [fp, #-212]
	mov w8, #205
	stur w8, [fp, #-208]
	mov w8, #206
	stur w8, [fp, #-204]
	mov w8, #207
	stur w8, [fp, #-200]
	mov w8, #208
	stur w8, [fp, #-196]
	mov w8, #209
	stur w8, [fp, #-192]
	mov w8, #210
	stur w8, [fp, #-188]
	mov w8, #211
	stur w8, [fp, #-184]
	mov w8, #212
	stur w8, [fp, #-180]
	mov w8, #213
	stur w8, [fp, #-176]
	mov w8, #214
	stur w8, [fp, #-172]
	mov w8, #215
	stur w8, [fp, #-168]
	mov w8, #216
	stur w8, [fp, #-164]
	mov w8, #217
	stur w8, [fp, #-160]
	mov w8, #218
	stur w8, [fp, #-156]
	mov w8, #219
	stur w8, [fp, #-152]
	mov w8, #220
	stur w8, [fp, #-148]
	mov w8, #221
	stur w8, [fp, #-144]
	mov w8, #222
	stur w8, [fp, #-140]
	mov w8, #223
	stur w8, [fp, #-136]
	mov w8, #224
	stur w8, [fp, #-132]
	mov w8, #225
	stur w8, [fp, #-128]
	mov w8, #226
	stur w8, [fp, #-124]
	mov w8, #227
	stur w8, [fp, #-120]
	mov w8, #228
	stur w8, [fp, #-116]
	mov w8, #229
	stur w8, [fp, #-112]
	mov w8, #230
	stur w8, [fp, #-108]
	mov w8, #231
	stur w8, [fp, #-104]
	mov w8, #232
	stur w8, [fp, #-100]
	mov w8, #233
	stur w8, [fp, #-96]
	mov w8, #234
	stur w8, [fp, #-92]
	mov w8, #235
	stur w8, [fp, #-88]
	mov w8, #236
	stur w8, [fp, #-84]
	mov w8, #237
	stur w8, [fp, #-80]
	mov w8, #238
	stur w8, [fp, #-76]
	mov w8, #239
	stur w8, [fp, #-72]
	mov w8, #240
	stur w8, [fp, #-68]
	mov w8, #241
	stur w8, [fp, #-64]
	mov w8, #242
	stur w8, [fp, #-60]
	mov w8, #243
	stur w8, [fp, #-56]
	mov w8, #244
	stur w8, [fp, #-52]
	mov w8, #245
	stur w8, [fp, #-48]
	mov w8, #246
	stur w8, [fp, #-44]
	mov w8, #247
	stur w8, [fp, #-40]
	mov w8, #248
	stur w8, [fp, #-36]
	mov w8, #249
	stur w8, [fp, #-32]
	mov w8, #250
	stur w8, [fp, #-28]
	mov w8, #251
	stur w8, [fp, #-24]
	mov w8, #252
	stur w8, [fp, #-20]
	mov w8, #253
	stur w8, [fp, #-16]
	mov w8, #254
	stur w8, [fp, #-12]
	mov w8, #255
	stur w8, [fp, #-8]
	mov w8, #256
	stur w8, [fp, #-4]
	add sp, sp, #928
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

