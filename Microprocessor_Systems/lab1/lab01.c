#include "pico/stdlib.h"

/**
 * @brief Toggle the LED state and sleep for the specified time.
 * 
 * @param pin The LED pin number.
 * @param delay The sleep delay in milliseconds.
 */
void LEDfunc(uint pin, uint delay) {
    gpio_put(pin, 1);   // Toggle the LED on
    sleep_ms(delay);    // Sleep for delay period
    gpio_put(pin, 0);   // Toggle the LED off
    sleep_ms(delay);    // Sleep for delay period
}



int main() {
    // Specify the PIN number and sleep delay
    const uint LED_PIN   =  25;
    const uint LED_DELAY = 500;

    // Setup the LED pin as an output.
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    // Do forever...
    while (true) {
        // Call the toggleLED subroutine with LED_PIN and LED_DELAY parameters
        LEDfunc(LED_PIN, LED_DELAY);
    }

    // Should never get here due to infinite while-loop.
    return 0;
}