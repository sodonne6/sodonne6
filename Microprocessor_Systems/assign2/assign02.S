@ MAKE SURE TO UPDATE C FILE AS WELL BEFORE TESTING

#include "hardware/regs/addressmap.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"
.syntax unified                                                 
.cpu    cortex-m0plus                                           
.thumb                                                          
.global main_asm                                                
.align 4                                                        

.equ    DFLT_ALARM_TIME, 1000000      

.equ    GPIO_BTN_EN_MSK, 0x00400000                             
.equ    GPIO_BTN_EN,  21                                        
.equ    GPIO_LED_PIN, 25              
.equ    GPIO_DIR_IN,   0              
.equ    GPIO_DIR_OUT,  1              

.equ    LED_VAL_ON,    1              
.equ    LED_VAL_OFF,   0              

.equ    GPIO_ISR_OFFSET, 0x74         
.equ    ALRM_ISR_OFFSET, 0x40 

.equ    DOT_TIME, 500000
.equ    DASH_TIME, 1500000

.equ    GPIO_BTN_DN_MSK, 0x00400000     @ falling edge event on GP21
.equ    GPIO_BTN_UP_MSK, 0x00800000     @ rising edge event on GP21 (twice the falling edge)

@TO-DO:
@set up level choosing logic
@integrate c functions into arm 
@
@
@

@ Entry point to the ASM portion of the program
main_asm:
    bl      LED_init                @ Initialise LED
    bl      button_init             @ Initialise Button
    bl      install_alarm_isr       @ Install alarm ISR
    bl      install_gpio_isr        @ Install button ISR

@ main_loop:
@     wfi                             @ Wait for interrupt
@     b       main_loop               @ Infinite loop


install_alarm_isr:
    @ Set IRQ Handler to our routine
    LDR R2, =PPB_BASE
    LDR R1, =M0PLUS_VTOR_OFFSET
    ADD R2, R1
    LDR R1, [R2]
    MOVS R2, #ALRM_ISR_OFFSET @ slot for alarm
    ADD R2, R1
    LDR R0, =alarm_isr
    STR R0, [R2]
    @ Enable alarm IRQ (clear then set)
    MOVS R0, #1 @ alarm is IRQ0
    LDR R2, =PPB_BASE
    LDR R1, =M0PLUS_NVIC_ICPR_OFFSET
    ADD R1, R2
    STR R0, [R1]
    LDR R1, =M0PLUS_NVIC_ISER_OFFSET
    ADD R1, R2
    STR R0, [R1]
    BX LR




install_gpio_isr:
@ Calculate the address of the interrupt vector in vector table
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)
    ldr     r1, [r2]
    movs    r2, #GPIO_ISR_OFFSET
    add     r2, r1
  
@ Insert address of gpio_isr subroutine into vector table
    ldr     r0, =gpio_isr
    str     r0, [r2]

@ Disable 
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)
    ldr     r1,=0x2000
    str     r1, [r2]
@ Enable 
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)
    ldr     r1,=0x2000
    str     r1, [r2]
   
    bx      lr


set_alarm:
    movs    r1, #1                                  
    ldr     r2, =(TIMER_BASE + TIMER_INTE_OFFSET)       @ base address for timer + offset for timer interrupt enable register
    str     r1, [r2]                                    @ enable the alarm timer interrupt
    ldr     r2, =(TIMER_BASE + TIMER_TIMELR_OFFSET)     @ base address for timer + offset for the lower 32-bits of timer register
    ldr     r1, [r2]                                    @ store current timer count in r1
    adds    r0, r1                                      @ add delay
    ldr     r2, =(TIMER_BASE + TIMER_ALARM0_OFFSET)     @ update the value at the address
    str     r0, [r2]                                    @ ^

    bx      lr




