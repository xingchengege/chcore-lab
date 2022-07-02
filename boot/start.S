#include <common/asm.h>

.extern arm64_elX_to_el1
.extern boot_cpu_stack
.extern secondary_boot_flag
.extern clear_bss_flag
.extern init_c

BEGIN_FUNC(_start)
	mrs	x8, mpidr_el1 /*mpidr_el1中记录了当前PE的cpuid*/
	and	x8, x8,	#0xFF /*保留低8位*/
	cbz	x8, primary /*若为0，则为首个PE，跳转到primary*/

  /* hang all secondary processors before we intorduce multi-processors */
secondary_hang:
	bl secondary_hang /*若不为0，则为非首个PE，进入死循环来挂起*/

primary:

	/* Turn to el1 from other exception levels. */
	bl 	arm64_elX_to_el1  /*调用函数，将异常级别设为内核态*/

	/* Prepare stack pointer and jump to C. */
	adr 	x0, boot_cpu_stack /*读入数组boot_cpu_stack地址，init_c.c中有定义*/
	add 	x0, x0, #0x1000  /*栈由高地址向低地址增长，故用加法，相当于给栈分配了4069字节*/
	mov 	sp, x0 /* 设置栈指针寄存器*/

	bl 	init_c /*调用函数init_c,init_c.c中定义*/

	/* Should never be here */
	b	.
END_FUNC(_start)
