	.data

	.global prompt
	.global mydataUART
	.global mydataGPIO
	.global xCount
	.global xPosition
	.global gameEnd

;any character over 80 is an ansi escapre sequence (see library for definitions)
;this is the main game board
clearScreen: .string 0x83, 27, "[2J", 0
promptTop:	.string 0xA, 0xD, 0x82, "                                                                                    ", 0
promptMiddle: .string 0xA, 0xD, 0x82, " ", 0x83, "                                                                                  ", 0x82, " ", 0
;these are the paddles as a whole
paddleLeft:	.string 0x84, 0
paddleRight: .string 0x85, 0
;these are cursor sequences to move paddles up/down
leftPaddleUpOne: .string 0x86, 0
leftPaddleDownOne: .string 0x87, 0
rightPaddleUpOne: .string 0x88, 0
rightPaddleDownOne: .string 0x89, 0

unpauseprompt: .string 0xA, 0xD, "The game is paused. Press SW1 on the Tiva board to unpause.", 0xA, 0xD, 0
mydataUART:	.byte	0x20	; This is where you can store data.
mydataGPIO:	.byte	0x30
xCount: .byte 0x1
isitpaused: .byte 0x00
xPosition: .word 0x20000106
gameEnd: .byte 0x00
gameOverScreen:	.string 0xC, "GAME OVER", 0
scorePrompt:	.string "Score: ", 0
score:	.byte 0x0


			; The .byte assembler directive stores a byte
			; (initialized to 0x20 in this case) at the label
			; mydata.  Halfwords & Words can be stored using the
			; directives .half & .word

	.text

	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler		; This is needed for Lab #6
	.global simple_read_character	; read_character modified for interrupts
	.global output_character	; This is from your Lab #4 Library
	.global output_ansi
	.global read_string		; This is from your Lab #4 Library
	.global output_string		; This is from your Lab #4 Library
	.global uart_init		; This is from your Lab #4 Library
	.global illuminate_RGB_LED
	.global read_tiva_pushbutton
	.global gpio_btn_and_LED_init
	.global lab7
	.global string2int
	.global int2string


ptr_to_clearScreen:	.word clearScreen
ptr_to_promptTop:		.word promptTop
ptr_to_promptMiddle:	.word promptMiddle
ptr_to_paddleLeft:			.word paddleLeft
ptr_to_paddleRight:		.word paddleRight
ptr_to_leftPaddleUpOne: .word leftPaddleUpOne
ptr_to_leftPaddleDownOne: .word leftPaddleDownOne
ptr_to_rightPaddleUpOne: .word rightPaddleUpOne
ptr_to_rightPaddleDownOne: .word rightPaddleDownOne

ptr_to_mydataUART:		.word mydataUART
ptr_to_mydataGPIO:		.word mydataGPIO
ptr_to_xCount:			.word xCount
ptr_to_isitpaused: 		.word isitpaused
ptr_to_unpauseprompt: 	.word unpauseprompt
ptr_to_xPosition:		.word xPosition
ptr_to_gameEnd:			.word gameEnd
ptr_to_gameOverScreen:	.word gameOverScreen
ptr_to_scorePrompt:		.word scorePrompt
ptr_to_score:			.word score


lab7:				; This is your main routine which is called from
				; your C wrapper.
	PUSH {r4-r12,lr}   	; Preserve registers to adhere to the AAPCS
begin:
	;reset everything


	;ldr r5, ptr_to_mydataUART
	;MOV r1, #0x20
	;STRB r1, [r5]

	;ldr r6, ptr_to_mydataGPIO
	;MOV r1, #0x30
	;STRB r1, [r6]

 	bl uart_init
 	BL gpio_btn_and_LED_init
	bl uart_interrupt_init ;this is fine, interrupt handler no BL
	bl gpio_interrupt_init
	bl timer_init

	ldr r0, ptr_to_clearScreen
	bl output_string

;nested for loop to print board
print_board:
	MOV r6, #24 ;counter
	;print the top border once
	ldr r0, ptr_to_promptTop
	BL output_string
boardloop:
	;print the middle border 24 times
	ldr r0, ptr_to_promptMiddle
	BL output_string
	SUB r6, r6, #1
	CMP r6, #0
	BGE boardloop

	;print the border again (bottom)
	ldr r0, ptr_to_promptTop
	BL output_string

	;print the paddles
	ldr r0, ptr_to_paddleLeft
	BL output_string
	ldr r0, ptr_to_paddleRight
	BL output_string


	;game loop that allows it to be interrupted
	MOV r1, #0xFFFF
	MOVT r1, #0x7FFF
lab7_loop:
	SUB r1, r1, #1
	CMP r1, #0
	BGT lab7_loop
	;check if game is paused
	;ldr r9, ptr_to_isitpaused
	;LDRB r10, [r9]
	;CMP r10, #1
	;BEQ gamePaused

	;ldr r7, ptr_to_gameEnd
	;LDRB r8, [r7]
	;CMP r8, #0
	;BEQ lab7_loop
	;B lab7Done

