#include "hardware/regs/addressmap.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"

.syntax unified
.cpu cortex-m0plus
.thumb
.global main_asm
.align 4

.equ    DFLT_STATE_STRT, 1                                      @ Specify the value to start flashing
.equ    DFLT_STATE_STOP, 0                                      @ Specify the value to stop flashing
.equ    DFLT_ALARM_TIME, 1000000                                @ Specify the default alarm timeout

.equ    GPIO_BTN_UP_MSK, 0x00040000                             @ Bit-18 for falling-edge event on GP20
.equ    GPIO_BTN_EN_MSK, 0x00400000                             @ Bit-22 for falling-edge event on GP21
.equ    GPIO_BTN_DN_MSK, 0x04000000                             @ Bit-26 for falling-edge event on GP22

.equ    GPIO_BTN_DN,  22                                        @ Specify pin for the "down" button
.equ    GPIO_BTN_EN,  21                                        @ Specify pin for the "enter" button
.equ    GPIO_BTN_UP,  20                                        @ Specify pin for the "up" button
.equ    GPIO_LED_PIN, 25                                        @ Specify pin for the built-in LED
.equ    GPIO_DIR_IN,   0                                        @ Specify input direction for a GPIO pin
.equ    GPIO_DIR_OUT,  1                                        @ Specify output direction for a GPIO pin

.equ    LED_VAL_ON,    1                                        @ Specify value that turns the LED "on"
.equ    LED_VAL_OFF,   0                                        @ Specify value that turns the LED "off"

.equ    GPIO_ISR_OFFSET, 0x74                                   @ GPIO is int #13 (vector table entry 29)
.equ    ALRM_ISR_OFFSET, 0x40                                   @ ALARM0 is int #0 (vector table entry 16)

@Register Name                                  @Reg Description

@TIMER_BASE                                     @Base address for the RP2040 timer component.
@TIMER_INTE_OFFSET                              @Offset address for the TIMER interrupt enable register.
@TIMER_INTR_OFFSET                              @Offset address for the TIMER raw interrupts register.
@TIMER_TIMELR_OFFSET                            @Offset address for the lower 32-bits of the timer register.
@TIMER_ALARM0_OFFSET                            @Offset address for the ALARM0 control register.
@PPB_BASE                                       @Base address for the RP2040 component that holds the VTOR and NVIC.
@M0PLUS_VTOR_OFFSET                             @Offset address for the vector table.
@M0PLUS_NVIC_ICPR_OFFSET                        @Offset address for the NVIC Interrupt Clear Pending register.
@M0PLUS_NVIC_ISER_OFFSET                        @Offset address for the NVIC Interrupt Set Enable register.
@IO_BANK0_BASE	                                @Base address for the RP2040 GPIO component.
@IO_BANK0_INTR2_OFFSET                          @Offset address for the GPIO raw interrupts #2 register.
@IO_BANK0_PROC0_INTS2_OFFSET	                @Offset address for the GPIO interrupt status #2 register.

@Objectives:
@Create a new ISR - part of its functionality should be to clear the pending interrupt that it is servicing before it completes
@Copy the address of the new ISR to the appropriate entry in the vector table (PPB_BASE + M0PLUS_VTOR_OFFSET + ALARM_ISR_OFFSET)
@Disable the specific interrupt level by writing to the appropriate bit in (PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)
@Enable the specific interrupt level by writing to the appropriate bit in (PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)

@Requirements:
@The correct LED flashes at the correct default period when the code is run.
@The toggling of the LED is controlled via a periodic alarm timer interrupt.
@The LED stops flashing when GP21 is pressed and restarts when pressed again.
@The LED flash rate halves each time GP20 is pressed and in flashing state.
@The LED flash rate doubles each time GP22 is pressed and in flashing state.
@The LED flash rate resets when GP20 or GP22 are pressed and not in flashing state
@All GPIO button press events should be controlled via an interrupt service routine

@Optional Features:
@A descriptive message gets written to the console every time a button event occurs.
@A descriptive message gets written to the console every time an alarm event occurs

@ Entry point to the ASM portion of the program
main_asm:
@call subroutines to initialise led and all three buttons
@call subroutines to install alarm isr and gpio isr    
    bl      led_init           
    bl      alarm_isr_install    
    bl      gpio_isr_install    
    movs    r0, #GPIO_BTN_DN        
    bl      buttons_init       
    movs    r0, #GPIO_BTN_EN        
    bl      buttons_init       
    movs    r0, #GPIO_BTN_UP        
    bl      buttons_init        
loop:
@loop to run program
    ldr   r0, =ltimer
    ldr   r0, [r0]
    bl    set_alarm          
    wfi                      
    b     loop               


set_alarm:
@initialise alarm timer interrupts with (TIMER_BASE + TIMER_INTE_OFFSET)
    movs    r1, #1
    ldr     r2, =(TIMER_BASE + TIMER_INTE_OFFSET)
    str     r1, [r2]
