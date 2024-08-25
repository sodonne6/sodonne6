#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "ws2812.pio.h"
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "hardware/watchdog.h"
#include "hardware/pio.h"
#include "hardware/clocks.h"

#define IS_RGBW true        // Will use RGBW format
#define NUM_PIXELS 1        // There is 1 WS2812 device in the chain
#define WS2812_PIN 28       // The GPIO pin that the WS2812 connected to
#define MAX_INPUT_SIZE 16  

// Global Variables
int lives, currentLevel;
int sequence[MAX_INPUT_SIZE];
int levelSelectionInput[4];

// Array of alphanumeric characters
char alphaNum[36] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
                    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
                    'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3',
                    '4', '5', '6', '7', '8', '9'};

char *alphaNumMorseCode[36] = {".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", ".---",
                    "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-",
                    "..-", "...-", ".--", "-..-", "-.--", "--..", "-----", ".----", "..---", "...--",
                    "....-", ".....", "-....", "--...", "---..", "----."};

char *alphaNumBinary[36] = {"01", "1000", "1010", "100", "0", "0010", "110", "0000", "00", "0111",
                            "101", "0100", "11", "10", "111", "0101", "1101", "010", "000", "1",
                            "001", "0001", "011", "1001", "1011", "1100", "11111", "01111", "00111", "00011",
                            "00001", "00000", "10000", "11000", "11100", "11110"};

char *words[15] = {"Apple", "Bus", "Fun", "Dog", "Cat", "Rock", "Ball", "Cup", "Pen", "Car",
                   "Sun", "Moon", "Star", "Tree", "Bird"};

char *wordsMorseCode[15] = {".-.--..--..-...", "-.....-...", "..-...--.", "-..-----.", 
                            "-.-..--", ".-.----.-.-.-", "-....-.-...-..", "-.-...-.--.", 
                            ".--..-.", "-.-..-.-.", "...-.", "--...--", "...-...-", 
                            "-.--.-.-", "-.---..-"};

char *wordsBinary[15] = {"010110011001000", "1000001000", "001000110", 
                        "100111110", "1010011", "0101111010101", 
                        "10000101000100", "10100010110", "011001101", 
                        "101001010", "00010", "1100011", "00010001", "10110101", "10111001"};




// Declare the main assembly code entry point.
void main_asm();
// Initialise a GPIO pin – see SDK for detail on gpio_init()
void asm_gpio_init(uint pin) {
 gpio_init(pin);
}
// Set direction of a GPIO pin – see SDK for detail on gpio_set_dir()
void asm_gpio_set_dir(uint pin, bool out) {
 gpio_set_dir(pin, out);
}
// Get the value of a GPIO pin – see SDK for detail on gpio_get()
bool asm_gpio_get(uint pin) {
 return gpio_get(pin);
}
// Set the value of a GPIO pin – see SDK for detail on gpio_put()
void asm_gpio_put(uint pin, bool value) {
 gpio_put(pin, value);
}
// Enable falling-edge interrupt – see SDK for detail on gpio_set_irq_enabled()
void asm_gpio_set_irq(uint pin) {
 gpio_set_irq_enabled(pin, GPIO_IRQ_EDGE_FALL | GPIO_IRQ_EDGE_RISE, true);
}

void printLine(const char *line) {
    printf("%s\n", line);
}

/**
 * @brief wrapper function to push 32-bit RGB colour value out to LED serially
 *
 * @param pixel_grb
 */
static inline void put_pixel(uint32_t pixel_grb)
{
    pio_sm_put_blocking(pio0, 0, pixel_grb << 8u);
}


/**
 * @brief ensures that the first 8 bits affect the red of the LED, middle 8 the green and last on blue
 *
 * @param r
 * @param g
 * @param b
 * @return uint32_t
 */
static inline uint32_t urgb_u32(uint8_t r, uint8_t g, uint8_t b)
{
    return ((uint32_t)(r) << 8) |
           ((uint32_t)(g) << 16) |
           (uint32_t)(b);
}

/**
 * @brief changes colour of the LED depending on the life count
 *
 * @param lives
 */
 //logic for led color depending on life count
void life_indicator(int lives)
{
    if (lives == 3)
    {
        put_pixel(urgb_u32(0x00, 0x2F, 0x00)); // green
    }
    else if (lives == 2)
    {
        put_pixel(urgb_u32(0x2F, 0x2F, 0x00)); // yellow
    }
    else if (lives == 1)
    {
        put_pixel(urgb_u32(0x2F, 0xC, 0x00)); // orange
    }
    else if (lives == 0)
    {
        put_pixel(urgb_u32(0x2F, 0x00, 0x00)); // red
    }
    else
        put_pixel(urgb_u32(0x00, 0x00, 0x2F)); // blue
}

