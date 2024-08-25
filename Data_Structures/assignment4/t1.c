#include "t1.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
//put spaces each side of print funt before to get rid of error//fix when get home

Node* create_node(int vertex) {
    Node* newNode = (Node*)malloc(sizeof(Node)); //allocate memory to new node
    newNode->vertex = vertex; //initialise new node's vertex and set the next pointer to 0 as it doesn't have a neighbour yet
    newNode->next = NULL;
    return newNode;
}

Graph* create_graph(int num_nodes) {
    Graph* graph = (Graph*)malloc(sizeof(Graph)); //allocate memory for new graph
    graph->num_nodes = num_nodes; //initialise how many nodes their are 
    graph->adjacency_list = (Node**)malloc(num_nodes * sizeof(Node*)); //initialise memory to correspond with number of nodes

    for (int i = 0; i < num_nodes; ++i) {
        graph->adjacency_list[i] = NULL;
    }

    return graph;
}

void add_edge(Graph* g, int from, int to) { // Function to add a directed edge from 'from' to 'to' in the graph 
    Node* newNode = create_node(to);
    newNode->next = g->adjacency_list[from];
    g->adjacency_list[from] = newNode;
}

void bfs_helper(Graph* g, int origin, bool* visited) {  //helper func//takes grph g and starts to origin node and an array of visited nodes
    int* queue = (int*)malloc(g->num_nodes * sizeof(int)); //allocates memory for qeueue which is dtermined by the number of nodes
    int front = 0, rear = 0;

    visited[origin] = true; //marks origin as visited

    queue[rear++] = origin; //queues origin node and increments rear index

    while (front != rear) { //loop iterates until queue is done
        int current = queue[front++]; //releases front element from queue and stores in current variable
        printf(" %c ", 'A' + current);  // outputs current node 

        Node* temp = g->adjacency_list[current]; //retrieves the adjacency list of the current node.
        while (temp != NULL) { //loop iterates finding neighbours of current node
            int neighbor = temp->vertex; //gets vertex value
            if (!visited[neighbor]) { //makes sure note hasn't been visited before
                visited[neighbor] = true; //marks neighbour as visited
                queue[rear++] = neighbor; //places neighbour in queue at rear
            }
            temp = temp->next; //moves to next neighbour
        }
    }

    free(queue);
}

void bfs(Graph* g, int origin) {
    bool* visited = (bool*)malloc(g->num_nodes * sizeof(bool));
    for (int i = 0; i < g->num_nodes; ++i) {
        visited[i] = false; //set all nodes to false indicating no nodes has been bisited yet, so when function is called it will work correctly
    }

    printf("BFS ");
    bfs_helper(g, origin, visited);
    printf("\n");

    free(visited);
}

void dfs_helper(Graph* g, int vertex, bool* visited) {
    
    visited[vertex] = true; //current node set as visited
    printf(" %c ", 'A' + vertex);  //print current node

    Node* temp = g->adjacency_list[vertex];
    while (temp != NULL) { //iterate through adjacency list
        int neighbor = temp->vertex; //retrive vertex number of neighour
        if (!visited[neighbor]) {  //if the neighbour hasn't been visited call dfs_helper
            dfs_helper(g, neighbor, visited);
        }
        temp = temp->next; //move to next neighbour
    }
}

void dfs(Graph* g, int origin) {
    // Implementation of Depth First Search
    bool* visited = (bool*)malloc(g->num_nodes * sizeof(bool));
    for (int i = 0; i < g->num_nodes; ++i) {
        visited[i] = false;
    }

    printf("DFS:");
    dfs_helper(g, origin, visited);
    printf("\n");

    free(visited);
   
}





void delete_graph(Graph* g) {
    for (int i = 0; i < g->num_nodes; ++i) {
        Node* current = g->adjacency_list[i];
        while (current != NULL) {
            Node* temp = current;
            current = current->next;
            free(temp);
        }
    }

    free(g->adjacency_list);
    free(g);
}

