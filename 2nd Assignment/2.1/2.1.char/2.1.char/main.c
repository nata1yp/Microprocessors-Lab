#include <avr/io.h>
int main(void)
{
	char x,A,B,C,D,F0,F1;
	DDRB=0xFF; // use PORTB as output
	DDRC=0x00; // use PORTC as input

	while (1)
	{
		x = PINC & 0x0F; //isolation of the 4 LSBs
		A = x & 0x01; //A is PC0
		B = x & 0x02; //B is PC1
		B = B>>1;
		C = x & 0x04; //C is PC2
		C = C>>2;
		D = x & 0x08; //D is PC3
		D = D>>3;
		F0 = !((!A && B ) || (!B && C && D)); //calculation of F0
		F1 = ((A && C) && (B || D)); //calculation of F1
		F1 = F1<<1;
		PORTB = (F0 | F1); //output
	}
}

