#include "t1.h"
#include "t2.h"
#include <stdio.h> 
#include <stdlib.h>
#include <string.h>

#define MAX_BUFFER 256 // Maximum string length this program can handle
#define MAX_NB_T4_IGN 649 // Maximum number of Pokemons

//read in csv
//goal is to find the top ten games of the last 20 years
//eliminate games that came out in 2002 or earlier 
//put all in array and quick sort so that they're in ascending or descending order so that the top ten are either the first ten or last 10
//the relevant data lines are the title, score, and release year
//title- to ensure the top ten titles can be read out
//score - this will be used to sort the most popular games
//release year - to ensure we are only looking at games from the last 20 years (2003-2023)

void swap(int*a, int *b){
    int temp =*a;
    *a = *b;
    *b = temp;
}


void quickSortHelper(int arr[], int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);
        quickSortHelper(arr, low, pi - 1);
        quickSortHelper(arr, pi + 1, high);
    }
}

int partition(int arr[], int low, int high) { //low and high represents the lower and higher bound of the lower bound of the sub array
    int pivot = arr[high]; //pivot is chosen to be the last element in the array
    int i = low - 1; //the job of i is to keep track of of where in the array the elements are less than the pivot value. It's initialised as low -1 

    for (int j = low; j <= high - 1; j++) { //this for loop compares each value to the pivot
        if (arr[j] < pivot) {
            i++;
            swap(&arr[i], &arr[j]);
        }
        number_comparisons++;
    }
    swap(&arr[i + 1], &arr[high]); //if the value is greater than the pivot swap that value with the last value in array
    return (i + 1);
}

void quickSort(int arr[], int size) {
    number_comparisons = 0;
    number_swaps = 0;

    quickSortHelper(arr, 0, size - 1);
}

//-----------------------------------------------------------------------------------------------------------------------------------------

struct t4_ign {
	int title, platform, score, release_year;
	char name[MAX_BUFFER], score[MAX_BUFFER], release_year[MAX_BUFFER];
};

// The CSV parser
int
next_field( FILE *f, char *buf, int max ) {
	int i=0, end=0, quoted=0;
	
	for(;;) {
		// fetch the next character from file		
		buf[i] = fgetc(f);
		// if we encounter quotes then flip our state and immediately fetch next char
		if(buf[i]=='"') { quoted=!quoted; buf[i] = fgetc(f); }
		// end of field on comma if we're not inside quotes
		if(buf[i]==',' && !quoted) { break; }
		// end record on newline or end of file
		if(feof(f) || buf[i]=='\n') { end=1; break; } 
		// truncate fields that would overflow the buffer
		if( i<max-1 ) { ++i; } 
	}

	buf[i] = 0; // null terminate the string
	return end; // flag stating whether or not this is end of the line
}
// Stuff to make life a bit neater in main
void
fetch_t4_ign(  FILE *csv, struct t4_ign *p) {
	char buf[MAX_BUFFER];

	 
	next_field( csv, p->title, MAX_BUFFER );  // name and type are just strings so read
	 // those directly into the struct
	

    next_field( csv, buf, MAX_BUFFER ); 
	// Load all the pokemon's stats from the file using buffer as intermediary
	next_field( csv, buf, MAX_BUFFER );
	p->score = atoi(buf);          // atoi stands for ASCII to Integer
	next_field( csv, buf, MAX_BUFFER ); // It converts strings to numbers
	p->release_year = atoi(buf);                  // It is not a totally safe function to use.
	
	
}

void
print_t4_ign( struct t4_ign *p ) {
	printf("  %s %s%c%s\n", 
			p->name, p->type1, ((p->type2[0])? '/':' '), p->type2 );
	printf(" --------------------------------------------------------------\n");
	printf("| HP: %4d | ATK: %3d | DEF %3d | SPE %3dd | SAT %3d | SDE %3d |\n",
			p->hp, p->attack, p->defense, p->speed, p->sp_atk, p->sp_def );
	printf(" --------------------------------------------------------------\n");
	printf("%s\n", p->desc);
}

int
main ( int argc, char *argv[] ) {
	FILE *f;
	struct t4_ign pArray[MAX_NB_POKEMON];		
	struct t4_ign p;

	// Users must pass the name of the input file through the command line. Make sure
	// that we got an input file. If not, print a message telling the user how to use
	// the program and quit
	if( argc < 2 ) { 
		printf("usage: csv FILE\n"); 
		return EXIT_FAILURE; 
	}

	// Try to open the input file. If there is a problem, report failure and quit
	f = fopen(argv[1], "r");
	if(!f) { 
		printf("unable to open %s\n", argv[1]); 
		return EXIT_FAILURE; 
	}
	
	fetch_t4_ign( f, &p ); // discard the header data in the first line

	// Now read and print pokemon until the end of the file
	int nbt4_ign = 0;
	while(!feof(f)) {
		
		fetch_t4_ign( f, &pArray[nbt4_ign] );
		//print_pokemon( &pArray[nbPokemons] );
		//printf("\n");
		nbt4_ign++;
	}

	float average = 0;
	// now you can do some calculations!
	
	for(int j=0;j<nbt4_ign;j++){
		average += (float)pArray[j].attack;
	}

	average = average/(float)nbt4_ign;

	printf("%f\n", average);

	// Always remember to close the file
	fclose(f);
	return EXIT_SUCCESS;
}
