#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include "pico/stdlib.h"
#include "pico/float.h"     // Required for using single-precision variables.
#include "pico/double.h"    // Required for using double-precision variables.
#include "pico/multicore.h" // Required for using multiple cores on the RP2040.

/**
 * @brief LAB #07 - TEMPLATE
 *        Main entry point for the code.
 * 
 * @return int      Returns exit-status zero on completion.
 */

// Function to get the enable status of the XIP cache
bool get_xip_cache_en(){
    uint8_t * p = (uint8_t *)(XIP_CTRL_BASE); //pointer to the XIP controller base address 
    return p[0]; //return status
}
// Function to set the enable status of the XIP cache
bool set_xip_cache_en(bool cache_en){
    uint8_t * p = (uint8_t *)(XIP_CTRL_BASE); //pointer to the XIP controller base address 
    p[0] = cache_en; //set status
    return cache_en; //return new status
}

void core1_entry() {
    while (1) { //infinite loop
        // 
        int32_t (*func)() = (int32_t(*)()) multicore_fifo_pop_blocking(); //recieve a function pointer from core 0 through FIFO queue
        int32_t p = multicore_fifo_pop_blocking(); //recieve parameter for teh fucntion of core 0 
        int32_t result = (*func)(p); //execute function using recieved parameters
        multicore_fifo_push_blocking(result); //push result back to core 0
    }
}
//single precision
float calcPiSinglePrecision(int ITER_MAX){
    uint64_t start = time_us_64();
    float piApprox = 1.0f;

    for(int i = 1; i <= ITER_MAX;i++){
        piApprox *= ((2.0f * i) / (2.0f * i - 1.0f)) * ((2.0f * i) / (2.0f * i + 1.0f)); //iterate through each series starting with ((2/1)*(2/3))
    }
    uint64_t end = time_us_64();
    double total = end - start;
    printf("Single precision execution time = %.0f\n", total);
    return 2.0f * piApprox; //formula is for pi/2 so to get pi we times by 2 to finish

   
}
//double precision
double calcPiDoublePresision(int ITER_MAX){ //similar to singe precision function but using doubles
    uint64_t start = time_us_64();
    double piApprox = 1.0;

    for(int i = 1;i <= ITER_MAX; i++){
        piApprox *= ((2.0 * i) / (2.0 * i - 1.0)) * ((2.0 * i) / (2.0 * i + 1.0));
    }
    uint64_t end = time_us_64();
    double total = end - start;
    printf("Double precision execution time = %.0f\n", total);
    return 2.0 * piApprox;
}
int main() {
    
    const int    ITER_MAX   = 100000;

    stdio_init_all();
    multicore_launch_core1(core1_entry);
    uint64_t singleTimeStart, singleTimeEnd;
    uint64_t parallelTimeStart, parallelTimeEnd;
    double singleTimeTotal, parallelTimeTotal;
    //cache enabled and measure execution time for single core for single and double precision
    set_xip_cache_en(1);
    singleTimeStart = time_us_64();
    calcPiSinglePrecision(ITER_MAX);
    calcPiDoublePresision(ITER_MAX);
    singleTimeEnd=time_us_64();
    singleTimeTotal = (double)(singleTimeEnd - singleTimeStart);
    printf("The total time for both single core functions to execute with cache enabled = %.0f\n\n", singleTimeTotal);

     //cache disabled and measure execution time for single core for single and double precision
    set_xip_cache_en(0);
    singleTimeStart = time_us_64();
    calcPiSinglePrecision(ITER_MAX);
    calcPiDoublePresision(ITER_MAX);
    singleTimeEnd=time_us_64();
    singleTimeTotal = (double)(singleTimeEnd - singleTimeStart);
    printf("The total time for both single core functions to execute with cache disabled = %.0f\n\n", singleTimeTotal);

     //cache enabled and measure execution time for multicore for single and double precision
    set_xip_cache_en(1);
    parallelTimeStart = time_us_64();
    multicore_fifo_push_blocking((uintptr_t) calcPiDoublePresision);
    multicore_fifo_push_blocking(ITER_MAX);
    calcPiDoublePresision(ITER_MAX);
    multicore_fifo_pop_blocking();
    parallelTimeEnd = time_us_64();
    parallelTimeTotal = (double) parallelTimeEnd - parallelTimeStart;
    printf("The total time for both multi core functions to execute with cache enabled = %.0f\n\n", parallelTimeTotal);

     //cache disabled and measure execution time for multicore for single and double precision
    set_xip_cache_en(0);
    parallelTimeStart = time_us_64();
    multicore_fifo_push_blocking((uintptr_t) calcPiDoublePresision);
    multicore_fifo_push_blocking(ITER_MAX);
    calcPiDoublePresision(ITER_MAX);
    multicore_fifo_pop_blocking();
    parallelTimeEnd = time_us_64();
    parallelTimeTotal = (double) parallelTimeEnd - parallelTimeStart;
    printf("The total time for both multi core functions to execute with cache disabled = %.0f\n\n", parallelTimeTotal);

    return 0;
}





