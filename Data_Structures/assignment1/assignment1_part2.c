#include<stdio.h>
#include<stdlib.h>
#include <string.h> //for strcpy and strcmp
#include <ctype.h>  //for isalnum

// NB: this skeleton is here to help you - ignore anything that does not help you
// There are a lot of others (and better!) ways of doing this

// note this sekeleton uses a global variable. It therefore will only work with 
// one hashtable, of the size set. In general global variables should be avoided
// as their global scope makes it very challenging to see where they are updated 
// (as it can be anywhere!), and don't work well when several threads/programs
// update them at the same time (concurency), amongst others problems.
// Having said that, they can make coding a bit easier, so that's why we are using 
// one here. If you can, try using a hashTable as a variable, passing it as a 
// parameter to functions!

//NOTES:
//Hash Tables like car parks, go space to space trying to find a space, if space is fill (collision++) and note what type of car it is (name count++)

#define MAX_STRING_SIZE 20 //max length of a string
#define ARRAY_SIZE 59  //best be prime
#define NAME_PROMPT "Enter term to get frequency or type \"quit\" to escape\n" //you can use this string as your invitation to the user
#define NEW_LINE_PROMPT ">>> " //you can use this string as your invitation to the user where the user should input the name

typedef struct Element Element;
struct Element{
    char name[MAX_STRING_SIZE];
    int count;
};

Element* hashTable[ARRAY_SIZE]; //array with 59 items with nothing in them
int collisions = 0;
int num_terms = 0;

int hash_function(char* s){ // generate usung a function where in the array the name goes
    int hash = 0;
    while(*s){
       hash = (hash * 47 + *s) %ARRAY_SIZE;
        s++;
    }
    return hash;
}

Element* createNewElement(char* name, Element* ht[]) {
    Element* newElement = (Element*) malloc(sizeof(Element)); // Allocate memory for the new Element
    
    if(newElement == NULL) { // Check if memory allocation was a success, if not print error message and exit
        printf("Error: Memory allocation failed\n");
        exit(1);
    }
    
    strncpy(newElement->name, name, MAX_STRING_SIZE - 1); // copy the name to the Element's name field
    newElement->name[MAX_STRING_SIZE - 1] = '\0'; // Make sure the string is null-terminated
    newElement->count = 1; // Initialize the count to 1, this is teh first time this name has appeared 

    int initial_slot = hash_function(name);
    int current_slot = initial_slot;

    while (ht[current_slot] != NULL){ //while the current slot is taken, add 1 to collisions and move onto the next spot
        collisions++; 
        current_slot = (current_slot + 1) % ARRAY_SIZE;

        if(current_slot == initial_slot){ // if the fucntion goes through the whole hash table and returns to the first slot, the hash table is full and can't take anymore data
            printf("Hash Table is full\n");
            free(newElement); //this frees the memory that was allocated previously for this element
            return NULL;
        }
    }

    ht[current_slot] = newElement; //save the new element to the slot that the function stopped on

    return newElement;


}

// returns the element with name name or NULL if the element is not present
Element* search (char* name,Element* ht[]){
    int list_loc = hash_function(name);

    if(ht[list_loc]==NULL){ //if the position on the hash table is taken by null, return null to the user 
        return NULL;
    }
    if(strcmp(ht[list_loc]->name,name) == 0){//strcmp compares two values-so if it equals 0 they're identical
        return ht[list_loc];
    }
    int current_location = (list_loc+1) % ARRAY_SIZE;
    int initial_location = list_loc;

    while(ht[current_location] != NULL){
        if(strcmp(ht[current_location]->name,name)==0){
            return ht[current_location];
        }

        current_location=(current_location+1) % ARRAY_SIZE;

        if (current_location==initial_location){
            break;
        }
    }

    return NULL;


}

// assuming that no element of key name is in the list (use search first!), add element at the correct place in the list
// NB: it would be more efficient for search to return the index where it should be stored directly, but aiming for simplicity here!
void insert(char* name, Element* ht[]){
 int list_loc =hash_function(name);
 if (ht[list_loc] == NULL){
    ht[list_loc]=createNewElement(name, ht);
 } else{
    collisions++;
 }
 
}

// prints the number of occurences, or 0 if not in the file
void printNumberOfOccurences(char* name, Element* ht[]){
    //TODO5
    Element* foundElement = search(name,ht);
    if(foundElement == NULL){
        printf("%s - 0 \n", name);
    } 
    else{
        printf("%s - %d \n", name, foundElement->count); //this prints the name and the number of times it was found in the list
    }
    
    
}

//searches the name in the array, if it is there increment its count, if not, add it
void addOrIncrement(char* name,Element* ht[]){
 Element* foundElement = search(name,ht);   
if(foundElement != NULL){
    foundElement->count++;
}
else{
    createNewElement(name,ht);
}
}



// From assignment 0
// Reads strings of alpha numeric characters from input file. Truncates strings which are too long to string_max-1
void next_token ( char *buf, FILE *f, int string_max ) {
	// start by skipping any characters we're not interested in
	buf[0] = fgetc(f);
	while ( !isalnum(buf[0]) && !feof(f) ) { buf[0] = fgetc(f); }
	// read string of alphanumeric characters
	int i=1;
	for (;;) {
		buf[i] = fgetc(f);                // get next character from file
		if( !isalnum(buf[i]) ) { 
            if(buf[i]!=' '){ // we still want to keep spaces
                break; // only load letters and numbers
            }
        } 
		if( feof(f) ) { break; }          // file ended?
		if( i < (string_max-1) ) { ++i; } // truncate strings that are too long
	}
	buf[i] = '\0'; // NULL terminate the string
}


//  Reads the contents of a file and adds them to the hash table - returns 1 if file was successfully read and 0 if not.
int load_file ( char *fname, Element* ht[] ) {
	FILE *f;
	char buf[MAX_STRING_SIZE];

	// boiler plate code to ensure we can open the file
	f = fopen(fname, "r");
	if (!f) { 
		printf("Unable to open %s\n", fname);
		return 0; 
	}
	
	// read until the end of the file
	while ( !feof(f) ) {
		next_token(buf, f, MAX_STRING_SIZE);
		addOrIncrement( buf, ht);
	}
    
    printf("File %s loaded\n", fname);
     //TODO7
    for(int i = 0; i<ARRAY_SIZE;i++){
        if(ht[i] != NULL){num_terms++;}}
    float load = (float)num_terms / ARRAY_SIZE;
        
    

    printf(" Capacity: %i\n Num Terms: %i\n Collisions: %i\n Load: %f\n", ARRAY_SIZE, num_terms, collisions,load);
	
	fclose(f);
	return 1;
}


int main ( int argc, char *argv[] ) {
    
	//TODO0
	//advice: follow the TODO number order
	//first test insert and search
    //then move on to addOrIncrement
    //only then worry about loading the file - see the function above and assignment 0 as to have to use arguments for your executable
    //and later again about an interactive interface - see the assignment 0 solution and the #define strings above
 if (load_file(argv[1], hashTable)) {
        char input[MAX_STRING_SIZE];
        printf(NAME_PROMPT);

        while (1) {
            printf(NEW_LINE_PROMPT);  
            fgets(input, sizeof(input), stdin);

          
            size_t len = strlen(input);
            if (len > 0 && input[len - 1] == '\n') {
                input[len - 1] = '\0';
            }

            if (strcmp(input, "quit") == 0) {
                break;
            }

            printNumberOfOccurences(input, hashTable);
        }
    } else {
        printf("Error loading file %s\n", argv[1]);
    }

    
    
    return 0;
}