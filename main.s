;******************** (C) Yifeng ZHU *******************************************
; @file    main.s
; @author  Yifeng Zhu
; @date    May-17-2015
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633
; @attension
;           This code is provided for education purpose. The author shall not be 
;           held liable for any direct, indirect or consequential damages, for any 
;           reason whatever. More information can be found from book website: 
;           http:;www.eece.maine.edu/~zhu/book
;*******************************************************************************


	INCLUDE core_cm4_constants.s
	INCLUDE stm32l476xx_constants.s
	
	AREA    main, CODE, READONLY
	EXPORT	__main
	ENTRY			
				
__main	PROC

; Enable the clock to GPIO Port A	
	LDR r4, =RCC_BASE ; Load Register r4 from memory with data stored on RCC_BASE 
					  ;RCC_BASE = 0x40000000+0x00020000+0x1000 = 0x40021000, Mem(0x40021000) -> r0 
	
	LDR r5, [r4, #RCC_AHB2ENR] ; Load Register r5 from memory with the data stored at r4+RCC_AHB2ENR (RCC_BASE+0x4c)
	                           ; Mem(0x4002104c) -> r1
	ORR r5, r5, #RCC_AHB2ENR_GPIOBEN ; r5 | 0x00000001 (RCC_AHB2ENR_GPIOBEN) -> r1 ;
	ORR r5, r5, #RCC_AHB2ENR_GPIOCEN ; 
	STR r5, [r4, #RCC_AHB2ENR] ; store r5 to r0+RCC_AHB2ENR r1 -> Mem(0x4002104c)
	
    LDR r0, =GPIOB_BASE       
    LDR r1, [r0, #GPIO_PUPDR] ;Load GPIOB_PUPDR into r1
    AND r1, r1, #0xFFF00FFF   ;Clear out target bits 
	AND r1, r1, #0xFFFFF00F   ;Clear out target bits
	AND r1, r1, #0xFFFFFFF0   ;Clear out target bits
    ORR r1, r1, #0x00015000   ;GPIOB pins 0-9 to pull-up
	ORR r1, r1, #0x00000550   ;GPIOB pins to pull-up
	ORR r1, r1, #0x00000005   ;GPIOB pins to pull-up
    STR r1, [r0, #GPIO_PUPDR] ;Put value back into memory
    LDR r1, [r0, #GPIO_OTYPER] ;Load GPIOB_OTYPE into r1
    ORR r1, r1, #0x00000300   ;set to open drain
	ORR r1, r1, #0x000000FF   ;set to open drain
    STR r1, [r0, #GPIO_OTYPER] ;Store OTYPE value back to memory
	LDR r1, [r0, #GPIO_MODER]
	AND r1, r1, #0xFFF0FFFF
	AND r1, r1, #0xFFFF00FF
	AND r1, r1, #0xFFFFFF00
	ORR r1, r1, #0x00050000
	ORR r1, r1, #0x00005500
	ORR r1, r1, #0x00000055 ; Set GPIOB to output
	STR r1, [r0, #GPIO_MODER]
	
	LDR r2, =GPIOC_BASE
	LDR r3, [r2, #GPIO_PUPDR] ;Load GPIOC_PUPDR into r3
	ORR r3, r3, #0x01500000 ; set GPIOC pins to pull-up
	STR r3, [r2, #GPIO_PUPDR] ;Store GPIOC_PUPDR
	LDR r1, [r2, #GPIO_MODER]
	AND r1, r1, #0xFC0FFFFF ;Set GPIOC to input
	STR r1, [r2, #GPIO_MODER]
	
	
	
	MOV r10, #0x1 ; set state to 1
	MOV r11, #0x0 ; set count to 0
lp  MOV r8, #0x0003D000 ; set delay to 0
    ORR r8, r8, #0x00000090
	;ORR r8, r8, #0x00000080
del	SUBS r8, #1 
	BNE del
	CMP r10, #0x0 ; compare to green state
	BEQ gr
	CMP r10, #0x1 ; compare to yellow state
	BEQ yw
gr  LDR r3, [r0, #GPIO_ODR] ; load the output
	ADD r11, #0x1 ; add 1 to count
	MVN r12, r11 ; negate for active low
	STR r12, [r0, #GPIO_ODR] ;store count to output
	LDR r3, [r2, #GPIO_IDR] ;load button inputs
	AND r3, r3, #0x00001c00 ; get only the input bits
	CMP r3, #0x00000C00 ; see if red is pressed pc(11)
	BNE noR
	MOV r11, #0x0 ; reset count
	MVN r11, r11
	STR r11, [r0, #GPIO_ODR]
noR	CMP r3, #0x00001400 ;see if yellow is pressed pc(12)
	BNE noY 
	MOV r10, #0x1 ; set state to yellow pause state
noY B lp
yw  LDR r3, [r2, #GPIO_IDR] ; load inputs
	AND r3, r3, #0x00001c00 ; get only the input bits
	CMP r3, #0x00000C00 ; see if red is pressed pc(11)
	BNE nRD
	MOV r11, #0x0 ; reset count
	MVN r11, r11
	STR r11, [r0, #GPIO_ODR]
nRD CMP r3, #0x00001800 ; check if green is pressed pc(10)
	BNE noG
	MOV r10, #0x0 ; set state to green
noG B lp
	
		ENDP
		
	ALIGN
	
	END
