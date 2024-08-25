#include "hardware/regs/addressmap.h"
#include "hardware/regs/m0plus.h"

.syntax unified                                 @ Specify unified assembly syntax
.cpu cortex-m0plus                              @ Specify CPU type is Cortex M0+
.thumb                                          @ Specify thumb assembly for RP2040
.global main_asm                                @ Provide program starting address to the linker
.align 4                                        @ Specify code alignment

.equ SLEEP_TIME, 500                            @ Specify the sleep time (in ms)
.equ LED_GPIO_PIN, 25                           @ Specify the pin that the LED is connected to
.equ LED_GPIO_OUT, 1                            @ Specify the direction of the GPIO pin
.equ LED_VALUE_ON, 1                            @ Specify the value that turns the LED "on"
.equ LED_VALUE_OFF, 0                           @ Specify the value that turns the LED "off"
.equ SVC_ISR_OFFSET, 0x2C                       @ The SVC is entry 11 in the vector table
.equ SVC_MAX_INSTRS, 0x01                       @ Maximum allowed SVC subroutines

@ Entry point to the ASM portion of the program
main_asm: 
    bl      init_gpio_led                       @ Initialise the GPIO LED pin
    bl      install_svc_isr                     @ Install the SVC interrupt service routine

loop:
    svc     #0                                  @ Call the SVC ISR with value 0 (turns on LED)
    nop                                         @ Add a no-op instruction for alignment after SVC
    bl      do_sleep                            @ Short pause before proceeding
    svc     #1                                  @ Call the SVC ISR with value 1 (turns off LED)
    nop                                         @ Add a no-op instruction for alignment after SVC
    bl      do_sleep                            @ Add a short pause before proceeding
    b       loop                                @ Always jump back to the start of the loop


@ Subroutine used to introduce a short delay in the application

do_sleep:
    push       {lr}                             @push to stack
    ldr        r0,=SLEEP_TIME                   @load address of SLEEP_TIME into r0
    bl         sleep_ms                         @branch to sleep_ms subroutine which provides the millisecond time for sleep
    pop        {pc}                             @pop from stack

@ Subroutine used to initialise the PI Pico built-in LED
init_gpio_led:
    push    {lr}                                @push function to stack
    movs    r0, #LED_GPIO_PIN                   @load value of #LED_GPIO_PIN to r0
    bl      asm_gpio_init                       @Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #LED_GPIO_PIN                   @ Reload the value of #LED_GPIO_PIN into register r0
    movs    r1, #LED_GPIO_OUT                   @ Load the value of #LED_GPIO_OUT into register r1
    bl      asm_gpio_set_dir                    @ Call the subroutine to set the direction of the GPIO pin
    pop     {pc}                                @exit func

@ Subroutine used to install the SVC interrupt service handler
install_svc_isr:
    ldr r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)    @ <loads contents of address PPB_BASE + M0PLUS_VTOR_OFFSET into reg 2
    ldr r1, [r2]                                @ loading address from r2 into r1
    movs r2, #SVC_ISR_OFFSET                    @ now load #SVC_ISR_OFFSET into r2
    add r2, r1                                  @ add r1 and r2 together
    ldr r0, =svc_isr                            @ loading r2 into r0
    str r0, [r2]                                @ storing r0 into address of r2
    bx lr                                       @ exit func

@ SVC interrupt service handler routine
.thumb_func                                     @ Required for all interrupt service routines
svc_isr:
    push {lr}                                   @ push function address to stack
    ldr r0, [sp, #0x1C]                         @ load content of address sp, #0x1C into r0
    subs r0, #0x2                               @ subtract 2 from r0
    ldr r0, [r0]                                @ load address of r0 to r0
    ldr r1, =#0xFF                              @ load 0xFF into r1
    ands r0, r1                                 @ This gets rid of all bits except for the 8 rightmost bits
    cmp r0, #SVC_MAX_INSTRS                     @ check if its a valid SVC func
    bgt svc_done                                @ end subroutine if invalid
    adr r1, svc_jmptbl                          @ load address of jump table to r1
    lsls r0, #2                                 @ shift contents of r2 2 bits to the left
    ldr r1, [r1, r0]                            @ load address of r1+r0 into r1
    mov pc, r1                                  @ exit func


svc_done:
    pop {pc}                                    @ when svc is done pop the stack


@ First function of SVC subroutine - turn on the LED
svc_num0:
    movs   r1,#LED_VALUE_ON                     @load turn on value to r1
    movs   r0,#LED_GPIO_PIN                     @load GPIO pin number for LED intp r0
    bl     asm_gpio_put                         @call subroutine to control led
    b      svc_done                             @ Branch back to the main ISR when done


@ Second function of SVC subroutine - turn off the LED
svc_num1:
    movs   r1, #LED_VALUE_OFF                   @load turn off value to r1
    movs   r0,#LED_GPIO_PIN                     @load GPIO pin number for LED intp r0
    bl     asm_gpio_put                         @call subroutine to control led
    b      svc_done                             @ Branch back to the main ISR when done


@ SVC function entry jump table.
.align 2
svc_jmptbl:
    .word svc_num0                               @ Entry zero goes to SVC function #0.
    .word svc_num1                               @ Entry one goes to SVC function #1.
     .word 0                                     @ Null termination of the jump table.


@ Set data alignment
.data
 .align 4