void printstartscreen(){
   printLine("###########################################");
   printLine("#                                         #");
   printLine("#  #      ####    ###      ###    ##   #  #");
   printLine("#  #      #      #####    #   #   # #  #  #");
   printLine("#  #      ####  ##   ##   ####    #  # #  #");
   printLine("#  #      #     #######   ###     #   ##  #");
   printLine("#  #####  ####  ##   ##   #  ##   #    #  #");
   printLine("#                                         #");
   printLine("#                                         #");
   printLine("#  #       #   ###   ####   ####  #####   #");
   printLine("#  ##     ##  #   #  #  ##  #     #       #");
   printLine("#  # #   # #  #   #  ####   ####  #####   #");
   printLine("#  #  # #  #  #   #  ###       #  #       #");
   printLine("#  #   #   #   ###   #  #   ####  #####   #");
   printLine("#                                         #");
   printLine("###########################################");
   printLine("#                                         #");
   printLine("#     USE GP21 TO ENTER A SEQUENCE TO     #");
   printLine("#              BEGIN                      #");
   printLine("#  ....    - LEVEL 01 - CHARS (EASY)      #");
   printLine("#  .-.-    - LEVEL 02 - CHARS (HARD)      #");
   printLine("#  --..    - LEVEL 03 - WORDS (EASY)      #");
   printLine("#  ..--    - LEVEL 04 - WORDS (HARD)      #");
   printLine("#                                         #");
   printLine("###########################################");
   printf("\n\nSelect a level: ");


 }

void printlevel1screen(){
     printLine("###########################################");
     printLine("#                                         #");
     printLine("#  #    #### #       # #### #       ##    #");
     printLine("#  #    #     #     #  #    #      ###    #");
     printLine("#  #    ####   #   #   #### #        #    #");
     printLine("#  #    #       # #    #    #        #    #");
     printLine("#  #### ####     #     #### ####   #####  #");
     printLine("#                                         #");
     printLine("###########################################");
  
}

void printlevel2screen(){
     printLine("###########################################");
     printLine("#                                         #");
     printLine("#  #    #### #       # #### #      #####  #");
     printLine("#  #    #     #     #  #    #          #  #");
     printLine("#  #    ####   #   #   #### #      #####  #");
     printLine("#  #    #       # #    #    #      #      #");
     printLine("#  #### ####     #     #### ####   #####  #");
     printLine("#                                         #");
     printLine("###########################################");
}

void printlevel3screen(){
     printLine("###########################################");
     printLine("#                                         #");
     printLine("#  #    #### #       # #### #      #####  #");
     printLine("#  #    #     #     #  #    #          #  #");
     printLine("#  #    ####   #   #   #### #      #####  #");
     printLine("#  #    #       # #    #    #          #  #");
     printLine("#  #### ####     #     #### ####   #####  #");
     printLine("#                                         #");
     printLine("###########################################");
}

void printlevel4screen(){
     printLine("###########################################");
     printLine("#                                         #");
     printLine("#  #    #### #       # #### #      #   #  #");
     printLine("#  #    #     #     #  #    #      #   #  #");
     printLine("#  #    ####   #   #   #### #      #####  #");
     printLine("#  #    #       # #    #    #          #  #");
     printLine("#  #### ####     #     #### ####       #  #");
     printLine("#                                         #");
     printLine("###########################################");
}

bool inGame = false;   //have a bool to keep track whether a game has started or not
int count = 0; //keep track of the number of entries into levelSelectionArray
int levelSelectionArray[4];


//can add error detection to both comparison functions below

//Function to compare arrays
//Returns 1 if true, 0 if false
int compareArrays(int arr1[], int arr2[], int size){

    for (int i = 0; i < size; i++) {
        if (arr1[i] != arr2[i]) {
            return 0; // Arrays are not equal
        }
    }

    return 1;
}

char binaryString[10]; // Adjust size as needed

void binaryIntArrayToString(const int binaryIntegers[], int size, char* binaryString) {
    // Initialize the binaryString
    binaryString[0] = '\0'; // Empty string

    // Convert each binary integer to a string and append it
    for (int i = 0; i < size; ++i) {
        sprintf(binaryString + strlen(binaryString), "%d", binaryIntegers[i]);
    }

}

int *stringToBinaryArray(const char *binaryString, size_t length) {
    int *binaryArray = malloc(length * sizeof(int));
    if (binaryArray == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }

    for (size_t i = 0; i < length; i++) {
        if (binaryString[i] == '0') {
            binaryArray[i] = 0;
        } else if (binaryString[i] == '1') {
            binaryArray[i] = 1;
        } else {
            fprintf(stderr, "Invalid character found: %c\n", binaryString[i]);
            exit(1);
        }
    }

    return binaryArray;
}

int compareStrings(const char* str1, const char* str2) {
    return strcmp(str1, str2);
}


