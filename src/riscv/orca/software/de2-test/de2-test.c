


volatile int* ledr = (volatile int*)(0x01000010);
volatile int* ledg = (volatile int*)(0x01000020);
volatile int* hex0 = (volatile int*)(0x01000030);
volatile int* hex1 = (volatile int*)(0x01000040);
volatile int* uart = (volatile int*)(0x01000070);


inline unsigned get_time()
{
	int val;
	asm volatile ("csrr %0,mtime":"=r"(val));
	return val;
}
inline void delay(int cycles)
{
	unsigned start=get_time();
	while(get_time() - start < cycles);
}


inline void jtaguart_putc(char c)
{
	*hex1=uart[1];

	while((uart[1]&0xffff0000) == 0){
	}//uart fifo full
	uart[0]=c;

}
inline void jtaguart_puts(char* s)
{
	while(*s){
		jtaguart_putc(*s++);
	}

}




int main()
{
	for(;;) {

		*ledg = get_time();
		*ledr = get_time();
		*hex0 =get_time();
		jtaguart_puts("hello world\r\n");
		delay(5000000);

	}
}
