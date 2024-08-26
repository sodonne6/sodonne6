#include <stdio.h>
#include <stdlib.h>

#define N 9 //9x9 board so N defined as 9

// Function to print the Sudoku board
void printBoard(int board[N][N]) { //take in board parameters - 2D array
    for (int row = 0; row < N; row++) { //print present baord parameters - first case will be incomplete board and then completely solved board 
        for (int col = 0; col < N; col++) { //nested for loop to work through board - start on row zero and iterate through columns until N = 9
            printf("%2d", board[row][col]); //continiously print board position 
        }
        printf("\n");
    }
}

// Function to check if a number can be placed in a specific position
int isSafe(int board[N][N], int row, int col, int num) {
    // Check if the number is already in the row
    for (int x = 0; x < N; x++) {
        if (board[row][x] == num) { //row number stays constant but change column to check each number in that row
            return 0; // if same number is found return zero - specific number can't be placed in that row 
        }
    }
    
    // Check if the number is already in the column
    for (int x = 0; x < N; x++) { //same logic as above but keep column const and change row value
        if (board[x][col] == num) {
            return 0;
        }
    }
    
    // Check if the number is in the 3x3 sub-grid
    int startRow = row - row % 3, startCol = col - col % 3; //percentage sign rounds the figure to the nearest multiple of 3 which indicates the start row and column for each 3x3 sub grid 
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            if (board[i + startRow][j + startCol] == num) { //if the given position equals the chosen num return 0 (the value num is already present in the sub-grid)
                return 0;
            }
        }
    }
    
    return 1;
}

// Function to solve the Sudoku puzzle using backtracking
int solveSudoku(int board[N][N]) {
    int row = -1;
    int col = -1;
    int isEmpty = 1;
    //find empty cells by scanning board 
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            if (board[i][j] == 0) { //if a 0 is found set coordinates to row and col and break from loop - move to line 70
                row = i;
                col = j;
                isEmpty = 0;
                break;
            }
        }
        if (isEmpty == 0) {
            break;
        }
    }
    
    // No empty space left - puzzle solved
    if (isEmpty) {
        return 1;
    }
    
    for (int num = 1; num <= 9; num++) { //for the given coordinates test out numbers between 1 and 9 and test if any of these numbers fit safely into the puzzle 
        if (isSafe(board, row, col, num)) {
            board[row][col] = num; 
            
            if (solveSudoku(board)) {
                return 1;
            }
            
            board[row][col] = 0; // Reset the cell
        }
    }
    
    return 0; // Triggers backtracking
}

// Function to read the Sudoku board from a CSV file
void readBoardFromCSV(char *filename, int board[N][N]) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        printf("Could not open file %s for reading\n", filename);
        exit(1);
    }
    
    for (int row = 0; row < N; row++) {
        for (int col = 0; col < N; col++) {
            if (fscanf(file, "%d,", &board[row][col]) != 1) {
                printf("Invalid input in file\n");
                exit(1);
            }
        }
    }
    
    fclose(file);
}

int main() {
    int board[N][N];
    readBoardFromCSV("sudoku.csv", board);
    
    printf("Original Sudoku board:\n");
    printBoard(board);
    
    if (solveSudoku(board)) {
        printf("\nSolved Sudoku board:\n");
        printBoard(board);
    } else {
        printf("\nNo solution exists\n");
    }
    
    return 0;
}
