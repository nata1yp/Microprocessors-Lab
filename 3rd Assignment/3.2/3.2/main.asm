;
; 3.2.asm
;
; Created: 20/11/2021 10:52:40 μμ
; Author : Πεγειώτη Νάταλη
;


.include "m16def.inc"

.DSEG
_tmp_: .byte 2
.CSEG
.def dgt1 = r20
.def dgt2 = r21

reset:	ldi r24, low(RAMEND)				; initialize stack pointer
		out SPL, r24
		ldi r24, high(RAMEND)
		out SPH, r24

		ser r26								
		out DDRB, r26						; initialize PORTB for output
		out DDRD, r26						; initialize PORTD that is connected to LCD, as output
		ldi r24, (1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)	; set as output the 4 MSB
		out DDRC, r24												; of PORTC
		

main:	clr r24
		rcall lcd_init_sim					; initialize with clear screen
		rcall scan_keypad_rising_edge_sim
		rcall keypad_to_ascii_sim			; read 1st digit 
		cpi r24, 0							; repeat until 1st digit is valid
		breq main
		mov dgt1,r24							; store 1st digit
next:	rcall scan_keypad_rising_edge_sim
		rcall keypad_to_ascii_sim			; read 2nd digit 
		cpi r24, 0							; repeat until 2nd digit is valid
		breq next
		mov dgt2,r24						; store 2nd digit
		rcall scan_keypad_rising_edge_sim	; we call that for safety reasons

		cpi dgt1, 52		; if 1st digit != 4
		brne wrong_key
		cpi dgt2, 49		; or 2nd digit != 1
		brne wrong_key	; wrong_key given, go to wrong_key

correct_key:	clr r24
				rcall lcd_init_sim
				ldi r24, 'W'
				rcall lcd_data_sim
				ldi r24, 'E'
				rcall lcd_data_sim
				ldi r24, 'L'
				rcall lcd_data_sim
				ldi r24, 'C'
				rcall lcd_data_sim
				ldi r24, 'O'
				rcall lcd_data_sim
				ldi r24, 'M'
				rcall lcd_data_sim
				ldi r24, 'E'
				rcall lcd_data_sim
				ldi r24, ' '
				rcall lcd_data_sim
				ldi r24, '4'
				rcall lcd_data_sim
				ldi r24, '1'
				rcall lcd_data_sim	;display "WELCOME 41"

				ser r19
				out PORTB, r19		; turn on LEDS
				ldi r24, low(4000)
				ldi r25, high(4000)
				rcall wait_msec		; delay 4sec
				clr r19
				out PORTB, r19		; turn off LEDS
				rjmp main

wrong_key:	clr r24
			rcall lcd_init_sim
			ldi r24, 'A'
			rcall lcd_data_sim
			ldi r24, 'L'
			rcall lcd_data_sim
			ldi r24, 'A'
			rcall lcd_data_sim
			ldi r24, 'R'
			rcall lcd_data_sim
			ldi r24, 'M'
			rcall lcd_data_sim
			ldi r24, ' '
			rcall lcd_data_sim
			ldi r24, 'O'
			rcall lcd_data_sim
			ldi r24, 'N'
			rcall lcd_data_sim	;display "ALARM ON"
		
		ldi r18, 4			; loop for 4 times
loop:	cpi r18, 0
		breq finish
		ser r19
		out PORTB, r19		; turn on LEDS
		ldi r24, low(500)
		ldi r25, high(500)
		rcall wait_msec		; delay 0.5sec
		clr r19
		out PORTB, r19		; turn off LEDS
		ldi r24, low(500)
		ldi r25, high(500)
		rcall wait_msec		; delay 0.5sec
		dec r18
		rjmp loop

finish:	rjmp main			; return to main

//given code for functions to be called
scan_row_sim:	
	out PORTC, r25		; ? ?????????? ?????? ??????? ??? ?????? ‘1’
	push r24			; ????? ?????? ??? ??????????? ??? ?? ?????
	push r25			; ?????????? ??? ???????????? ??????????????
	ldi r24,low(500)	; ?????????
	ldi r25,high(500)
	rcall wait_usec
	pop r25
	pop r24				; ????? ????? ??????
	nop
	nop					; ??????????? ??? ?? ???????? ?? ????? ? ?????? ??????????
	in r24, PINC		; ??????????? ?? ?????? (??????) ??? ????????? ??? ????? ?????????
	andi r24 ,0x0f		; ????????????? ?? 4 LSB ???? ?? ‘1’ ???????? ??? ????? ?????????
	ret					; ?? ?????????


