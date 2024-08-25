#ifndef T1_H_
#define T1_H_

typedef struct Node {
    int vertex; //variable contains node value
    struct Node* next; //pointer to the next node in the list
} Node;

typedef struct Graph{
    int num_nodes; //contains the number of nodes in graph
    Node** adjacency_list; //stores an array of linked lists where each array is a node and the linked list represents the neighbour of said node
} Graph;

Graph* create_graph(int num_nodes); // creates a graph with num_nodes nodes, assuming nodes are stored in alphabetical order (A, B, C..)
void add_edge(Graph *g, int from, int to); // adds a directed edge
void bfs(Graph* g, int origin); //implements breath first search and prints the results
void dfs(Graph* g, int origin); //implements depth first search and prints the results
void delete_graph(Graph* g);

#endif