#include "bstdb.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Write your submission in this file
//
// A main function and some profiling tools have already been set up to test
// your code in the task2.c file. All you need to do is fill out this file
// with an appropriate Binary Search Tree implementation.
//
// The input data will be books. A book is comprised of a title and a word
// count. You should store both these values in the tree along with a unique
// integer ID which you will generate.
//
// We are aiming for speed here. A BST based database should be orders of
// magnitude faster than a linked list implementation if the BST is written
// correctly.
//
// We have provided an example implementation of what a linked list based
// solution to this problem might look like in the db/listdb.c file. If you
// are struggling to understand the problem or what one of the functions
// below ought to do, consider looking at that file to see if it helps your
// understanding.
//
// There are 6 functions you need to look at. Each is provided with a comment
// which explains how it should behave. The functions are:
//
//  + bstdb_init
//  + bstdb_add
//  + bstdb_get_word_count
//  + bstdb_get_name
//  + bstdb_stat
//  + bstdb_quit
//
// Do not rename these functions or change their arguments/return types.
// Otherwise the profiler will not be able to find them. If you think you
// need more functionality than what is provided by these 6 functions, you
// may write additional functions in this file.

//To sort the necessary data a red and black BST was used//A red and black tree is self balancing therefore making it a viable option when wanting to create a program that sorts data into a balanced tree, making run times quicker
//nodes are either red or black 
//root is always black
//Every leaf node is black
//if node is red then both children are black

// Enum to represent the color of a node
typedef enum { RED, BLACK } Color;

// Define the structure for the Red-Black Tree node
typedef struct Node { //struct for all data needed including node color
    int doc_id; //unique if for each book
    char *name;
    int word_count;
    Color color;
    struct Node *left;
    struct Node *right;
    struct Node *parent;
} Node;

// Define a global root for the Red-Black Tree
Node *root = NULL;

// Helper function to create a new node
Node *createNode(int doc_id, char *name, int word_count) {
    Node *newNode = (Node *)malloc(sizeof(Node));
    if (newNode) {
        newNode->doc_id = doc_id;
        newNode->name = strdup(name);
        newNode->word_count = word_count;
        newNode->color = RED; //new nodes will always red
        newNode->left = newNode->right = newNode->parent = NULL;
    }
    return newNode;
}

// Helper function to perform left rotation
void leftRotate(Node **root, Node *x) { //pointer to root in the tree//*x is the node the rotation occurs around//after the rotation y becomes the new parent of x and the left child of y becomes the right child of x 
    Node *y = x->right; //y is the right child of node x
    x->right = y->left; //left subtree of y becomes te right subtree of x
    
    if (y->left != NULL) { //if y has a child to the left, update its parent pointer to point to x
        y->left->parent = x;
    }

    y->parent = x->parent; //update the parent of y to be the parent of x

    if (x->parent == NULL) { //if x is the root update the root of the tree to be y
        *root = y;
    } else if (x == x->parent->left) { //if x is the left child of its parent update the left child of x's parent to be y
        x->parent->left = y;
    } else { //if x is the right child of its parent update the right child of x's parent to be y
        x->parent->right = y;
    }

    y->left = x; //make x teh left child of y
    x->parent = y; //update the parent pointer of x to be y
}

// Helper function to perform right rotation
void rightRotate(Node **root, Node *y) { //pointer to root of tree//y* is the node the right rotoation will rotate around//After the rotation x should become the new parent of y and the right child of x becomes the left child of y
    Node *x = y->left; //x is the left child of y
    y->left = x->right; //the right subtree of x is now the left subtree of y
    
    if (x->right != NULL) { //if x is the right child update its parent pointer to point to y
        x->right->parent = y; 
    }

    x->parent = y->parent; //update the parent of x to be the parent of y

    if (y->parent == NULL) { //if y is the root update the root of the tree to be x
        *root = x;
    } else if (y == y->parent->left) { //if y is the left child of its parent update the left child of y's parent to be x
        y->parent->left = x;
    } else { //if y is the right child of its parent update the right child of y's parent to be x
        y->parent->right = x;
    }

    x->right = y; //make y the right child of x
    y->parent = x; //update the parent pointer of y to be x
}

// Helper function to maintain Red-Black Tree properties after insertion
void insertFix(Node **root, Node *z) { //**root=a pointer to the root//*z=newly inserted node which is initially red//after a node is inserted this function is to be called to ensure that red and black tree parameters are maintained//ensure no consecutive red nodes are present in the tree 
    while (z->parent != NULL && z->parent->color == RED) { //while loop is used to iterate through the tree and find any violations//first condition ensures z has a parent//second condition checks whether z's parent is red 
        if (z->parent == z->parent->parent->left) { 
			//Case 1: Uncle is red // if the uncle (sibling of parent) of z us red, this is a violation//colors of parent, uncle, and grandparent are adjusted and the pointer z moves up 2 levels
            Node *y = z->parent->parent->right;
            if (y != NULL && y->color == RED) {
                z->parent->color = BLACK;
                y->color = BLACK;
                z->parent->parent->color = RED;
                z = z->parent->parent;
            } else { // Case 2:Uncle is black or NULL // if uncle is black or NULL additional rotations occur to restore balance (to the force)
			//depending on whether the z node is a left or right child the appropriate function is called//loop continues until no more violations are present
                if (z == z->parent->right) {
                    z = z->parent;
                    leftRotate(root, z);
                } // Case 3: Uncle is black or NULL // continuation of case 2, adjusts color of parents and grandparents again to ensure rules of a red and black tree are followed
                z->parent->color = BLACK;
                z->parent->parent->color = RED;
                rightRotate(root, z->parent->parent);
            }
        } else { // Case 1: Uncle is red
            Node *y = z->parent->parent->left;
            if (y != NULL && y->color == RED) {
                z->parent->color = BLACK;
                y->color = BLACK;
                z->parent->parent->color = RED;
                z = z->parent->parent;
            } else { //Case 2: Uncle is black or NULL
                if (z == z->parent->left) {
                    z = z->parent;
                    rightRotate(root, z);
                } // Case 3: Uncle is black or NULL
                z->parent->color = BLACK;
                z->parent->parent->color = RED;
                leftRotate(root, z->parent->parent);
            }
        }
    }
    (*root)->color = BLACK; //after all violations are fixed the root is restored to black(This is one of the rule of a red and black tree)
}

