;
; 2.1.assembly.asm
;
; Created: 29/10/2021 7:18:03 μμ
; Author : Πεγειώτη Νάταλη
;


.include "m16def.inc"
.DEF input=r22 
.DEF output=r23 
.DEF inputC=r15
.DEF F0=r20
.DEF F1=r21

reset:	ldi r24, low(RAMEND)		; initialize stack pointer
		out SPL, r24
		ldi r24, high(RAMEND)
		out SPH, r24

		clr input				; initialize PORTC for input
		out DDRC , input
		ser output				; initialize PORTB for output
		out DDRB , output

main:	in inputC, PINC

F0_lbl:	mov r16, inputC		; (r16) <- 0000 DCBA, load number
		andi r16, 3			; (r16) <- 0000 DCBA and 0000 0011 = 0000 00BA
		cpi r16,2			; compare 0000 00BA to 0000 0010
		breq F0_zero		; if (A'B=1 <=> ((r16) == 0000 0010)) => F0=0 => jump to F0_zero
		mov r16, inputC		; (r16) <- 0000 DCBA, load number again
		andi r16,14			; (r16) <- 0000 DCBA and 0000 1110 = 0000 DCB0  
		cpi r16,12			; compare 0000 DCB0 to 0000 1100 
		breq F0_zero		; if (B'CD=1 <=> ((r16) == 0000 1100)) => F0=0 => jump to F0_zero
		rjmp F0_ace			; else F0=1 => jump to F0_ace
F0_zero:	ldi F0, 0
			rjmp F1_lbl
F0_ace:		ldi F0, 1
			rjmp F1_lbl


F1_lbl:	mov r17, inputC		; (r17) <- 0000 DCBA, load number
		andi r17, 1			; (r17) <- 0000 DCBA and 0000 0001 = 0000 000A
		cpi r17, 0			; compare 0000 000A to 0000 0000
		breq F1_zero		; if (A=0 <=> ((r17) == 0000 0000)) => F1=0 => jump to F1_zero
		mov r17, inputC		; (r17) <- 0000 DCBA, load number again
		andi r17, 4			; (r17) <- 0000 DCBA and 0000 0100 = 0000 0C00
		cpi r17, 0			; compare 0000 0C00 to 0000 0000
		breq F1_zero		; if (C=0 <=> ((r17) == 0000 0000)) => F1=0 => jump to F1_zero
		mov r17, inputC		; (r17) <- 0000 DCBA, load number again
		andi r17, 10		; (r17) <- 0000 DCBA and 0000 1010 = 0000 D0B0
		cpi r17, 0			; compare 0000 D0B0 to 0000 0000 
		breq F1_zero		; if (B+D=0 <=> ((r17) == 0000 0000)) => F1=0 => jump to F1_zero
		rjmp F1_ace			; else F1=1 => jump to F1_ace
F1_zero:	ldi F1, 0
			rjmp RES
F1_ace:		ldi F1, 1
			rjmp RES

RES:	lsl F1				; (F1) <- 0000 00(F1)0  (shift)
		add F1, F0			; (F1) <- 0000 00(F1)(F0)
		out PORTB, F1
		rjmp main			; start from the beginning
