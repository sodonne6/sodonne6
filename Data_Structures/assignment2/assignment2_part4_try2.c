#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_BUFFER 256 // Maximum string length this program can handle
#define MAX_GAME_REVIEWS 1000 // Adjust the maximum number of game reviews as needed

struct GameReview {
    char title[MAX_BUFFER];
    int score[MAX_BUFFER];
    int release_year[MAX_BUFFER];
    
};

// CSV parsing functions
int next_field(FILE *f, char *buf, int max) {
    int i = 0, end = 0, quoted = 0;

    for (;;) {
        // fetch the next character from file		
        buf[i] = fgetc(f);
        // if we encounter quotes then flip our state and immediately fetch the next char
        if (buf[i] == '"') { quoted = !quoted; buf[i] = fgetc(f); }
        // end of field on comma if we're not inside quotes
        if (buf[i] == ',' && !quoted) { break; }
        // end record on newline or end of file
        if (feof(f) || buf[i] == '\n') { end = 1; break; }
        // truncate fields that would overflow the buffer
        if (i < max - 1) { ++i; }
    }

    buf[i] = 0; // null terminate the string
    return end; // flag stating whether or not this is the end of the line
}

void fetch_game_review(FILE *csv, struct GameReview *review) {
    char buf[MAX_BUFFER];

    next_field(csv, review->title, MAX_BUFFER); // Load the title into the struct
    next_field(csv, buf, MAX_BUFFER); // Load the score into a buffer as a string
    review->score = atoi(buf); // Convert the score to a integer
    review->release_year=atoi(buf); // Convert the release year to a integer

}

void release_year_check(struct GameReview reviews[],int num_reviews){
    int q, k;
    struct GameReview temp;

    for(q=0; q<num_reviews - 1; q++){
        for(k=0;j<num_reviews-i-1; k++){
            if(reviews[j].release_year<reviews[j+1].score){
                temp=reviews[j];
                reviews[j]=reviews[j+1];
                reviews[j+1]=temp;
            }
        }
    }
}

// Sorting function (e.g., Bubble Sort for demonstration)
void sort_game_reviews(struct GameReview reviews[], int num_reviews) {
    int i, j;
    struct GameReview temp;
while(reviews[i].release_year>2002){
    for (i = 0; i < num_reviews - 1; i++) {
        for (j = 0; j < num_reviews - i - 1; j++) {
            if (reviews[j].score < reviews[j + 1].score) {
                temp = reviews[j];
                reviews[j] = reviews[j + 1];
                reviews[j + 1] = temp;
            }
        }
    }
}
}
int main(int argc, char *argv[]) {
    FILE *f;
    struct GameReview reviews[MAX_GAME_REVIEWS];
    int num_reviews = 0;

    // Check for command line arguments and open the input file
    if (argc < 2) {
        printf("Usage: %s input_file.csv\n", argv[0]);
        return EXIT_FAILURE;
    }

    f = fopen(argv[1], "r");
    if (!f) {
        printf("Unable to open %s\n", argv[1]);
        return EXIT_FAILURE;
    }

    // Discard the header data in the first line
    while (!feof(f) && fgetc(f) != '\n');

    // Read game reviews
    while (!feof(f) && num_reviews < MAX_GAME_REVIEWS) {
        fetch_game_review(f, &reviews[num_reviews]);
        num_reviews++;
    }

    //sort game reviews by release year
    release_year_check(reviews,num_reviews);

    // Sort game reviews by scores
    sort_game_reviews(reviews, num_reviews);

    // Print the most popular games with the highest scores
    printf("Top Game Reviews:\n");
    for (int i = 0; i < 11; i++) {
        printf("Title: %s, Score: %.2f\n", reviews[i].title, reviews[i].score);
       
    }

    // Close the file
    fclose(f);

    return EXIT_SUCCESS;
}