#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include "pico/stdlib.h"
#include "pico/float.h"     // Required for using single-precision variables.
#include "pico/double.h"    // Required for using double-precision variables.
#include "pico/multicore.h" // Required for using multiple cores on the RP2040.

/**
 * @brief LAB #06 - TEMPLATE
 *        Main entry point for the code.
 * 
 * @return int      Returns exit-status zero on completion.
 */

void core1_entry() {
    while (1) {
        // 
        int32_t (*func)() = (int32_t(*)()) multicore_fifo_pop_blocking();
        int32_t p = multicore_fifo_pop_blocking();
        int32_t result = (*func)(p);
        multicore_fifo_push_blocking(result);
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

    singleTimeStart = time_us_64();
    calcPiSinglePrecision(ITER_MAX);
    calcPiDoublePresision(ITER_MAX);
    singleTimeEnd = time_us_64();
    singleTimeTotal = (double) (singleTimeEnd - singleTimeStart);
    printf("Total execution time for both functions with single core = %.0f\n\n", singleTimeTotal);


    parallelTimeStart = time_us_64();
    multicore_fifo_push_blocking((uintptr_t) calcPiDoublePresision);
    multicore_fifo_push_blocking(ITER_MAX);
    calculatePiFloat(ITER_MAX);
    multicore_fifo_pop_blocking();
    parallelTimeEnd = time_us_64();
    parallelTimeTotal = (double) parallelTimeEnd - parallelTimeStart;
    printf("Total execution time for both functions with multi core = %.0f\n\n\n", parallelTimeTotal);


    // Code for sequential run goes here…
    //    Take snapshot of timer and store
    //    Run the single-precision Wallis approximation
    //    Run the double-precision Wallis approximation
    //    Take snapshot of timer and store
    //    Display time taken for application to run in sequential mode

    // Code for parallel run goes here…
    //    Take snapshot of timer and store
    //    Run the single-precision Wallis approximation on one core
    //    Run the double-precision Wallis approximation on the other core
    //    Take snapshot of timer and store
    //    Display time taken for application to run in parallel mode

    return 0;
}