.thumb_func @ necessary for interrupt handlers
@ Below is Alarm interrupt handler and state machine.
alarm_isr:
        PUSH {LR}
        @ Clear the interrupt
        LDR R2, =TIMER_BASE
        MOVS R1, #1                             @ for alarm
        STR R1, [R2, #TIMER_INTR_OFFSET]        @ Offset address for the TIMER raw interrupts register.

        @Below is for checking if its in the correct state
        LDR R0, =two_seconds_passed
        LDR R1, [R0]
        CMP R1, 1                                       @ This checks if two seconds have passed
        BNE  only_1_sec_passed
        
        @else 2 seconds have passed
        @ Do something to show that the sequence has been completed
        
end_alarm:
        POP {PC}

only_1_sec_passed:                              @

        LDR R0, =two_seconds_passed
        @ STR #1, [R0]
        @ STR R0, [#1]

        @Do something to make a space happen

        LDR R3, =ltimer
        finish: LDR R0, [R3]                    @ sleep time
        BL set_alarm                            @ set next alarm

        b end_alarm



.thumb_func     
gpio_isr:                                           @This is what happens when button interrupt is called
    push {LR}

    @ Poll Watchdog 
    bl watchdog_update

    @ Loading in the base + offset for where the interupt identifier is
    LDR     r2, =(IO_BANK0_BASE + IO_BANK0_PROC0_INTS2_OFFSET)  
    LDR     r1, [r2]                                            

    @ Mask for button pressed
    LDR     r0, =GPIO_BTN_DN_MSK                              
    CMP     r1, r0                                             
    BEQ     button_press                                                                             
    
    @ Mask for button release
    LDR     r0, =GPIO_BTN_UP_MSK                               
    CMP     r1, r0                                             
    BEQ     button_release  


end_isr:
    bl set_alarm
    pop {PC}

@this will distinguish which level the user chose - make sure teh users input is being comapred to the correct morse sequence 
.thumb_func
check_level:
    @ Assuming only two levels for simplicity
    LDR R1, =current_level
    LDR R1, [R1]
    CMP R1, #1
    beq check_level_1
    CMP R1, #2
    beq check_level_2
    B end_isr


button_press:
    bl sub_toggle

    @ Capture the current time at button press and store in r1
    LDR R2, =TIMER_BASE
    LDR R1, [R2, #TIMER_TIMELR_OFFSET]    
    LDR R2, =button_press_time
    STR R1, [R2]
    
    @ Update last action time (put value of r1(current time) into last_action_time variable) [Do we still need this?]
    @ LDR R2, =last_action_time   
    @ STR R1, [R2]

    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)        @ Load the address of the raw interrupts register into r2
    ldr     r0, =GPIO_BTN_DN_MSK                                @ Load the enable button mask into r0
    str     r0, [r2]                                           

    B end_isr


button_release:
    bl sub_toggle

    @ Capture the current time at button release
    LDR R2, =TIMER_BASE
    LDR R1, [R2, #TIMER_TIMELR_OFFSET]
    LDR R3, =button_release_time
    STR R1, [R3]
    
    @ Calculate the duration of the button press
    LDR R3, =button_press_time
    LDR R3, [R3]
    SUBS R1, R1, R3
    
    @ Update last action time
    STR R1, [R2]
    
    @ Distinguish between dot, dash, or space based on duration
    @DOT TIME OR DOT ThRESHOLD
    LDR R2, =DOT_TIME
    CMP R1, R2
    blt process_dot
    LDR R2, =DASH_TIME
    CMP R1, R2
    blt process_dash
    
    @if dash was too long, do nothing
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)        @ Load the address of the raw interrupts register into r2
    ldr     r0, =GPIO_BTN_UP_MSK                                @ Load the enable button mask into r0
    str     r0, [r2]  

    B end_isr

.thumb_func
process_dot:
    @ LDR R0, =dot_ascii
    @ bl printf
    movs r0, #0
    bl gameLogic
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)        @ Load the address of the raw interrupts register into r2
    ldr     r0, =GPIO_BTN_UP_MSK                                @ Load the enable button mask into r0
    str     r0, [r2]  
    b end_isr

.thumb_func
process_dash:
    @ LDR R0, =dash_ascii
    @ bl printf
    @ talk to c code
    movs r0, #1
    bl gameLogic
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)        @ Load the address of the raw interrupts register into r2
    ldr     r0, =GPIO_BTN_UP_MSK                                @ Load the enable button mask into r0
    str     r0, [r2]  
    b end_isr

