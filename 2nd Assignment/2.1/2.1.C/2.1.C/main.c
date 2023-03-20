/*
 * 2.1.C.c
 *
 * Created: 29/10/2021 7:28:00 μμ
 * Author : Πεγειώτη Νάταλη
 */ 

#include <avr/io.h>

char f0 , f1 ;

int main ( void )
{
	DDRB = 0xFF; // Initialize PORTB as output
	DDRC = 0x00; // Initialize PORTC as input
	
	while (1) {
		// F0
		if ((( PINC & 0x03 )==2) || (( PINC & 0x0e )==12)) {
			f0 = 0;
		}
		else { 
			f0 = 1;
		}
		// F1
		if ((( PINC & 0x01 )==0) || (( PINC & 0x04 )==0) || (( PINC & 0x0A )==0)) {
			f1 = 0;
		}
		else {
			f1 = 1;
		}
			
		f1 = f1 << 1;
		PORTB = f0 | f1 ; // Output in PORTB
	}
	return 0;
}

