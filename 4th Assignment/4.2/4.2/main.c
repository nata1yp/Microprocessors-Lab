/*
 * 4.2.c
 *
 * Created: 2/12/2021 7:21:22 μμ
 * Author : Πεγειώτη Νάταλη
 */ 

#define F_CPU 8000000	 // frequency is set 8MHz
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

int num_pressed, tmp,i;		// 16-bit number to store the key that was pressed and tmp
char first_digit, second_digit;	// digits pressed
char x, y, z, flag_clear=0, flag_blink=0, leds;

char scan_row_sim(char y)	// y-->r25
{
	PORTC = y;	// Current line is set to 1
	_delay_us(500);	// delay for ~ 0.5usec (each 'nop' is 1/4usec so it's included to 500usec)
	return PINC & 0x0F;	// keep the 4 LSB of PORTC
}

int scan_keypad_sim(void)	// x-->r24, y-->r25, z-->r26, h-->r27
{
	char z,h;	// set as parameters so as to be topical
	int result;	// result = r25:r24 to be returned
	
	y = 0x10;	// check 1st line
	x = scan_row_sim(y);	// keep the result
	h =  x<<4;	// and save it in the 4 MSB of h
	
	y = 0x20;	// check 2nd line
	x = scan_row_sim(y);	// keep the result
	h = h+x;	// and save it in the 4 LSB of h
	
	y = 0x40;	// check 3rd line
	x = scan_row_sim(y);	// keep the result
	z =  x<<4;	// and save it in the 4 MSB of z
	
	y = 0x80;	// check 2nd line
	x = scan_row_sim(y);	// keep the result
	z = z+x;	// and save it in the 4 LSB of z
	
	result = h;
	return (result<<8) + z;	//return correct number
}

int scan_keypad_rising_edge_sim(void)
{
	int y = scan_keypad_sim();	// check the keypad for pressed button
	_delay_ms(15);	// delay for ~ 15msec
	int z = scan_keypad_sim();	// check the keypad again
	y = y & z;	// bitwise and, so to have the correct result
	z = tmp;	// load from RAM the previous value
	tmp = y;	// save in RAM the new value
	z = ~z;	// one's complement
	y = y & z;	// bitwise and
	return y;	// return value
}

char keypad_to_ascii_sim(int x)	// function that makes the number pressed to the ascii value or 0
{
	switch(x){
		case 0x01:return '*';
		case 0x02:return '0';
		case 0x04:return '#';
		case 0x08:return 'D';
		case 0x10:return '7';
		case 0x20:return '8';
		case 0x40:return '9';
		case 0x80:return 'C';
		case 0x100:return '4';
		case 0x200:return '5';
		case 0x400:return '6';
		case 0x800:return 'B';
		case 0x1000:return '1';
		case 0x2000:return '2';
		case 0x4000:return '3';
		case 0x8000:return 'A';
	}
	return 0;
}

void write_2_nibbles_sim(char x)
{
	char k,v;	//local variable for this program
	_delay_us(6000);	// delay for ~ 6000usec | protection for simulation
	k = (PIND & 0x0f);	// k is r25
	v =  k + (x & 0xf0);
	PORTD = v;	//output in PORTD
	v = PIND | 0x08;
	PORTD = v;
	v = PIND & 0xf7;
	PORTD = v;			//PD3=1 and then PD3=0 (enable pulse)
	_delay_us(6000);	// delay for ~ 6000usec | protection for simulation
	v =  k + ((x >> 4 | x << 4) & 0xf0);
	PORTD = v;	//output in PORTD
	v = PIND | 0x08;
	PORTD = v;			//PD3=1 and then PD3=0 (enable pulse)
	v = PIND & 0xf7;
	PORTD = v;

}

void lcd_data_sim(char x)
{
	PORTD = (1<<PD2);
	write_2_nibbles_sim(x);
	_delay_us(43);	// delay for ~ 43usec
}

void lcd_command_sim(char x)
{
	PORTD = (0<<PD2);
	write_2_nibbles_sim(x);
	_delay_us(39);	// delay for ~ 39usec
}

void lcd_init_sim()
{
	char v; //local variable
	_delay_us(40);	// delay for ~ 40usec
	PORTD = 0x30;		//8-bit mode
	v = PIND | 0x08;
	PORTD = v;			//PD3=1
	v = PIND & 0xf7;
	PORTD = v;			//PD3=0
	_delay_us(39);	// delay for ~ 39usec
	_delay_us(1000);	// delay for ~ 1000usec | protection for the simulation
	PORTD = 0x30;
	v = PIND | 0x08;
	PORTD = v;			//PD3=1
	v = PIND & 0xf7;
	PORTD = v;			//PD3=0
	_delay_us(39);	// delay for ~ 39usec
	_delay_us(1000);	// delay for ~ 1000usec | protection for the simulation
	
	PORTD = 0x20;		//change in 4-bit mode
	v = PIND | 0x08;
	PORTD = v;			//PD3=1
	v = PIND & 0xf7;
	PORTD = v;			//PD3=0
	_delay_us(39);	// delay for ~ 39usec
	_delay_us(1000);	// delay for ~ 1000usec | protection for the simulation
	lcd_command_sim(0x28);	// choose character size 5x8
	lcd_command_sim(0x0c);	// turn on screen, hide cursor
	lcd_command_sim(0x01);	// clear screen
	_delay_us(1530);	// delay for ~ 1530usec
	lcd_command_sim(0x06);	// activate automatic address increase by 1 and deactivate screen sliding
}

