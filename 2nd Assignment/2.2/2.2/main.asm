.include "m16def.inc"

.def intercount = r16	;interrupts counter
.def temp = r17
.def count = r15

.org 0x0	; the main program (reset) starts
rjmp reset	; in address 0x0
.org 0x4	; the interrupt INT1 routine starts
rjmp ISR1 	; in address 0x4

reset:		; here starts the main program
	ldi r20, low(RAMEND)				; initialise stack pointer
	out SPL, r20
	ldi r20, high(RAMEND)
	out SPH, r20
	
	ldi r24,(1 << ISC11) | (1 << ISC10)	;set interrupt on rising edge
	out MCUCR, r24				
	ldi r24,(1 << INT1)			;set INT1
	out GICR, r24
	sei

	ser r26						; initialise  PORTB, PORTC for output
	out DDRC, r26
	out DDRB, r26
	clr r26						; initialise  PORTA for input
	out DDRA, r26		

loop:
out PORTC , count			; display counter on LEDs
;ldi r24 , low(100)		; load r25:r24 with 100
;ldi r25 , high(100)		; delay 100 ms
;rcall wait_msec			; cannot be used on the simulator
inc count					; increase counter
rjmp loop				; repeat


ISR1:
	in temp, PINA			; read input from PINA
	andi temp,0b11000000	; isolate bits 6 and 7 
	cpi temp,0b11000000		; if bit 6 or 7 is off then skip
	brne loop				
	inc intercount			; increase counter of interrupts
	out PORTB, intercount	; display counter of interrupts on PORTB
	;ldi r24 , low(998)		; load r25:r24 with 980
	;ldi r25 , high(998)		; delay 1sec
	;rcall wait_msec		; cannot be used on the simulator
	reti