@retrieve current timer count
    ldr     r2, =(TIMER_BASE + TIMER_TIMELR_OFFSET)
    ldr     r1, [r2]
    adds    r0, r1
    
@push updated value
    ldr     r2, =(TIMER_BASE + TIMER_ALARM0_OFFSET)
    str     r0, [r2]

    bx      lr


alarm_isr_install:
@ (PPB_BASE + M0PLUS_VTOR_OFFSET)  -- Gets address of the ram vector table
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)
    ldr     r1, [r2]
    movs    r2, #ALRM_ISR_OFFSET
    add     r2, r1
@ Store the address of the alarm ISR handler at the correct offset for ALARM0 in the vector table
    ldr     r0, =alarm_isr
    str     r0, [r2]
@ Disable ALARM0 IRQ by writing the correct value to (PBB_BASE + M0PLUS_NVIC_ICPR_OFFSET)
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)
    movs    r1, #1
    str     r1, [r2]
@ Enable the ALARM0 IRQ by writing the correct value to (PBB_BASE + M0PLUS_NVIC_ISER_OFFSET)
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)
    movs    r1, #1
    str     r1, [r2]

    bx      lr

.thumb_func
alarm_isr:
    push    {lr}                                                                    @Store the link register to the stack as we will call nested subroutines

    ldr     r0,=alrm_msg
    bl      printf

    ldr     r2, =TIMER_BASE

    movs    r1, #1
    str     r1, [r2, #TIMER_INTR_OFFSET]  

    ldr     r0, =lstate
    ldr     r0, [r0]
    cmp     r0, DFLT_STATE_STOP                                                     @compare with DFLT_STATE_STOP
    beq     flashing_disabled
    bl      sub_toggle
flashing_disabled:
    pop     {pc}


gpio_isr_install:
@ (PBB_BASE + M0PLUS_VTOR_OFFSET)  -- Gets address of the ram vector table
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)
    ldr     r1, [r2]
    movs    r2, #GPIO_ISR_OFFSET
    add     r2, r1
  
@ store address of GPIO ISR handler to correct offset for GPIO in the vector table
    ldr     r0, =gpio_isr
    str     r0, [r2]

@ Disable GPIO IRQ by writing the correct value to (PBB_BASE + M0PLUS_NVIC_ICPR_OFFSET)
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)
    ldr     r1,=0x2000
    str     r1, [r2]
@ Enable the GPIO IRQ by writing the correct value to (PBB_BASE + M0PLUS_NVIC_ISER_OFFSET)
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)
    ldr     r1,=0x2000
    str     r1, [r2]
   
    bx      lr

@GPIO ISR
.thumb_func
gpio_isr:
    push    {lr}

    ldr     r0, =gpio_msg
    bl      printf

    ldr     r0, =(IO_BANK0_BASE + IO_BANK0_PROC0_INTS2_OFFSET)                  @Retrieve location of the INTS2 register that stores which pin triggered the interrupt
    ldr     r0, [r0]                                                            @Store value in r0, to location in r0 to reset and clear interrupts
@Compare each mask to (IO_BANK0_BASE+IO_BANK0_PROC0_INTS2_OFFSET) 
    movs    r1, r0
    ldr     r2, =GPIO_BTN_DN_MSK                    
    ands    r0, r2
    cmp     r0, #0                                                              @Check if Pin 20's Edge fall triggered the interrupt
    bne     down_button_pressed

    movs    r0, r1
    ldr     r2, =GPIO_BTN_EN_MSK
    ands    r0, r2
    cmp     r0, #0                                                              @Check if Pin 21's Edge fall triggered the interrupt
    bne     enter_button_pressed

    movs    r0, r1
    ldr     r2, =GPIO_BTN_UP_MSK                                                @Check if Pin 22's Edge fall triggered the interrupt
    ands    r0, r2
    cmp     r0, #0
    bne     up_button_pressed
down_button_pressed:
    ldr     r0, =lstate
    ldr     r0, [r0]
    cmp     r0, #DFLT_STATE_STRT
    beq     down_interval_half                                                  @branch if equal
    ldr     r0, =ltimer
    ldr     r1, =DFLT_ALARM_TIME
    str     r1, [r0]
    b       down_interval_change_end
down_interval_half:
    ldr     r0,=half_msg                                                        @print "Doubling Delay"
    bl      printf
    ldr     r0, =ltimer                                     
    ldr     r1, [r0]
    lsrs    r1, #1                                                              @shift ltimer bit right once to half value
    str     r1, [r0]
down_interval_change_end:
    ldr     r1, =GPIO_BTN_DN_MSK
    b       button_check_end
enter_button_pressed:
    ldr     r0, =lstate                                                         @ Load address of lstate into r0
    ldr     r1, [r0]                                                            @ Load address value into r1
    cmp     r1, #DFLT_STATE_STOP                                                @ compare r1 with DFLT_STATE_STOP 
    beq     start_flashing                                                      @ If equal -> branch to start_flashing
    movs    r1, #DFLT_STATE_STOP                                                @ set r1 to DFLT_STATE_STOP
    b       stop_flashing_check                                                 @ branch to stop_flashing_check