int bstdb_init(void) {
	// This function will run once (and only once) when the database first
	// starts. Use it to allocate any memory you want to use or initialize 
	// some globals if you need to. Function should return 1 if initialization
	// was successful and 0 if something went wrong.
    root = NULL;
    return 1;
}

int bstdb_add(char *name, int word_count, char *author) {
	// This function should create a new node in the binary search tree, 
	// populate it with the name, word_count and author of the arguments and store
	// the result in the tree.
	//
	// This function should also generate and return an identifier that is
	// unique to this document. A user can find the stored data by passing
	// this ID to one of the two search functions below.
	//
	// How you generate this ID is up to you, but it must be an integer. Note
	// that this ID should also form the keys of the nodes in your BST, so
	// try to generate them in a way that will result in a balanced tree.
	//
	// If something goes wrong and the data cannot be stored, this function
	// should return -1. Otherwise it should return the ID of the new node
    static int doc_id_counter = 0; //used to genrate a unique id for each book, incremented everytime a new document is added 

    Node *z = createNode(doc_id_counter, name, word_count); //creates a new node "z" with the provided ID, title, and word count
    if (!z) {
        return -1; // Memory allocation error
    }

    // Perform Red-Black Tree insertion
    Node *y = NULL;
    Node *x = root;

    while (x != NULL) { //finds the correct position in the tree for the new node according to its ID code by traversing the tree 
        y = x; // y is assigned the current node x before moving down the tree 
        if (z->doc_id < x->doc_id) { //if the ID of the new node is less than the ID of the current node the traverse continues left
            x = x->left;
        } else { //if the ID of the new node is greater than the ID of the current node the traversal continues right
            x = x->right;
        }
    }

    z->parent = y; //after the while loop is finished iterating z is set to the last node (y) that is encountered during the traversal
    if (y == NULL) { //this means the tree is empty and the new node becomes the root
        root = z; 
    } else if (z->doc_id < y->doc_id) {//if the new node's ID is less than the ID of y the new node becomes the left child of y
        y->left = z;
    } else { // if the new nodes's ID is greater than the ID of y the new nodes becomes the right child of y
        y->right = z;
    }

    insertFix(&root, z); //ensures new insertion abides by red and black trees

    doc_id_counter++; //esnures next insertion has a unique ID code
    return z->doc_id; //
}

int bstdb_get_word_count(int doc_id) {
	// This is a search function. It should traverse the binary search tree
	// and return the word_count of the node with the corresponding doc_id.
	//
	// If the required node is not found, this function should return -1
    Node *current = root; //starts search from root of tree 
    while (current != NULL) { //While loop will iterate until it finds the desired node or it reaches a leaf node (leaf nodes are NULL)
        if (doc_id == current->doc_id) { //if the matching doc id is found the word count associated with that node is returned
            return current->word_count;
        } else if (doc_id < current->doc_id) { //if the desired ID is less than current ID continue the traversal to the left
            current = current->left;
        } else { //if the desired ID is greater than the current ID continue the travsersal to the right
            current = current->right;
        }
    }
    return -1; // Not found
}

char *bstdb_get_name(int doc_id) {
	// This is a search function. It should traverse the binary search tree
	// and return the name of the node with the corresponding doc_id.
	//
	// If the required node is not found, this function should return NULL or 0
	// Search for a book by doc_id in the BST
  // Search for a book by doc_id in the BST
    Node *current = root;
    while (current != NULL) {
        if (doc_id == current->doc_id) {
            return current->name;
        } else if (doc_id < current->doc_id) {
            current = current->left;
        } else {
            current = current->right;
        }
    }
    return NULL; // Not found
}

void bstdb_stat(void) {
   // Use this function to show off! It will be called once after the 
	// profiler ends. The profiler checks for execution time and simple errors,
	// but you should use this function to demonstrate your own innovation.
	//
	// Suggestions for things you might want to demonstrate are given below,
	// but in general what you choose to show here is up to you. This function
	// counts for marks so make sure it does something interesting or useful.
	//
	//  + Check if your tree is balanced and print the result
	//
	//  + Does the number of nodes in the tree match the number you expect
	//    based on the number of insertions you performed?
	//
	//  + How many nodes on average did you need to traverse in order to find
	//    a search result? 
	//
	//  + Can you prove that there are no accidental duplicate document IDs
	//    in the tree?
}

void freeTree(Node *node) {
    if (node != NULL) {
        freeTree(node->left);
        freeTree(node->right);
        free(node->name);
        free(node);
    }
}

void bstdb_quit(void) {
	// This function will run once (and only once) when the program ends. Use
	// it to free any memory you allocated in the course of operating the
	// database.
    freeTree(root);
    root = NULL;
}