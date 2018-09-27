/*
  *************************************************************************
**  Target      : Cortex-M3
**  Environment : GNU Tools
 *************************************************************************
*/
.syntax unified

.global pfnVectors
.global Default_Handler
.global _start
.equ Top_Of_Stack, 0x20004000    /* end of 16K RAM */

.global sdata
.global edata
.global etext
.global sbss
.global ebss

.section .vectors
vectors:
	.word Top_Of_Stack          @ msp = 0x20004000
	.word _start                @ Starting Program address
	.word Default_Handler	    @ NMI_Handler
	.word Default_Handler	    @ HardFault_Handler
	.word Default_Handler	    @ MemManage_Handler
	.word Default_Handler	    @ BusFault_Handler
	.word Default_Handler	    @ UsageFault_Handler
	.word 0                     @ 7
	.word 0                     @ To
	.word 0                     @ 10 
	.word 0                     @ Reserved
	.word Default_Handler	    @ SVC_Handler
	.word Default_Handler	    @ DebugMon_Handler
	.word 0                     @ Reserved
	.word Default_Handler	    @ PendSV_Handler
	.word Default_Handler	    @ SysTick_Handler
	.word Default_Handler	    @ IRQ_Handler
	.word Default_Handler	    @ IRQ_andler

.section .rodata


.section .data


.section .bss


.section .text
.thumb
/**
 * This is the code that gets called when the processor first
 * starts execution following a reset. 
*/
.type _start, %function
_start:                              @ _start label is required by the linker

	//init .data section
	ldr r7, =etext
	ldr r6, =sdata
	ldr r5, =edata
	mov r4, #0
data_init:
	cmp r6, r5
	beq data_init_end
	ldrb r4, [r7], #1
	strb r4, [r6], #1
	b data_init
data_init_end:

	//clear .bss section
	ldr r6, =sbss
	ldr r7, =ebss
	mov r4, #0
bss_init:
	cmp r6, r7
	beq bss_init_end
	strb r4, [r6], #1
	b bss_init
bss_init_end:

	bl main
	stop:   b stop

.global main
.type main, %function
main:                              
	stmfd sp!, {lr}
	stmfd sp!, {r4-r11}

	mov r0, #5
	bl fact
	mov r1, r0		@ result

	ldmfd sp!, {r4-r11}
	ldmfd sp!, {lr}
	mov pc, lr

.global fact
.type fact, %function
fact:
	cmp r0, #0
	itt eq
	moveq r0, #1
	moveq pc, lr

	stmfd sp!, {lr}
	stmfd sp!, {r4-r11}

	mov r4, r0		@ save n
	sub r0, r0, #1	@ calc n-1 for arg
	bl fact			@ call fact(n-1)
	mul r5, r4, r0	@ r5 = n * res of fact(n-1)
	mov r0, r5		@ get res in r0 for return

	ldmfd sp!, {r4-r11}
	ldmfd sp!, {lr}

	mov pc, lr


/**
 * This is the code that gets called when the processor receives an
 * unexpected interrupt.  This simply enters an infinite loop, preserving
 * the system state for examination by a debugger.
 *
*/
.type Default_Handler, %function
Default_Handler:
	loop:	b loop
	
.end