;gamePaused:
	;loop while game paused else return to lab7 loop
	;ldr r9, ptr_to_isitpaused
	;LDRB r10, [r9]
	;CMP r10, #1
	;BEQ gamePaused
	;B lab7_loop

lab7Done:
	POP {r4-r12,lr}		; Restore registers to adhere to the AAPCS
	MOV pc, lr



uart_interrupt_init:
	PUSH {r4-r12,lr} ; Spill registers to stack

	MOV r0, #0xC000
	MOVT r0, #0x4000 		;UART interrupt mask register address
	LDRB r1, [r0, #0x038]	;read from address + offset
	ORR r1, r1, #0x10		;set bit 4 to 1
	STRB r1, [r0, #0x038] 	;write to enable UART interrupt

	MOV r0, #0xE000
	MOVT r0, #0xE000 		;UART set enable register address
	LDRB r1, [r0, #0x100]	;read from address + offset
	ORR r1, r1, #0x20		;set bit 5 to 1
	STRB r1, [r0, #0x100] 	;write to enable UART interrupt


	POP {r4-r12,lr} ; Restore registers from stack
	MOV pc, lr


gpio_interrupt_init:
	PUSH {r4-r12,lr} ; Spill registers to stack

	;enable edge sensitive via GPIOIS (write 0)
	MOV r0, #0x5000
	MOVT r0, #0x4002 ;r0 = base adrr 0x40025000
	MOV r1, #1 ;r1 = mask pin 4 = 0 (1 0000)
	LSL r1, r1, #4 ;pin 4
	MVN r1, r1 ;clear -> not it and move into r1 (complement)
	;do i load, and it, and then store that?? (to not affect other bits)
	LDR r2, [r0, #0x404]
	AND r1, r1, r2
	STR r2, [r0, #0x404] ;GPIOIS offset

	;allow GPIOEV det (0) both/single edge triggering via GPIOIBE
	;r0 base address remains same
	MOV r1, #1 ;r1 = mask pin 4 = 0 (1 0000)
	LSL r1, r1, #4 ;pin 4
	MVN r1, r1 ;clear -> not it and move into r1 (complement)
	;do i load, and it, and then store that?? (to not affect other bits)
	LDR r2, [r0, #0x408]
	AND r1, r1, r2
	STR r1, [r0, #0x408] ;GPIOIBE offset

	;select edge (0) for interrupt triggering (falling/button pressed) via GPIOIV
	;r0 base addr stays same
	MOV r1, #1 ;r1 = mask pin 4 = 0 (1 0000)
	LSL r1, r1, #4 ;pin 4
	MVN r1, r1 ;clear -> not it and move into r1 (complement)
	;do i load, and it, and then store that?? (to not affect other bits)
	LDR r2, [r0, #0x40C]
	AND r1, r1, r2
	STR r1, [r0, #0x40C] ;GPIOIV offset

	;enable (1) interrupt via GPIO interrupt mask
	;r0 base addr remain same
	MOV r1, #1 ;r1 = mask pin 4 = 0 (1 0000)
	LSL r1, r1, #4 ;pin 4
	;do i load it then or it?
	LDR r2, [r0, #0x410]
	ORR r1, r1, r2 ;set only that bit, put in r1
	STR r1, [r0, #0x410] ;GPIOIM offset

	;configure processor to allow GPIO port F to interrupt processor (set to 1)
	MOV r0, #0xE000
	MOVT r0, #0xE000 ;r0 = 0xE000E000 (EN0 base addr)
	MOV r1, #1
	LSL r1, r1, #30 ;shift it 30 bits (pin 30)
	LDR r2, [r0, #0x100]
	ORR r1, r1, r2 ;set only that but, put in r1
	STR r1, [r0, #0x100] ;EN0 offset

	;init SW1 here <lab 4 procedure> - can we just call gpio init subr?
	;BL gpio_btn_and_LED_init ;make sure it's in lab5 library

	POP {r4-r12,lr} ; Restore registers from stack
	MOV pc, lr

timer_init:
	PUSH {r4-r12,lr} ; Spill registers to stack

	MOV r0, #0xE000
	MOVT r0, #0x400F	;base address of RCGCTIMER
	LDRB r1, [r0, #0x604]	;read from address + offset
	ORR r1, r1, #0x1		;set bit 0 to 1
	STRB r1, [r0, #0x604]

	MOV r0, #0x0000
	MOVT r0, #0x4003		;address of GPTMCTL
	LDRB r1, [r0, #0x00C]	;read from address + offset
	AND r1, r1, #0xFE		;0xFE = 1111 1110, so we are only changing the 0th bit to 0
	STRB r1, [r0, #0x00C]

	MOV r0, #0x0000
	MOVT r0, #0x4003		;address of GPTMCFG
	LDRB r1, [r0, #0x000]	;read from address + offset
	AND r1, r1, #0
	STRB r1, [r0, #0x000]

	MOV r0, #0x0000
	MOVT r0, #0x4003		;address of GPTMTAMR
	LDRB r1, [r0, #0x004]	;read from address + offset
	AND r1, r1, #0xFE		;change the 0th bit to 0
	ORR r1, r1, #0x2		;set 1st bit to 1 (10)
	STRB r1, [r0, #0x004]

	MOV r0, #0x0000
	MOVT r0, #0x4003		;address of GPTMTAILR
	MOV r1, #0x1200
	MOVT r1, #0x007A
	STR r1, [r0, #0x28]

	MOV r0, #0x0000
	MOVT r0, #0x4003		;address of GPTMIMR
	LDRB r1, [r0, #0x018]	;read from address + offset
	ORR r1, r1, #0x1		;set 0th bit to 1
	STRB r1, [r0, #0x018]

	MOV r0, #0xE000
	MOVT r0, #0xE000 		;r0 = 0xE000E000 (EN0 base addr)
	MOV r1, #1
	LSL r1, r1, #19 		;shift it 19 bits (pin 19)
	LDR r2, [r0, #0x100]
	ORR r1, r1, r2 			;set only that but, put in r1
	STR r1, [r0, #0x100] 	;EN0 offset

	MOV r0, #0x0000
	MOVT r0, #0x4003		;address of GPTMCTL
	LDRB r1, [r0, #0x00C]	;read from address + offset
	ORR r1, #0x1			;set 0th bit to 1
	STRB r1, [r0, #0x00C]	;enable TAEN


	POP {r4-r12,lr} ; Restore registers from stack
	MOV pc, lr

UART0_Handler:
	PUSH {r4-r12,lr} ; Spill registers to stack

	MOV r0, #0xC000
	MOVT r0, #0x4000 		;UART interrupt register address
	LDRB r1, [r0, #0x044]	;read from address + offset
	ORR r1, r1, #0x10		;set bit 4 to 1
	STRB r1, [r0, #0x044] 	;write to enable UART interrupt
	BL simple_read_character

	CMP r0, #0x77				;checking if char is w
	BEQ w_left_paddle_up		;branch if char is w to move L paddle up

	CMP r0, #0x73			;checking if char is s
	BEQ s_left_paddle_down		;branch if char is s to move L paddle down

	CMP r0, #0x69			;checking if char is i
	BEQ i_right_paddle_up		;branch if char is i to move R paddle up

	CMP r0, #0x6b			;checking if char is k
	BEQ k_right_paddle_down		;branch if char is k to set to 3
	B uartdone ;theoretically never runs but just in case

w_left_paddle_up:
	;redraw left paddle 1 space up using cursor
	ldr r0, ptr_to_leftPaddleUpOne
	BL output_string
	B uartdone

s_left_paddle_down:
	;redraw left paddle 1 space down using cursor
	ldr r0, ptr_to_leftPaddleDownOne
	BL output_string
	B uartdone

i_right_paddle_up:
	;redraw right paddle 1 space up using cursor
	ldr r0, ptr_to_rightPaddleUpOne
	BL output_string
	B uartdone

k_right_paddle_down:
	;redraw right paddle 1 space down using cursor
	ldr r0, ptr_to_rightPaddleDownOne
	BL output_string
	B uartdone

uartdone:
	POP {r4-r12,lr} ; Restore registers from stack
	BX lr       	; Return


Switch_Handler:
	PUSH {r4-r12,lr} ; Spill registers to stack

	;Q: should i be using STRB instead of STR?

	;clear interrupt via GPIOICR (write 1)
	MOV r0, #0x5000
	MOVT r0, #0x4002 ;r0 = 40025000 (GPIOICR base addr)
	MOV r1, #1 ;r1 contains the mask
	LSL r1, r1, #4 ;bit 4 so shift 4
	LDR r2, [r0, #0x41C] ;offset for GPIOICR - load whats there alr
	ORR r1, r2, r1 ;or it and put in r1 to set that bit to 1
	STR r1, [r0, #0x41C] ;write to the pin

	LDR r4, ptr_to_unpauseprompt
	LDR r7, ptr_to_isitpaused
	ldrb r8, [r7]
	CMP r8, #0		;if its already a 0, it is currently unpaused
	BEQ pauseit		;so go pause it
	MOV r9, #0		;if not it is paused, so unpause it
	strb r9, [r7]
	B switchDone

pauseit:
	MOV r9, #1		;set to 1 to indicate it is paused
	strb r9, [r7]
	MOV r0, r4
	BL output_string

switchDone:
	POP {r4-r12,lr} ; Restore registers from stack
	BX lr       	; Return


Timer_Handler:
	PUSH {r4-r12,lr} ; Spill registers to stack

	;clear interrupt via GPTMICR
	MOV r0, #0x0000			;base address of timer 0
	MOVT r0, #0x4003		;address of GPTMICR
	LDRB r1, [r0, #0x024]	;read from address + offset
	ORR r1, #0x1			;set 0th bit to 1
	STRB r1, [r0, #0x024]	;write 1 to TATOCINT


end:
	POP {r4-r12,lr} ; Restore registers from stack
	BX lr       	; Return


simple_read_character:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
				; that are used in your routine.  Include lr if this
				; routine calls another routine.


	MOV r1, #0xC000
	MOVT r1, #0x4000 ;UART0 data register
	;AND r3, r2, #0x10 - do  we need this?

	LDRB r0, [r1]
	;returns in r0

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	MOV pc, lr


	.end
