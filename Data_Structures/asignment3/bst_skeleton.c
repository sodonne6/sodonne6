#include <stdio.h>
#include <stdlib.h>
#include "bst.h"

//int temp,item;


//int arrayCreate(int arr[],int i){
    //while(i != "\0"){
       // scanf("%d",arr[i]);
       // i++;
   // }
//}


Tree_Node* create_node(char data){ // creates a new node with the character data provided 
    Tree_Node* new_node=(Tree_Node*)malloc(sizeof(Tree_Node));
    new_node->data=data;
    new_node->left=NULL; //initialise to null
    new_node->right=NULL; //initialise to null
    return new_node;
}

void tree_insert(Tree_Node** root, char data){ //inserts a new node into the bst//traversing the tree to find the correct place to put the new node
    //TODO
    //has to either go left or right until finding a null spot
    if (*root == NULL) { //if the root is returned as null the new node necomes the root because teh tree is empty
       *root = create_node(data);
   } else {
        if (data < (*root)->data) { //if the new node is less than the root the node traverses the left side of the root
           tree_insert(&((*root)->left), data);
        } else { //if the new node is less than the root the node traverses the right side of the root
           tree_insert(&((*root)->right), data);
        }
    }
}


Tree_Node* create_bst (char data[]){ //an array of characters is inputted and this function take them in and sorts them one at a time
    // TODO
    //sorts a randomly inputed array (remember the tutorial (take medians maybe??))
    
    int i = 0; //initialise node counter to 0
     Tree_Node* root = NULL; //initialise root to null because the tree is empty to begin
    while (data[i] != '\0') { //"\0" is the last element in the array so while loop will break once all characters are read in 
        tree_insert(&root, data[i]); //call tree insert function//this will insert the character that was just read in into the correct position in the tree 
        i++; //node counter increase by 1
    }
    return root;
}

Tree_Node* tree_search(Tree_Node* root, char data){
    //TODO
    //if smaller than root go left if bigger go right 
    //repeat this for subtrees until node matches searched value
    //if (root == NULL){
        //return NULL;
   // }
   // if (data<node->data){
        //move left if smaller than node
   // }
    //else if (data<node->data){
        //move right if bigger than node

   // }
    //return NULL;
    if (root == NULL) { //if no root is found reurn null because the tree is empty
        return NULL;
    }
    if (data < root->data) { //if the searched character is less than the root the node traverses the left side of the root
        return tree_search(root->left, data);
    } else if (data > root->data) { //if the searched character is less than the root the node traverses the left side of the root
        return tree_search(root->right, data);
    }
    return root;
}

void tree_print_sorted(Tree_Node* root){ //prints the charcaters in the bst from smallest to biggest
    //TODO
    //print sorted tree from smallest to largest(Doesn't have to look like a tree just in order)
    if (root == NULL) {
        return;
    }
    tree_print_sorted(root->left);
    printf("%c", root->data);
    tree_print_sorted(root->right);
    
   
}
void tree_delete(Tree_Node* root){ //Deletes the whole tree without any memory leaks/Deletion starts at the root and works down tree
    //TODO
    //Three cases 
    //1. Leaf node deletion
    //2. One child deletion
    //3. Two child deletion
    //Check typed notes when confused 
    if (root == NULL) {
        return;
    }
    tree_delete(root->left);
    tree_delete(root->right);
    free(root);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