int level1[4] = {0,0,0,0};
int level2[4] = {0,1,0,1};
int level3[4] = {1,1,0,0};
int level4[4] = {0,0,1,1};

//returns level selection
int levelSelection(int input[]){
    if(compareArrays(input, level1, 4) == 1){
        return 1;
    }
    if(compareArrays(input, level2, 4) == 1){
        return 2;
    }
    if(compareArrays(input, level3, 4) == 1){
        return 3;
    }
    if(compareArrays(input, level4, 4) == 1){
        return 4;
    }

    return 0;
}

char returnMorse(int i){
    if(i == 0){
        return '.';
    }else{
        return '-';
    }
}

bool readingIn = false;
int morseLevelArray[MAX_INPUT_SIZE]; //used inside levels
int morseLength; //used to calculate the length of morse code to read in
int rngGlobal;
int levelRound = 1;
bool levelStarted = false;

//contains all the logic for level 1
void level1Logic(int i){
    //print level start screen if level hasnt started yet
    if(!levelStarted){
        printlevel1screen();
        printf("\nEnter the following 5 Characters:\n");
        levelStarted = true;
    }
    //count keeps track of game state. ie; count = 0 when player needs new character
    else if(count == 0){    
        rngGlobal = rand() % 36;
        printf("%c: %s\n   ", alphaNum[rngGlobal], alphaNumMorseCode[rngGlobal]);
        morseLength = strlen(alphaNumMorseCode[rngGlobal]); //find the length of the morse code player needs to input
    }
    //this block enters when player is inputting morse code
    else{

        printf("%c", returnMorse(i));   
        morseLevelArray[count-1] = i;   //read in player input

        //enters when player inputs same number of characters as character they are trying to replicated
        if(count == (morseLength)){ 
            binaryIntArrayToString(morseLevelArray, (morseLength), binaryString);

            if(compareStrings(binaryString, alphaNumBinary[rngGlobal])){
                lives--;
                printf("\nWrong!\nLives remaining: %i\n", lives);
                if(lives == 0){
                    printf("Level 1 Failed :(\n");
                    printf("\nReturning to main menu\n\n");
                    printstartscreen();

                    inGame = false;
                }
            }else{
                printf("\nCorrect!\n");
                levelRound++;
                if(levelRound == 6){
                    printf("Level 1 Complete!\n");
                    printf("\nProgressing to Level 2!\n\n");
                    printlevel2screen();
                    currentLevel = 2;
                }
            }

            count = -1;
        }
    }

}

void level2Logic(int i){
    //print level start screen if level hasnt started yet
    if(!levelStarted){
        printlevel2screen();
        printf("\nEnter the following 5 Characters:\n\n");
        levelStarted = true;
    }
    //count keeps track of game state. ie; count = 0 when player needs new character
    else if(count == 0){    
        rngGlobal = rand() % 36;
        printf("%c: ", alphaNum[rngGlobal]);
        morseLength = strlen(alphaNumMorseCode[rngGlobal]); //find the length of the morse code player needs to input
    }
    //this block enters when player is inputting morse code
    else{

        printf("%c", returnMorse(i));   
        morseLevelArray[count-1] = i;   //read in player input

        //enters when player inputs same number of characters as character they are trying to replicated
        if(count == (morseLength)){ 
            binaryIntArrayToString(morseLevelArray, (morseLength), binaryString);

            if(compareStrings(binaryString, alphaNumBinary[rngGlobal])){
                lives--;
                printf("\nWrong! Correct input: %s\nLives remaining: %i\n", alphaNumMorseCode[rngGlobal], lives);
                if(lives == 0){
                    printf("Level 2 Failed :(\n");
                    printf("\nReturning to main menu\n\n");

                    printstartscreen();
                    inGame = false;
                }
            }else{
                printf("\nCorrect!\n");
                levelRound++;
                if(levelRound == 6){
                    printf("Level 2 Complete!\n");
                    printf("\nProgressing to Level 3!\n\n");
                    printlevel3screen();
                    currentLevel = 3; 
                }
            }

            count = -1;
        }
    }
}

