#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "pico/stdlib.h"
#include "pico/float.h"     // Required for using single-precision variables.
#include "pico/double.h"    // Required for using double-precision variables.
/**
 * @brief LAB #02 - TEMPLATE
 *        Main entry point for the code.
 * 
 * @return int      Returns exit-status zero on completion.
 */

float calcPiSinglePrecision(int maxIter){
    float piApprox = 1.0f;

    for(int i = 1; i <= maxIter;i++){
        piApprox *= ((2.0f * i) / (2.0f * i - 1.0f)) * ((2.0f * i) / (2.0f * i + 1.0f)); //iterate through each series starting with ((2/1)*(2/3))
    }
    return 2.0f * piApprox; //formula is for pi/2 so to get pi we times by 2 to finish
}

double calcPiDoublePresision(int maxIter){ //similar to singe precision function but using doubles
    double piApprox = 1.0;

    for(int i = 1;i <= maxIter; i++){
        piApprox *= ((2.0 * i) / (2.0 * i - 1.0)) * ((2.0 * i) / (2.0 * i + 1.0));
    }
    return 2.0 * piApprox;
}
int main() {
    //constant values
    const int maxIter = 100000;
    const double piRef = 3.14159265359;

    //calculate and output Pi using single precision 
    float singleVal = calcPiSinglePrecision(maxIter);
    printf("Single Precision Pi: %.10f\n",singleVal);

    //calculate approximation error for single precision
    float singleError = fabsf(singleVal - piRef);
    printf("Single Precision Error: %.10f\n",singleError);

    //calculate and output percentage error of single precision
    float singleErrorPercent = ((singleError/piRef)*100);
    printf("Single Precison Error Percentage: %.10f%%\n",singleErrorPercent);

    //calcuate and output using double precision
    double doubleVal = calcPiDoublePresision(maxIter);
    printf("\nDouble Precision Pi: %.10f\n",doubleVal);

    //calculate approximation error for double precision
    double doubleError = fabs(doubleVal - piRef);
    printf("Double Precision Error: %.10f\n", doubleError);

    //calculate and output percentage error of double precision
    double doubleErrorPercent = ((doubleError/piRef)*100);
    printf("Single Precison Error Percentage: %.10f%%\n",doubleErrorPercent);
    // Returning zero indicates everything went okay.
    return 0;
}