scan_keypad_sim:	
	push r26			; ?????????? ???? ??????????? r27:r26 ????? ????
	push r27			; ????????? ???? ???? ???????
	ldi r25 , 0x10		; ?????? ??? ????? ?????? ??? ????????????? (PC4: 1 2 3 A)
	rcall scan_row_sim
	swap r24			; ?????????? ?? ??????????
	mov r27, r24		; ??? 4 msb ??? r27
	ldi r25 ,0x20		; ?????? ?? ??????? ?????? ??? ????????????? (PC5: 4 5 6 B)
	rcall scan_row_sim
	add r27, r24		; ?????????? ?? ?????????? ??? 4 lsb ??? r27
	ldi r25 , 0x40		; ?????? ??? ????? ?????? ??? ????????????? (PC6: 7 8 9 C)
	rcall scan_row_sim
	swap r24			; ?????????? ?? ??????????
	mov r26, r24		; ??? 4 msb ??? r26
	ldi r25 ,0x80		; ?????? ??? ??????? ?????? ??? ????????????? (PC7: * 0 # D)
	rcall scan_row_sim
	add r26, r24		; ?????????? ?? ?????????? ??? 4 lsb ??? r26
	movw r24, r26		; ???????? ?? ?????????? ????? ??????????? r25:r24
	clr r26				; ?????????? ??? ??? ????????????? ????????
	out PORTC,r26		; ?????????? ??? ??? ????????????? ????????
	pop r27				; ????????? ???? ??????????? r27:r26
	pop r26
	ret 


scan_keypad_rising_edge_sim:
	push r22				; ?????????? ???? ??????????? r23:r22 ??? ????
	push r23				; r26:r27 ????? ???? ????????? ???? ???? ???????
	push r26
	push r27	
	rcall scan_keypad_sim	; ?????? ?? ???????????? ??? ?????????? ?????????
	push r24				; ??? ?????????? ?? ??????????
	push r25
	ldi r24 ,15				; ??????????? 15 ms (??????? ????? 10-20 msec ??? ??????????? ??? ???
	ldi r25 ,0				; ???????????? ??? ????????????? – ????????????? ????????????)
	rcall wait_msec
	rcall scan_keypad_sim	; ?????? ?? ???????????? ???? ??? ????????	
	pop r23					; ??? ??????? ?????????? ???????????
	pop r22
	and r24 ,r22
	and r25 ,r23
	ldi r26 ,low(_tmp_)		; ??????? ??? ????????? ??? ????????? ????
	ldi r27 ,high(_tmp_)	; ??????????? ????? ??? ???????? ????? r27:r26
	ld r23 ,X+
	ld r22 ,X	
	st X ,r24				; ?????????? ??? RAM ?? ??? ?????????
	st -X ,r25				; ??? ?????????
	com r23
	com r22					; ???? ???? ????????? ??? ????? «?????» ???????
	and r24 ,r22
	and r25 ,r23
	pop r27					; ????????? ???? ??????????? r27:r26
	pop r26					; ??? r23:r22
	pop r23
	pop r22
	ret


keypad_to_ascii_sim:
	push r26			; ?????????? ???? ??????????? r27:r26 ????? ????
	push r27			; ????????? ???? ??? ???????
	movw r26 ,r24		; ?????? ‘1’ ???? ?????? ??? ?????????? r26 ????????
						; ?? ???????? ??????? ??? ????????
	ldi r24 ,'*'		
						; r26
						;C 9 8 7 D # 0 *
	sbrc r26 ,0
	rjmp return_ascii
	ldi r24 ,'0'
	sbrc r26 ,1
	rjmp return_ascii
	ldi r24 ,'#'
	sbrc r26 ,2
	rjmp return_ascii
	ldi r24 ,'D'
	sbrc r26 ,3			; ?? ??? ????? ‘1’??????????? ??? ret, ?????? (?? ????? ‘1’)	
	rjmp return_ascii	; ?????????? ?? ??? ?????????? r24 ??? ASCII ???? ??? D.
	ldi r24 ,'7'
	sbrc r26 ,4
	rjmp return_ascii
	ldi r24 ,'8'
	sbrc r26 ,5
	rjmp return_ascii
	ldi r24 ,'9'	
	sbrc r26 ,6
	rjmp return_ascii ;
	ldi r24 ,'C'
	sbrc r26 ,7
	rjmp return_ascii
	ldi r24 ,'4'		; ?????? ‘1’ ???? ?????? ??? ?????????? r27 ????????
	sbrc r27 ,0			; ?? ???????? ??????? ??? ????????
	rjmp return_ascii
	ldi r24 ,'5'
						;r27
						;? 3 2 1 B 6 5 4
	sbrc r27 ,1
	rjmp return_ascii
	ldi r24 ,'6'
	sbrc r27 ,2
	rjmp return_ascii
	ldi r24 ,'B'
	sbrc r27 ,3
	rjmp return_ascii
	ldi r24 ,'1'
	sbrc r27 ,4
	rjmp return_ascii ;
	ldi r24 ,'2'
	sbrc r27 ,5
	rjmp return_ascii
	ldi r24 ,'3' 
	sbrc r27 ,6
	rjmp return_ascii
	ldi r24 ,'A'
	sbrc r27 ,7
	rjmp return_ascii
	clr r24
	rjmp return_ascii
	
return_ascii:
	pop r27				; ????????? ???? ??????????? r27:r26
	pop r26
	ret 
	

lcd_init_sim:
	push r24				; ?????????? ???? ??????????? r25:r24 ????? ????
	push r25				; ????????? ???? ??? ???????
	
	ldi r24, 40				; ???? ? ???????? ??? lcd ????????????? ??
	ldi r25, 0				; ????? ??????? ??? ???? ??? ????????????.
	rcall wait_msec			; ??????? 40 msec ????? ???? ?? ???????????.
	ldi r24, 0x30			; ?????? ????????? ?? 8 bit mode
	out PORTD, r24			; ?????? ??? ???????? ?? ??????? ???????
	sbi PORTD, PD3			; ??? ?? ?????????? ??????? ??? ???????
	cbi PORTD, PD3			; ??? ??????, ? ?????? ???????????? ??? ?????
	ldi r24, 39
	ldi r25, 0				; ??? ? ???????? ??? ?????? ????????? ?? 8-bit mode
	rcall wait_usec			; ??? ?? ?????? ??????, ???? ?? ? ???????? ???? ??????????
							; ??????? 4 bit ?? ??????? ?? ?????????? 8 bit
	push r24				; ????? ?????? ??? ??????????? ??? ?? ?????
	push r25				; ?????????? ??? ???????????? ??????????????
	ldi r24,low(1000)		; ?????????
	ldi r25,high(1000)
	rcall wait_usec
	pop r25
	pop r24					; ????? ????? ??????
	ldi r24, 0x30
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ldi r24,39
	ldi r25,0
	rcall wait_usec 
	push r24				; ????? ?????? ??? ??????????? ??? ?? ?????
	push r25				; ?????????? ??? ???????????? ??????????????
	ldi r24 ,low(1000)		; ?????????
	ldi r25 ,high(1000)
	rcall wait_usec
	pop r25
	pop r24					; ????? ????? ??????
	ldi r24,0x20			; ?????? ?? 4-bit mode
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ldi r24,39
	ldi r25,0
	rcall wait_usec
	push r24				; ????? ?????? ??? ??????????? ??? ?? ?????
	push r25				; ?????????? ??? ???????????? ??????????????
	ldi r24 ,low(1000)		; ?????????
	ldi r25 ,high(1000)	
	rcall wait_usec
	pop r25
	pop r24					; ????? ????? ??????
	ldi r24,0x28			; ??????? ?????????? ???????? 5x8 ????????
	rcall lcd_command_sim	; ??? ???????? ??? ??????? ???? ?????
	ldi r24,0x0c			; ???????????? ??? ??????, ???????? ??? ???????
	rcall lcd_command_sim
	ldi r24,0x01			; ?????????? ??? ??????
	rcall lcd_command_sim
	ldi r24, low(1530)
	ldi r25, high(1530)
	rcall wait_usec
	ldi r24 ,0x06			; ???????????? ????????? ??????? ???? 1 ??? ??????????
	rcall lcd_command_sim	; ??? ????? ???????????? ???? ??????? ??????????? ???
							; ?????????????? ??? ????????? ????????? ??? ??????
	pop r25					; ????????? ???? ??????????? r25:r24
	pop r24
	ret
	

lcd_command_sim:
	push r24					; ?????????? ???? ??????????? r25:r24 ????? ????
	push r25					; ????????? ???? ??? ???????
	cbi PORTD, PD2				; ??????? ??? ?????????? ??????? (PD2=0)
	rcall write_2_nibbles_sim	; ???????? ??? ??????? ??? ??????? 39?sec
	ldi r24, 39					; ??? ??? ?????????? ??? ????????? ??? ??? ??? ??????? ??? lcd.
	ldi r25, 0					; ???.: ???????? ??? ???????, ?? clear display ??? return home,
	rcall wait_usec				; ??? ???????? ????????? ?????????? ??????? ????????.	
	pop r25						; ????????? ???? ??????????? r25:r24
	pop r24
	ret 
	

lcd_data_sim:
	push r24					; ?????????? ???? ??????????? r25:r24 ????? ????
	push r25					; ????????? ???? ??? ???????
	sbi PORTD, PD2				; ??????? ??? ?????????? ????????? (PD2=1)
	rcall write_2_nibbles_sim	; ???????? ??? byte
	ldi r24 ,43					; ??????? 43?sec ????? ?? ??????????? ? ????
	ldi r25 ,0					; ??? ????????? ??? ??? ??????? ??? lcd
	rcall wait_usec
	pop r25						;????????? ???? ??????????? r25:r24
	pop r24
	ret
	

write_2_nibbles_sim:
	push r24			; ????? ?????? ??? ??????????? ??? ?? ?????
	push r25			; ?????????? ??? ???????????? ??????????????
	ldi r24 ,low(6000)	; ?????????
	ldi r25 ,high(6000)
	rcall wait_usec
	pop r25
	pop r24				; ????? ????? ??????
	push r24			; ??????? ?? 4 MSB
	in r25, PIND		; ??????????? ?? 4 LSB ??? ?? ?????????????	
	andi r25, 0x0f		; ??? ?? ??? ????????? ??? ????? ??????????? ?????????
	andi r24, 0xf0		; ????????????? ?? 4 MSB ???
	add r24, r25		; ???????????? ?? ?? ???????????? 4 LSB
	out PORTD, r24		; ??? ???????? ???? ?????
	sbi PORTD, PD3		; ????????????? ?????? Enable ???? ????????? PD3
	cbi PORTD, PD3		; PD3=1 ??? ???? PD3=0
	push r24			; ????? ?????? ??? ??????????? ??? ?? ?????
	push r25			; ?????????? ??? ???????????? ??????????????
	ldi r24 ,low(6000)	; ?????????
	ldi r25 ,high(6000)
	rcall wait_usec
	pop r25
	pop r24				; ????? ????? ??????
	pop r24				; ??????? ?? 4 LSB. ????????? ?? byte.
	swap r24			; ????????????? ?? 4 MSB ?? ?? 4 LSB
	andi r24 ,0xf0		; ??? ?? ??? ????? ???? ?????????????
	add r24, r25
	out PORTD, r24
	sbi PORTD, PD3		; ???? ?????? Enable
	cbi PORTD, PD3
	ret


wait_msec:
	push r24			; 2 ?????? (0.250 ?sec)
	push r25			; 2 ??????
	ldi r24 , low(998)	; ??????? ??? ?????. r25:r24 ?? 998 (1 ?????? - 0.125 ?sec)
	ldi r25 , high(998) ; 1 ?????? (0.125 ?sec)
	rcall wait_usec		; 3 ?????? (0.375 ?sec), ???????? ???????? ??????????? 998.375 ?sec
	pop r25				; 2 ?????? (0.250 ?sec)
	pop r24				; 2 ??????
	sbiw r24 , 1		; 2 ??????
	brne wait_msec		; 1 ? 2 ?????? (0.125 ? 0.250 ?sec)
	ret					; 4 ?????? (0.500 ?sec)

wait_usec:
	sbiw r24 ,1		; 2 ?????? (0.250 ?sec)
	nop				; 1 ?????? (0.125 ?sec)
	nop				; 1 ?????? (0.125 ?sec)
	nop				; 1 ?????? (0.125 ?sec)
	nop				; 1 ?????? (0.125 ?sec)
	brne wait_usec	; 1 ? 2 ?????? (0.125 ? 0.250 ?sec)
	ret				; 4 ?????? (0.500 ?sec)