void level3Logic(int i){
    //print level start screen if level hasnt started yet
    if(!levelStarted){
        printlevel3screen();
        printf("\nEnter the following 5 Words:\n\n");
        levelStarted = true;
    }
    //count keeps track of game state. ie; count = 0 when player needs new character
    else if(count == 0){    
        rngGlobal = rand() % 15;
        printf("%s: %s\n   ", words[rngGlobal], wordsMorseCode[rngGlobal]);
        morseLength = strlen(wordsMorseCode[rngGlobal]); //find the length of the morse code player needs to input
    }
    //this block enters when player is inputting morse code
    else{

        printf("%c", returnMorse(i));   
        morseLevelArray[count-1] = i;   //read in player input

        //enters when player inputs same number of characters as character they are trying to replicated
        if(count == (morseLength)){ 
            binaryIntArrayToString(morseLevelArray, (morseLength), binaryString);
            if(compareStrings(binaryString, wordsBinary[rngGlobal])){
                lives--;
                printf("\nWrong! Correct input: %s\nLives remaining: %i\n\n", wordsMorseCode[rngGlobal], lives);
                if(lives == 0){
                    printf("Level 3 Failed :(\n");
                    printf("\nReturning to main menu\n\n");

                    printstartscreen();
                    inGame = false;
                }
            }else{
                printf("\nCorrect!\n");
                levelRound++;
                if(levelRound == 6){
                    printf("Level 3 Complete!\n");
                    printf("\nProgressing to Level 4!\n\n");
                    printlevel4screen();

                    currentLevel = 4; //3 doesnt exist yet
                }
            }

            count = -1;
        }
    }
}

void level4Logic(int i){
    //print level start screen if level hasnt started yet
    if(!levelStarted){
        printlevel3screen();
        printf("\nEnter the following 5 Words:\n\n");
        levelStarted = true;
    }
    //count keeps track of game state. ie; count = 0 when player needs new character
    else if(count == 0){    
        rngGlobal = rand() % 15;
        printf("%s\n   ", words[rngGlobal]);
        morseLength = strlen(wordsMorseCode[rngGlobal]); //find the length of the morse code player needs to input
    }
    //this block enters when player is inputting morse code
    else{

        printf("%c", returnMorse(i));   
        morseLevelArray[count-1] = i;   //read in player input

        //enters when player inputs same number of characters as character they are trying to replicated
        if(count == (morseLength)){ 
            binaryIntArrayToString(morseLevelArray, (morseLength), binaryString);
            if(compareStrings(binaryString, wordsBinary[rngGlobal])){
                lives--;
                printf("\nWrong! Correct input: %s\nLives remaining: %i\n\n", wordsMorseCode[rngGlobal], lives);
                if(lives == 0){
                    printf("Level 3 Failed :(\n");
                    printf("\nReturning to main menu\n\n");

                    printstartscreen();
                    inGame = false;
                }
            }else{
                printf("\nCorrect!\n");
                levelRound++;
                if(levelRound == 6){
                    printf("Level 3 Complete!\n");
                    printf("\nProgressing to Level 4!\n\n");
                    // printstartscreen();

                    currentLevel = 4; //3 doesnt exist yet
                }
            }

            count = -1;
        }
    }
}

void gameLogic(int i){
    //if player is not in game, display homescreen
    if(!inGame){
        life_indicator(4);
        lives = 3;

        levelSelectionArray[count%4] = i;
        printf("%c", returnMorse(i));

        if(((count + 1) % 4) == 0){
            currentLevel = levelSelection(levelSelectionArray);
            if(currentLevel != 0){
                inGame = true;
                printf("\n\nLevel Selected: %i\n", currentLevel);
                printf("\t\n--- Press any button to continue ---\n\n");
                levelStarted = false;
                count = -2;
            }else{
                printf("\n\nInvalid Selection\n");
            }
        }
      
    }
    else{
        //Otherwise enter a level
        switch(currentLevel){
            case 1:
                level1Logic(i);
                break;

            case 2:
                level2Logic(i);
                break;
            case 3:
                level3Logic(i);
                break;
            case 4:
                level4Logic(i);
                break;
        }
    }
  
    life_indicator(lives);
    count++;
}

/*
 * Main entry point for the code - simply calls the main assembly function.
 */
int main() {
    stdio_init_all();
    srand(time(NULL));
   // Initialise the PIO interface with the WS2812 code
    PIO pio = pio0;
    uint offset = pio_add_program(pio, &ws2812_program);
    ws2812_program_init(pio, 0, offset, WS2812_PIN, 800000, IS_RGBW);




    // watchdog_enable(20000, 1); //8 second delay


    // if (watchdog_caused_reboot()) {
    //     printf("\nRebooted by Watchdog!\n");
    // } else{
    //     printf("Continue\n");
    // }

    lives = 3;
    currentLevel = 0;

    // printf("Start Screen  ..--..\n");
    printstartscreen();
    life_indicator(4);


    main_asm();   


   


    // Enable the watchdog, requiring the watchdog to be updated every xms or the chip will reboot
    // second arg is pause on debug which means the watchdog will pause when stepping through code

    //this can be done in c
    // for (uint i = 0; i < 5; i++) {
    //     printf("Updating watchdog %d\n", i);
    //     watchdog_update();
    // }

    // main_asm();
    
    // Wait in an infinite loop and don't update the watchdog so it reboots us
    // printf("Waiting to be rebooted by watchdog\n");
    // while(1);



    return(0);
}