/* 
I think this can mostly be implemented in c
.thumb_func
process_dot:
    LDR R1, =input_sequence     @ Load the address of the input_sequence buffer
    LDR R2, =sequence_pos       @ Load the position in the sequence
    LDR R2, [R2]
    MOVS R0, #'.'               @ ASCII for dot
    STRB R0, [R1, R2]           @ Store the dot in the buffer at the current position
    ADDS R2, R2, #1             @ Increment the position
    LDR R3, =sequence_pos
    STR R2, [R3]                @ Update the position
    B check_sequence            @ Go to compare sequence

.thumb_func
process_dash:
    LDR R1, =input_sequence     @ Load the address of the input_sequence buffer
    LDR R2, =sequence_pos       @ Load the position in the sequence
    LDR R2, [R2]
    MOVS R0, #'-'               @ ASCII for dash
    STRB R0, [R1, R2]
    ADDS R2, R2, #1
    LDR R3, =sequence_pos
    STR R2, [R3]                @ Update the position
    B check_sequence            @ Go to compare sequence
*/


.thumb_func
check_sequence:
    @only 2 levels at the moment-decide path on what to compare buffer to 
    LDR R1, =current_level
    LDR R1, [R1]
    CMP R1, #1
    beq check_level_1
    CMP R1, #2
    beq check_level_2
    B end_isr

check_level_1:
    @ Compare input_sequence to "---..."
    LDR R1, =input_sequence
    LDRB R2, [R1]
    @ Add code to compare the sequence
    @ if the two codes match, trigger success and move onto next level - output success in c file 
    @ on failure, possibly reset or deduct a life - reset and change led color
    B end_isr

check_level_2:
    @ Compare input_sequence to ".--.-."
    LDR R1, =input_sequence
    LDRB R2, [R1]
    @ Add code to compare the sequence
    @ if the two codes match, trigger success and move onto next level - output success in c file 
    @ on failure, possibly reset or deduct a life - reset and change led color
    B end_isr


LED_init:
    push {lr}
    movs    r0, #GPIO_LED_PIN           @ This value is the GPIO LED pin on the PI PICO board
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_LED_PIN           @ This value is the GPIO LED pin on the PI PICO board
    movs    r1, #GPIO_DIR_OUT           @ We want this GPIO pin to be setup as an output pin
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    pop {pc}

button_init:
    push {lr}
    movs    r0, #GPIO_BTN_EN            @ This value is the GPIO LED pin on the PI PICO board
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_BTN_EN            @ This value is the GPIO LED pin on the PI PICO board
    movs    r1, #GPIO_DIR_IN            @ We want this GPIO pin to be setup as an output pin
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    movs    r0, #GPIO_BTN_EN
    bl      asm_gpio_set_irq            @Initialised for interrupts
    pop {pc}

//------------ JUST FOR TESTING ---------------
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
    pop     {pc}     



@ Set data alignment



.data
.align 4
button_press_time: .word 0x20000000       
ltimer: .word   DFLT_ALARM_TIME
two_seconds_passed: .word     0  
button_release_time: .word 0
last_action_time: .word 0
input_sequence: .space 10  @ Allocate 10 bytes for the sequence
sequence_pos:   .word 0      @ Position in the sequence
current_level:  .word 1     @ Current level; assume it starts at level 1
dash_ascii:     .asciz "-"
dot_ascii:      .asciz "."


