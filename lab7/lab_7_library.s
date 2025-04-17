	.data
currRowL: .byte 0x10 ;current row of cursor (start = 16)
currRowR: .byte 0x10 ;current row of cursor (start = 16)

	;0x81 is our go back character - sub 80 later
	;there is no lt1, matches the offset so less confusing
lookUpTable2: .string 27, "[48;5;248m", 0x81 ;0x82 (offset 2) gray
lookUpTable3: .string 27, "[40m", 0x81	;0x83 (offset 3) black space
lookUpTable4: .string 27, "[16;2H", 27, "[41m ", 27, "[17;2H", 27, "[41m ", 27, "[18;2H", 27, "[41m ", 27, "[19;2H", 27, "[41m ", 0x81 ;0x84 - paddle (red)
lookUpTable5: .string 27, "[16;83H", 27, "[42m ", 27, "[17;83H", 27, "[42m ", 27, "[18;83H", 27, "[42m ", 27, "[19;83H", 27, "[42m ", 0x81 ;0x85 - paddle (green)
lookUpTable6: .string 27, "[D", 27, "[40m ", 27, "[4A",27, "[D", 27, "[41m ", 27, "[3B", 0x81 ;0x86 left paddle up 1
lookUpTable7: .string 27, "[D", 27, "[B", 27, "[41m ", 27, "[4A", 27, "[D", 27, "[40m ", 27, "[4B", 0x81 ;0x87 left paddle down 1
lookUpTable8: .string 27, "[D", 27, "[40m ", 27, "[4A",27, "[D", 27, "[42m ", 27, "[3B", 0x81 ;0x88 right paddle up 1
lookUpTable9: .string 27, "[D", 27, "[B", 27, "[42m ", 27, "[4A", 27, "[D", 27, "[40m ", 27, "[4B", 0x81 ;0x89 right paddle down 1

cursorMoveStrL: .string 27, "[xx;3H", 0 ;HUGE BUG MAKE REGULAR LT STRS
cursorMoveStrR: .string 27, "[xx;84H", 0
;split this bc doesn't handle single chars and leading 0s

	.text
	.global uart_init
	.global gpio_btn_and_LED_init
	.global output_character
	.global read_character
	.global read_string
	.global output_string
	.global output_ansi
	.global read_from_push_btns
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global read_tiva_pushbutton
	.global division
	.global multiplication
	.global string2int
	.global int2string
	.global lookUpTable1
	.global lookUpTable2
	.global lookUpTable3
	.global	lookUpTable4
	.global lookUpTable5
	.global	lookUpTable6
	.global lookUpTable7
	.global lookUpTable8
	.global lookUpTable9
	.global currRowL
	.global currRowR
	.global cursorMoveStrL
	.global cursorMoveStrR


ptr_to_lookUpTable2:		.word lookUpTable2
ptr_to_lookUpTable3:		.word lookUpTable3
ptr_to_lookUpTable4:		.word lookUpTable4
ptr_to_lookUpTable5:		.word lookUpTable5
ptr_to_lookUpTable6:		.word lookUpTable6
ptr_to_lookUpTable7:		.word lookUpTable7
ptr_to_lookUpTable8:		.word lookUpTable8
ptr_to_lookUpTable9:		.word lookUpTable9
ptr_to_currRowL:			.word currRowL
ptr_to_currRowR:			.word currRowR
ptr_to_cursorMoveStrL:		.word cursorMoveStrL
ptr_to_cursorMoveStrR:		.word cursorMoveStrR
	;lab5
	;.global uart_interrupt_init
	;.global gpio_interrupt_init
	;.global UART0_Handler
	;.global Switch_Handler
	;.global Timer_Handler		; This is needed for Lab #6
	;.global simple_read_character	; read_character modified for interrupts

;uart_interrupt_init:
	;PUSH {r4-r12,lr}	; Spill registers to stack


	;POP {r4-r12,lr}
    ;mov pc, lr

;gpio_interrupt_init:
	;PUSH {r4-r12,lr}	; Spill registers to stack


	;POP {r4-r12,lr}
    ;mov pc, lr

;Switch_Handler:
	;PUSH {r4-r12,lr}	; Spill registers to stack


	;POP {r4-r12,lr}
    ;mov pc, lr

;Timer_Handler:
	;PUSH {r4-r12,lr}	; Spill registers to stack


	;POP {r4-r12,lr}
    ;mov pc, lr

