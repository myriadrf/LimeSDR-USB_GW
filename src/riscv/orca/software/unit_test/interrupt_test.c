
#define _stringify(a) #a
#define stringify(a) _stringify(a)
#define csrr(name,dst) asm volatile ("csrr %0 ," stringify(name) :"=r"(dst) )
#define csrw(name,src) asm volatile ("csrw " stringify(name) ",%0" ::"r"(src) )
#define nop asm volatile ("nop" )

#define MEIMASK 0x7C0
#define MEIPEND 0x7C0

#define MSTATUS_MIE 0x8


static inline void schedule_interrupt(int cycles)
{
	//when an integer is written to the INT_GEN_REGISTER,
	//an iterrupt will be triggered that many cycles from now.
	//if the number is negative, no interrupt will occur

	// Note that an interrupt must clear flush the popeling, before the
	//processor can be interrupted, so if the next instruction disables
	//interrupts, the interrupt will probably not be taken

	volatile int*  INT_GEN_REGISTER = (volatile int*)(0x01000000);
	*INT_GEN_REGISTER = cycles;
}

volatile int interrupt_count;
void* handle_interrupt(int cause,void* pc)
{
	interrupt_count++;
	schedule_interrupt(-1);//clear interrupt
	return pc;
}
#define TEST_ATTR static __attribute__((noinline))


TEST_ATTR int test_2()
{
	int before=interrupt_count;

	//enable interrupts
	csrw(mstatus,MSTATUS_MIE);
	csrw(MEIMASK,1);
	//send interrupt
	schedule_interrupt(0);
	nop;nop;nop;//poor mans pipeline flush

	//disable interrupts
	csrw(mstatus,0);
	//check if interrupt was signalled
	return before+1 == interrupt_count ? 0: 1;

}

TEST_ATTR int test_3()
{
	int before=interrupt_count;

	//clear interrupts
	csrw(mstatus,0);
	csrw(MEIMASK,1);
	//send interrupt
	schedule_interrupt(0);
	nop;nop;nop;//poor mans pipeline flush
	//disable interrupts
	csrw(mstatus,0);
	schedule_interrupt(-1);
	//check if interrupt was signalled
	return before == interrupt_count ? 0: 1;

}


TEST_ATTR int test_4()
{
	int before=interrupt_count;

	//clear interrupts
	csrw(mstatus,MSTATUS_MIE);
	csrw(MEIMASK,0);
	//send interrupt
	schedule_interrupt(0);
	nop;nop;nop;//poor mans pipeline flush
	//disable interrupts
	csrw(mstatus,0);
	schedule_interrupt(-1);
	//check if interrupt was signalled
	return before == interrupt_count ? 0: 1;

}

TEST_ATTR int test_5()
{
	int before=interrupt_count;

	//clear interrupts
	csrw(mstatus,MSTATUS_MIE);
	csrw(MEIMASK,0);
	//send interrupt
	schedule_interrupt(0);
	nop;nop;nop;//poor mans pipeline flush
	//disable interrupts
	csrw(mstatus,0);
	schedule_interrupt(-1);
	//check if interrupt was signalled
	return before == interrupt_count ? 0: 1;

}

TEST_ATTR int interrupt_latency_test(int cycles)
{
	int before=interrupt_count;

	//clear interrupts
	csrw(mstatus,MSTATUS_MIE);
	csrw(MEIMASK,1);
	//send interrupt
	schedule_interrupt(cycles);
	int timeout=80;
	while((before+1) > interrupt_count){
		if(--timeout == 0 ){break;};
	}
	//disable interrupts
	schedule_interrupt(-1);
	csrw(mstatus,0);
	//if timeout > 0 then the loop did not timeout
	return timeout>0 ? 0 :1;

}




//this macro runs the test, and returns the test number on failure
#define do_test(i) do{if ( test_##i () ) return i;}while(0)

int main()
{
	//disable interrupts
	csrw(mstatus,0);

	do_test(2);
	do_test(3);
	do_test(4);
	do_test(5);

	int i;
	for(i = 0 ; i< 15;i++){
		if (interrupt_latency_test(i))
			return i+6;
	}

	return 0;

}