void CLEAR()
{

	if (flag_clear == 1)		// if previous state was Gas Detected display Clear
	{
		flag_clear=0;	
		lcd_init_sim();	
		lcd_data_sim('C');
		lcd_data_sim('L');
		lcd_data_sim('E');
		lcd_data_sim('A');
		lcd_data_sim('R');
		//_delay_ms(200);
	}
	TCNT1H = 0xfc;
	TCNT1L = 0xf3;
}

void GAS()
{
	if (flag_clear == 0)		// if previous state was Clear display Gas Detected
	{
		flag_clear=1;
		lcd_init_sim();
		lcd_data_sim('G');
		lcd_data_sim('A');
		lcd_data_sim('S');
		lcd_data_sim(' ');
		lcd_data_sim('D');
		lcd_data_sim('E');
		lcd_data_sim('T');
		lcd_data_sim('E');
		lcd_data_sim('C');
		lcd_data_sim('T');
		lcd_data_sim('E');
		lcd_data_sim('D');
	}
	TCNT1H = 0xfc;
	TCNT1L = 0xf3;
}

void Gas_on_led() // make leds blink when in Gas Detected state 
{ 
	if (flag_blink == 0) // if in previous Gas detected state leds were on, turn them off 
	{ 
		flag_blink = 1; 
		PORTB = leds; 
	} 
	else 
	{
		flag_blink = 0; 
		PORTB = 0; 
	} 
	GAS(); 
}


ISR(TIMER1_OVF_vect)
{
	cli(); //deactivate interrupts 
	ADCSRA = (1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)|(1<<ADSC);	// start transformation now 
	TCNT1H = 0xfc; 
	TCNT1L = 0xf3; 
	sei(); //reactivate interrupts
}


ISR(ADC_vect) // turn leds on according to the CO concentration level 
{ 
	if (ADC<=0x72) 
	{ 
		PORTB = 0b00000001; 
		CLEAR(); 
	} 
	else if (ADC<=0xcf) 
	{ 
		PORTB = 0b00000011; 
		CLEAR(); 
	} 
	else if (ADC<=0x12c) 
	{ 
		leds = 0b00000111; 
		Gas_on_led(); 
	} 
	else if (ADC<=0x18a) 
	{ 
		leds = 0b00001111; 
		Gas_on_led(); 
	} 
	else if (ADC<=0x1e7) 
	{ 
		leds = 0b00011111; 
		Gas_on_led(); 
	} 
	else if (ADC<=0x244) 
	{
		leds = 0b00111111; 
		Gas_on_led(); 
	} 
	else 
	{ 
		leds = 0b01111111; 
		Gas_on_led(); 
	} 
}


void ADC_init()
{
	ADMUX =  (1<<REFS0);
	ADCSRA = (1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);
}

int main(void)
{
	ADC_init();
	lcd_init_sim();
	
	DDRB = 0xFF;	// initialize PB0-7 as output
	DDRD = 0xFF;
	DDRC = (1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4);	// initialize PC4-7 as output
		
	//enable interrupts for timer , set frequency and initialize
	TIMSK = (1 << TOIE1);
	TCCR1B = (1 << CS12) | (0<<CS11) | (1<<CS10);
	TCNT1H = 0xfc;
	TCNT1L = 0xf3;
	sei();
	
	while(1)
	{
		first_digit = 0;	//initialize first digit with 0
		second_digit = 0;	//initialize first digit with 0
		do{
			num_pressed = scan_keypad_rising_edge_sim();
			first_digit = keypad_to_ascii_sim(num_pressed);		// read and store 1st digit
		} while(first_digit==0);	//repeat until first digit is valid
		do{
			num_pressed = scan_keypad_rising_edge_sim();
			second_digit = keypad_to_ascii_sim(num_pressed);	// read and store 2nd digit
		} while(second_digit==0);	//repeat until second digit is valid
		scan_keypad_rising_edge_sim();	// we call that for safety reasons
		
		
		if((first_digit=='4') && (second_digit=='1'))	// if the key is correct
		{
			cli();
			lcd_init_sim();
			lcd_data_sim('W');
			lcd_data_sim('E');
			lcd_data_sim('L');
			lcd_data_sim('C');
			lcd_data_sim('O');
			lcd_data_sim('M');
			lcd_data_sim('E');
			lcd_data_sim(' ');
			lcd_data_sim('4');
			lcd_data_sim('1');	// display "WELCOME 41"

			PORTB = (1 << PB7);	// turn on LED in PB7
			_delay_ms(4000);	// for ~4sec
			PORTB = (0 << PB7);	// turn off LED in PB7
			
			flag_clear = 0;

			lcd_init_sim();
			TCNT1H = 0xfc;
			TCNT1L = 0xf3;
			sei();
		}
		else  // if the key is wrong
		{
			for(i=0; i<4; i++)	//repeat 4 times --> ~4sec
			{
				z = PINB | 0x80; // turn on PB7
				PORTB = z;
				_delay_ms(500);	// for ~ 0.5sec
				z = PINB & 0x7f ;	// turn off PB7
				PORTB = z;
				_delay_ms(500);	// for ~ 0.5sec
			}
		}
	}
}