;simple_read_character:
	;PUSH {r4-r12,lr}	; Spill registers to stack


	;POP {r4-r12,lr}
    ;mov pc, lr


uart_init:
	PUSH {r4-r12,lr}	; Spill registers to stack

    ;Provide clock to UART0
    MOV r0, #0xE618          ;UART0 clock register
    MOVT r0, #0x400F
    MOV r1, #1               ;initialise value 1
    STR r1, [r0]             ;store 1 to enable UART0 clock

    ;Enable clock to PortA
    MOV r0, #0xE608          ;load address of GPIO PortA
    MOVT r0, #0x400F
    MOV r1, #1
    STR r1, [r0]             ;store 1 to enable PortA clock

    ;Disable UART0 Control
    MOV r0, #0xC030          ;UART0 control
    MOVT r0, #0x4000
    MOV r1, #0               ;initialise value 0
    STR r1, [r0]             ;store 0 to disable UART0

    ;Set UART0_IBRD_R for 115,200 baud
    MOV r0, #0xC024         ;integer baud rate register
    MOVT r0, #0x4000
    MOV r1, #8               ;initialise value 8
    STR r1, [r0]             ;store integer baud rate

    ;Set UART0_FBRD_R for 115,200 baud
    MOV r0, #0xC028         ;fractional baud rate register
    MOVT r0, #0x4000
    MOV r1, #44
    STR r1, [r0]

    ;Use System Clock
    MOV r0, #0xCFC8         ;UART clock source register
    MOVT r0, #0x4000
    MOV r1, #0
    STR r1, [r0]

    ;maybe its like this
    MOV r0, #0xC02C         ;UART line control register
    MOVT r0, #0x4000
    MOV r1, #0x60
    STR r1, [r0]

    ;Enable UART0 Control
    MOV r0, #0xC030
    MOVT r0, #0x4000
    MOV r1, #0x301           ;initialise value 0x301
    STR r1, [r0]             ;store value to enable UART0

    ;Make PA0 and PA1 as Digital Ports
    MOV r0, #0x451C         ;GPIO digital enable register
    MOVT r0, #0x4000
    LDR r1, [r0]
    ORR r1, r1, #0x03        ;OR with 0x03
    STR r1, [r0]

    ;Change PA0,PA1 to Use an Alternate Function
    MOV r0, #0x4420         ;GPIO alternate function register
    MOVT r0, #0x4000
    LDR r1, [r0]
    ORR r1, r1, #0x03
    STR r1, [r0]

    ;Configure PA0 and PA1 for UART
    MOV r0, #0x452C         ;GPIO port control register
    MOVT r0, #0x4000
    LDR r1, [r0]
    ORR r1, r1, #0x11       ;OR with 0x11 to configure UART
    STR r1, [r0]

    POP {r4-r12,lr}
    mov pc, lr