start_flashing:
    movs    r1, #DFLT_STATE_STRT                                                @set DFLT_STATE_STRT to r1
stop_flashing_check:
    str     r1, [r0]                                                            @ store the address stored in r0 into r1

    ldr     r0, =pause_msg
    bl      printf

    ldr     r1, =GPIO_BTN_EN_MSK                                                @ load address of GPIO_BTN_EN_MSK into r1
    b       button_check_end                                                    @ branch to button_check_end
up_button_pressed:  
    ldr     r0, =lstate                                                         @load address of lstate into r0
    ldr     r0, [r0]
    cmp     r0, #DFLT_STATE_STRT                                                @compare with DFLT_STATE_STRT
    beq     up_interval_double                                                  @if equal branch to up_interval_change func
    ldr     r0, =ltimer
    ldr     r1, =DFLT_ALARM_TIME                                                @set new alarm time
    str     r1, [r0]                                                            @load into r1
    b       up_interval_double_end                                              @branch to end func

up_interval_double:
    ldr     r0,=dble_msg                                                        @print "Halfing Delay"
    bl      printf
    ldr     r0, =ltimer
    ldr     r1, [r0]
    lsls    r1, #1                                                              @shifts bits by 1 to left, doubling values
    str     r1, [r0]
@end flash rate change
up_interval_double_end:
    ldr     r1, =GPIO_BTN_UP_MSK                                                @load GPIO_BTN_IP_MSK into r1
    b       button_check_end                                                    @branch to button_check_end
@end button check
button_check_end:
    ldr     r0, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)                        @base address for the RP2040 GPIO component. + Offset address for the GPIO 
    str     r1, [r0]
    pop     {pc}


buttons_init:
    push    {r4, lr}                                                            @ Load r4 and link register into stack
    movs    r4, r0                                                              @ Store r0 value (GPIO button pin) into r4
    bl      asm_gpio_init                                                       @ call the subroutine to initlialise GPIO pin 
    movs    r0, r4                                                              @ set r0 to button pin
    movs    r1, #GPIO_DIR_IN                                                    @ store direction value of button in r1         
    bl      asm_gpio_set_dir                                                    @ call subroutine to initiliaise direction of button        
    movs    r0, r4
    bl      asm_gpio_set_irq                                                    @call subroutine to set up GPIO interrupt for the pin specified 
    pop     {r4, pc}                                                            @pop from stack and end func

led_init:
    push    {lr}                                                                @ push to stack
    movs    r0, #GPIO_LED_PIN                                                   @ This value is the GPIO LED pin on the PI PICO board        
    bl      asm_gpio_init                                                       @ Call the subroutine to initialise the GPIO pin specified by r0         
    movs    r0, #GPIO_LED_PIN                                                   @ This value is the GPIO LED pin on the PI PICO board           
    movs    r1, #GPIO_DIR_OUT                                                   @ We want this GPIO pin to be setup as an output pin    
    bl      asm_gpio_set_dir                                                    @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1    
    pop     {pc}                                                                @ pop from stack 

@ Subroutine to toggle the LED GPIO pin value
@ Taken from lab03 and variables altered to satsify skeleton variables
sub_toggle:
    push    {lr}                                                                @ Store the link register to the stack as we will call nested subroutines         
    movs    r0, #GPIO_LED_PIN                                                   @ Set the LED GPIO pin number to r0 for use by asm_gpio_get
    bl      asm_gpio_get                                                        @ Get current the value of the LED GPIO pin (returns to r0)
    cmp     r0, #LED_VAL_OFF                                                    @ Check if the LED GPIO pin value is "off"
    beq     led_set_on                                                          @ If it is "off" then then jump code to to turn it on
led_set_off:
    movs    r1, #LED_VAL_OFF                                                    @ The LED is currently "on" so we want to turn it "off" 
    b       led_set_state                                                       @ Jump to portion of code where we set the state of the LED
led_set_on:
    movs    r1, #LED_VAL_ON                                                     @The LED is currently "off" so we want to turn it "on"
led_set_state:
    movs    r0, #GPIO_LED_PIN                                                   @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    bl      asm_gpio_put                                                        @ Update the the value of the LED GPIO pin (based on value in r1)
    pop     {pc}                                                                @ Pop the link register from the stack to the program counter

                 

.data
lstate: .word DFLT_STATE_STRT
ltimer: .word DFLT_ALARM_TIME

gpio_msg: .asciz "\nGPIO Event\n"
alrm_msg: .asciz "\nAlarm Triggered\n"
half_msg: .asciz "\nDoubling Delay\n"
dble_msg: .asciz "\nHalfing Delay\n"
pause_msg:.asciz "\nPausing Flash\n"

