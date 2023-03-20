.include "m16def.inc"
.DEF input=r22 
.DEF output=r23 
.DEF inputC=r15
.DEF F0=r20
.DEF F1=r21
.DEF A=r16
.DEF B=r17
.DEF C=r18
.DEF D=r19
.DEF temp1=r12
.DEF temp2=r13
.DEF ace=r14

reset:	ldi r24, low(RAMEND)		; initialize stack pointer
		out SPL, r24
		ldi r24, high(RAMEND)
		out SPH, r24

		clr input				; initialize PORTC for input
		out DDRC , input
		ser output				; initialize PORTB for output
		out DDRB , output

main:	in inputC, PINC
		mov A, inputC		; A <- 0000 DCBA, load number
		andi A, 1			; A <- 0000 DCBA and 0000 0001 = 0000 000A
		mov B, inputC		; B <- 0000 DCBA, load number
		andi B, 2			; B <- 0000 DCBA and 0000 0010 = 0000 00B0
		lsr B				; right shift => B <- 0000 000B 
		mov C, inputC		; C <- 0000 DCBA, load number
		andi C, 4			; C <- 0000 DCBA and 0000 0100 = 0000 0C00
		lsr C				; right shift => C <- 0000 00C0 
		lsr C				; right shift => C <- 0000 000C 
		mov D, inputC		; D <- 0000 DCBA, load number
		andi D, 8			; D <- 0000 DCBA and 0000 1000 = 0000 D000
		lsr D				; right shift => D <- 0000 0D00 
		lsr D				; right shift => D <- 0000 00D0 
		lsr D				; right shift => D <- 0000 000D 

		clr ace
		inc ace
	
F0_lbl:	mov temp1, ace		; temp1 = 1
		eor temp1, A		; 1 xor A => temp1 = A'
		and temp1, B		; temp1 and B => temp1 = A'B

		mov temp2, ace		; temp2 = 1
		eor temp2, B		; 1 xor B => temp2 = B'
		and temp2, C		; temp2 and C => temp2 = B'C
		and temp2, D		; temp2 and D => temp2 = B'CD

		mov F0, temp1		; F0 = temp1 = A'B
		or F0, temp2		; F0 add temp2 => F0 = A'B + B'CD
		eor F0, ace			; F0 xor 1 => F0' = (A'B + B'CD)'

F1_lbl: mov temp1, A		; temp1 = A
		and temp1, C		; temp1 and C => temp1 = AC

		mov temp2, B		; temp2 = B
		or temp2, D		; temp2 add D => temp2 = B+D

		mov F1, temp1		; F1 = temp1 = AC
		and F1, temp2		; F1 and temp2 => F1 = AC(B+D)


RES:	lsl F1				; (F1) <- 0000 00(F1)0  (shift)
		add F1, F0			; (F1) <- 0000 00(F1)(F0)
		out PORTB, F1
		rjmp main			; start from the beginning