gpio_btn_and_LED_init:
	PUSH {r4-r12,lr}	; Spill registers to stack

    MOV r0, #0xE000
	MOVT r0, #0x400F 		;GPIO clock base address
	LDRB r1, [r0, #0x608]	;read from RCGCGPIO register
	ORR r1, r1, #0x20		;set bit 5 to enable clock
	STRB r1, [r0, #0x608] 	;write to enable clock

	MOV r0, #0x5000
	MOVT r0, #0x4002		;GPIO direction register
	MOV r1, #0xE			;0xE bc 0000 1110 (1,2,3 out, 4 in)----------------
	STRB r1, [r0, #0x400]	;setting bit 1,2,3 to write (R,G,B)

	MOV r1, #0x1E			;1,2,3,4 enabled 0001 1110 ------------------------------------
	STRB r1, [r0, #0x51C]	;setting pins for GPIO digital enable register

	MOV r0, #0x5000
	MOVT r0, #0x4002		;port F base address
	MOV r1, #0x10
	STRB r1, [r0, #0x510]	;setting pull up resistor

    ;part2 init stuff
    MOV   r0, #0xE608
    MOVT  r0, #0x400F
    LDRB  r1, [r0]
    ORR   r1, r1, #0xA       	;0x0A = 0x02 ,port B, and then 0x08 port D
    STRB  r1, [r0]

    MOV   r0, #0x5000         	;port B base address
    MOVT  r0, #0x4000
    LDRB  r1, [r0, #0x400]
    ORR   r1, r1, #0xF
    STRB  r1, [r0, #0x400]    	;GPIO direction register (pins are output)
    LDRB  r1, [r0, #0x51C]
    ORR   r1, #0xF
    STRB  r1, [r0, #0x51C]		;for GPIO digital enable register

    MOV   r0, #0x7000         	;port D base address
    MOVT  r0, #0x4000
    LDRB  r1, [r0, #0x400]
    AND   r1, r1, #0
    STRB  r1, [r0, #0x400]    	;GPIO direction register (pins are input)
    LDRB  r1, [r0, #0x51C]		;to enable pins 0-3
    ORR   r1, #0xF
    STRB  r1, [r0, #0x51C]    	;enable GPIO digital enable register

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

output_character:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.
						; Your code for your output_character routine is placed here
	MOV r1, #0xC000
	MOVT r1, #0x4000

outloop:
    LDRB r2, [r1, #0x18]
    AND r2, r2, #0x20
    CMP r2, #0
    BNE outloop

    STRB r0, [r1]

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr


;read_string:
	;PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
					; that are used in your routine.  Include lr if this
					; routine calls another routine.
	;MOV r1, r0	 	;copy str base address from r0, r1 is the pointer to current address

;readsloop:
	;BL read_character
	;STRB r0, [r1]
	;ADD r1, r1, #1
	;CMP r0, #0xD
	;BNE readsloop
	;SUB r1, r1, #1
	;MOV r0, #0
	;STRB r0, [r1]

	;POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	;mov pc, lr

output_string:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.
	MOV r3, r0 			;move base address in r0 to r3

outstringloop:
	LDRB r0, [r3] 		;load character from the string to r0
	CMP r0, #0 			;check if the character is null
	BEQ outstringdone 	;if null, end the loop
	CMP r0, #0x80
	BGE output_ansi_label
	BL output_character ;output character
	ADD r3, r3, #1 		;increment the address to point to the next character
	B outstringloop

;this is the code for when we encounter an ansi character (>80)
;switch cases for what to print (in  r9) based on what's in r4
output_ansi_label:
	;if  r4 = 2,print lt2
	;if r4 = 3, print lt3
	;if r4 = 4, print lt4
	;if r4 = 5, print lt5
	;if r4 = 6, print lt6
	;if r4 = 7, print lt7
	SUB r4, r0, #0x80
	CMP r4, #2
	BEQ lt2
	CMP r4, #3
	BEQ lt3
	CMP r4, #4
	BEQ lt4
	CMP r4, #5
	BEQ lt5
	CMP r4, #6
	BEQ lt6
	CMP r4, #7
	BEQ lt7
	CMP r4, #8
	BEQ lt8
	CMP r4, #9
	BEQ lt9

;load the correct pointer by case into r9
lt2: LDR r9, ptr_to_lookUpTable2
	 B outAnsiloop ;jump to main loop to print remaining chars
lt3: LDR r9, ptr_to_lookUpTable3
	 B outAnsiloop ;need in all cases so they don't do the other cases too
lt4: LDR r9, ptr_to_lookUpTable4
	 B outAnsiloop
lt5: LDR r9, ptr_to_lookUpTable5
	 B outAnsiloop
lt6: BL moveCursorL ;move cursor to the correct position
	;check if row is topmost (6) else don't move up
	 LDR r10, ptr_to_currRowL ;decrement row by 1
	 LDRB r11, [r10]
	 CMP r11, #0x6
	 BEQ outAnsidone ;don't do the rest of the printing

	 LDR r9, ptr_to_lookUpTable6 ;left up 1

	 ;decrement rowL by 1
	 SUB r11, r11, #1
	 STRB r11, [r10]

	 B outAnsiloop
lt7: BL moveCursorL ;move cursor to the correct position
	 ;check if row is bottommost (1A) else don't move down
	 LDR r10, ptr_to_currRowL ;decrement row by 1
	 LDRB r11, [r10]
	 CMP r11, #0x1B
	 BEQ outAnsidone ;don't do the rest of the printing

     LDR r9, ptr_to_lookUpTable7 ;left down 1

     ;increment row by 1
	 ADD r11, r11, #1
	 STRB r11, [r10]

	 B outAnsiloop

lt8: BL moveCursorR ;move cursor to the correct position
	;check if row is topmost (6) else don't move up
	 LDR r10, ptr_to_currRowR ;decrement row by 1
	 LDRB r11, [r10]
	 CMP r11, #0x6
	 BEQ outAnsidone ;don't do the rest of the printing

	 LDR r9, ptr_to_lookUpTable8 ;left up 1

	 ;decrement row by 1
	 SUB r11, r11, #1
	 STRB r11, [r10]

	 B outAnsiloop
lt9: BL moveCursorR ;move cursor to the correct position
	 ;check if row is bottommost (1A) else don't move down
	 LDR r10, ptr_to_currRowR ;decrement row by 1
	 LDRB r11, [r10]
	 CMP r11, #0x1B
	 BEQ outAnsidone ;don't do the rest of the printing

     LDR r9, ptr_to_lookUpTable9 ;left down 1

     ;increment row by 1
	 ADD r11, r11, #1
	 STRB r11, [r10]

	 B outAnsiloop

;proceed with rest of ansi string until reach 0x81
outAnsiloop:
	LDRB r0, [r9] 		;load character from the string to r0
	CMP r0, #0x81
	BEQ outAnsidone		;if reach go back character 81, then end
	BL output_character ;output character
	ADD r9, r9, #1 		;increment the address to point to the next character

	B outAnsiloop

outAnsidone:
	ADD r3, r3, #1 ;move forward in output string too
	B outstringloop ;output the rest of the string normally

outstringdone:
    POP   {r4-r12, lr}
    MOV   pc, lr

;these are subroutines to move the cursor to the correct position before reprinting L, R paddles
moveCursorL:
	PUSH {r4-r12, lr}
	LDR r10, ptr_to_currRowL
	LDRB r11, [r10]
	ADD r11, r11, #3 ;add 3 to row get correct coordinate

	;now store this inside the ansi sequence manually in memory
	LDR r10, ptr_to_cursorMoveStrL
	;int2string to print it correctly
	MOV r1, r11 ;integer in r1
	ADD r10, r10, #2 ;at the xx space we left
	MOV r0, r10 ;string base addr in r0
	BL int2string

	;need to manually write the ; 0x3b bc int2string nul terminates it
	MOV r2, #0x3b
	STRB r2, [r10, #2] ;offset 2 is right after the xx

	LDR r0, ptr_to_cursorMoveStrL
	BL output_string

	POP   {r4-r12, lr}
    MOV   pc, lr

moveCursorR:
	PUSH {r4-r12, lr}

	POP   {r4-r12, lr}
    MOV   pc, lr

read_from_push_btns:
	PUSH {r4-r12, lr}         ; Spill registers to stack

    MOV r0, #0x7000				;set pord D base address
    MOVT r0, #0x4000
    LDRB r1, [r0, #0x3FC]		;read port D's data register
    AND r1, r1, #0xF			;mask r1 with 0x9 cause 1001 in binary to mask bit 3 and bit 0

	;but switch 2's bit is already in bit 3, and switch 5's bit is already in bit 0
	;so we can just return r1 as is
	MOV r0, r1
	;if switch 2 is pressed, r0 = 0x8, if switch 5 is pressed, r0 = 0x1
	;if both pressed, r0 = 0x9

    POP   {r4-r12, lr}
    MOV   pc, lr

illuminate_LEDs:
	PUSH {r4-r12,lr} ; Spill registers to stack

	MOV r1, #0x5000
	MOVT r1, #0x4000 ;port B base address in r1
	;0x3FC is the offset again

	STRB r0, [r1, #0x3FC] ;bc it maps directly (pin/bit 0 = led 0)

	POP {r4-r12,lr} ; Restore registers from stack
	MOV pc, lr

illuminate_RGB_LED:
	PUSH {r4-r12,lr}	; Spill registers to stack

	MOV r2, #0x5000
	MOVT r2, #0x4002	;port F base address (tiva), r2

	STRB r0, [r2, #0x3FC] ;offset, data register

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

read_tiva_pushbutton:
	PUSH {r4-r12,lr}		; Spill registers to stack
	MOV r0, #0x5000
	MOVT r0, #0x4002		;port F base address
	LDRB r1, [r0, #0x3FC]
	AND r1, r1, #0x10		;cause 0x10 is 0001 0000 in binary and we want to mask the 5th bit
	CMP r1, #0				;compare r1 to 0
	BEQ button_pressed 		;if equal, jump to button_pressed
	MOV r0, #0				;else, set r0 to 0 cause not pressed
	B button_done

button_pressed:
	MOV r0, #1

button_done:
	POP {r4-r12,lr}  		; Restore registers from stack
	MOV pc, lr

division:
	PUSH {r4-r12,lr}	; Spill registers to stack

	MOV r2, #15			;initialize counter to 15
	MOV r3, r0			;copy the dividend from r0 to r3
	MOV r0, #0			;initialize quotient to 0
	LSL r1, #15			;logical left shift divisor 15 places
	MOV r4, r3			;initialize remainder
divmainloop:
	SUB r4, r4, r1		;Remainder = remainder - divisor
	CMP r4, #0			;is remainder < 0 ?
	BLT divloop1		;if yes, go to loop1
	B divloop2			;if not, go to loop2
divloop1:
	ADD r4, r4, r1		;Remainder = remainder + divisor
	LSL r0, #1			;logical left shift quotient
	B divloop3
divloop2:
	LSL r0, #1			;if not, logical left shift quotient
	ORR r0, #1			;set quotient LSB to 1
divloop3:
	LSR r1, #1
	CMP r2, #0
	BGT divdecrement
	B divend
divdecrement:
	SUB r2, #1
	B divmainloop
divend:
	MOV r5, r5

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

multiplication:
	PUSH {r4-r12,lr}	; Spill registers to stack

    MOV r2, r0		;since final product needs to be in r0,
	MOV r0, #0		;just copy r0 to r2 and make r2 the COUNTER
multiloop:
	ADD r0, r0, r1	;product = product + r1
	SUB r2, #1		;decrement counter
	CMP r2, #0		;if counter > 0, loop again
	BGT multiloop

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

int2string:

	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
	CMP r1, #0
	BNE notzero

;we need the check for 0, because the actual calculation loop relies on the number
;given to not be 0, because it will not start the loop when the number is 0.

	MOV r4, #0x30 		;ascii '0'
	STRB r4, [r0] 		;store '0' at [r0]
	ADD r0, r0, #1 		;increment r0
	MOV r4, #0
	STRB r4, [r0] 		;null terminator at [r0]
	B intdone

notzero:
	MOV r2, #0 			;initialise r2 as counter for digits

calcloop:
	MOV r7, #10
	UDIV r4, r1, r7 	;r4 = r1 / 10 (integer divide)
	MOV r6, #10
	MUL r5, r4, r6 		;r5 = r4 * 10
	SUB r5, r1, r5 		;r5 = r1 - (r4 * 10) --> remainder
	ADD r5, r5, #0x30	;0x30 #convert to ASCII
	PUSH {r5}			;save it on the stack
	ADD r2, r2, #1 		;increment digit counter
	MOV r1, r4 			;make r1 the quotient for the next loop
	CMP r1, #0 			;check if we're done
	BNE calcloop 		;if not, loop

intsaveloop:
	POP {r5}			;pop it off the stack
	STRB r5, [r0] 		;store digit
	ADD r0, r0, #1 		;increment the pointer
	SUB r2, r2, #1 		;decrement digit count
	CMP r2, #0 			;check if we're done
	BNE intsaveloop 	;loop until no more digits

	MOV r4, #0
	STRB r4, [r0] 		;add null terminator

intdone:
	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	mov pc, lr



string2int:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
				; that are used in your routine.  Include lr if this
				; routine calls another routine.

		; Your code for your string2int routine is placed here
	MOV r1, #0
	MOV r4, #10
	;copy address from r0 into another register as current pointer
    MOV r2, r0
    MOV r0, #0 ;now we can use r0 as the return area
loop_str2int:
    LDRB r1, [r2] ;address is in r2
    CMP r1, #0
    BEQ stop
    CMP r1, #0x2C
    BEQ comma
    SUB r1, r1, #0x30 ;subtract 30 to get int from ascii
    ;calculating the int total value
    ;r0 = r0 * 10 (in r4) + digit (in r1) -> r0 is where the final integer is stored
    MUL r0, r0, r4
    ADD r0, r0, r1 ;add digit

comma:
	ADD r2, r2, #1 ; move to next byte by incrementing r2 (current ptr)
    B loop_str2int
stop:
	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	mov pc, lr
	.end
