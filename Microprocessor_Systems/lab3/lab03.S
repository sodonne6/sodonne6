.syntax unified                 @ Specify unified assembly syntax
.cpu    cortex-m0plus           @ Specify CPU type is Cortex M0+
.thumb                          @ Specify thumb assembly for RP2040
.global main_asm                @ Provide program starting address to the linker
.align 4                        @ Specify code alignment

//GP21 of the Raspberry Pi Pico is initialised as an input pin
//The code will poll the status of the button to determine when it is pressed
//The LED will only toggle its state after the button has been pressed

.equ    SLEEP_TIME, 500         @ Specify the amount of ms that we want to sleep for in the loop
.equ    LED_GPIO_PIN, 25        @ Specifiy the physical GPIO pin that the LED is connected to (change to 21 to suit lab)
.equ    LED_GPIO_OUT, 1         @ Specify the direction that we want to set the GPIO pin to
.equ    LED_VALUE_ON, 1         @ Specify the value that turns the LED "on"
.equ    LED_VALUE_OFF, 0        @ Specify the value that turns the LED "off"
.equ    BUTTON_PIN, 21
.equ    LED_GPIO_IN, 0
.equ    BUTTON_PRESS, 0


@ Entry point to the ASM portion of the program
main_asm:
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board
    movs    r1, #LED_GPIO_OUT           @ We want this GPIO pin to be setup as an output pin
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1

    @INITIALISE LED PIN ON BOARD
    movs    r0, #BUTTON_PIN             @ This value is the Button pin on the PI PICO board
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #BUTTON_PIN             @ This value is the Button Pin on the PI PICO board
    movs    r1, #LED_GPIO_IN            @ We want this GPIO pin to be setup as an input pin
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
loop:
    bl      press_check                 @Call press check subroutine 
    b       loop                        @ Repeat the loop


@subroutine for checking if the button has been pressed
press_check:
    push    {lr}                        @Push link register into the stack to save the return address
    movs    r0, #BUTTON_PIN             @Load the relevant pin number into the r0 register
    bl      asm_gpio_get                @call subroutine asm_gpio_get to get the current state of the Button pin and store in r0
    cmp     r0,#BUTTON_PRESS            @Comapre current state of pin to with BUTTON_PRESS constant
    beq     sub_toggle                  @Branch to subtoggle if the two values are equal representing that the button has been pressed
    pop     {pc}                        @pop the value from the stack into the program counter which restores the original value of lr 

@ Subroutine to toggle the LED GPIO pin value
sub_toggle:
    push    {lr}                        @ Store the link register to the stack as we will call nested subroutines
    movs    r0, #LED_GPIO_PIN           @ Set the LED GPIO pin number to r0 for use by asm_gpio_get
    bl      asm_gpio_get                @ Get current the value of the LED GPIO pin (returns to r0)
    cmp     r0, #LED_VALUE_OFF          @ Check if the LED GPIO pin value is "off"
    beq     led_set_on                  @ If it is "off" then then jump code to to turn it on
led_set_off:
    movs    r1, #LED_VALUE_OFF          @ The LED is currently "on" so we want to turn it "off"
    b       led_set_state               @ Jump to portion of code where we set the state of the LED
led_set_on:
    movs    r1, #LED_VALUE_ON           @ The LED is currently "off" so we want to turn it "on"
led_set_state:
    movs    r0, #LED_GPIO_PIN           @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    bl      asm_gpio_put                @ Update the the value of the LED GPIO pin (based on value in r1)
    pop     {pc}                        @ Pop the link register from the stack to the program counter


@ Set data alignment
.data
    .align 4
