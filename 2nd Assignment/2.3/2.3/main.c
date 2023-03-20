#include <avr/io.h>
#include <avr/interrupt.h>

unsigned char a,b,temp,count,output;	//a->PORTA, b->PORTB

ISR (INT0_vect)
{
	int i;
	int output;
	output=0x00;
	a=PINA & 0x04;	//isolate the 2nd lsb for PA2
	a=a>>2;	//shift right 2 positions to get the value in the LSB
	b=PINB;
	for(i=0; i<8; i++)
	{
		temp=b;
		b=b & 0x01;	//isolate the lsb
		if(b==1)
		{
			count++;	//counter for dip switches ON
		}
		b=temp;		//restore number
		b=b>>1;		//right shift to check the next LSB dip switch
	}
	if(a==0)
	{
		while(count > 0)
		{
			output=output+1;
			output=output<<1;
			count=count-1;
		}
		PORTC=output>>1;
	}
	else
	{
		PORTC=count;
	}
	return;
}

int main(void)
{
	DDRA=0x00;	//set A and B as inputs
	DDRB=0x00;
	DDRC=0xFF;	//set PORTC as output
	GICR=0x40;	//INT0 ON
	MCUCR=0x03;	//INT0 MODE: FALL EDGE
	sei();
	while (1)
	{
		asm("nop");
	}
}


