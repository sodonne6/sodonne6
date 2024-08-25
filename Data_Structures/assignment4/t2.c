#include "t2.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>

typedef struct {
    int vertex;
    int distance;
} Node;

int compareNodesByDistance(const void* a, const void* b) {
    return ((Node*)a)->distance - ((Node*)b)->distance;
}

int compareNodesByVertex(const void* a, const void* b) {
    return ((Node*)a)->vertex - ((Node*)b)->vertex;
}

Graph* create_graph(int num_nodes) {
    Graph* graph = (Graph*)malloc(sizeof(Graph));
    graph->num_nodes = num_nodes;

    for (int i = 0; i < MAX_VERTICES; ++i) {
        for (int j = 0; j < MAX_VERTICES; ++j) {
            if (i == j) {
                graph->adjacency_matrix[i][j] = 0;  // Diagonal elements set to 0
            } else {
                graph->adjacency_matrix[i][j] = INT_MAX;  // Initialize all other edges with maximum weight
            }
        }
    }

    return graph;
}

void add_edge(Graph* g, int from, int to, int weight) {
    g->adjacency_matrix[from][to] = weight;
    g->adjacency_matrix[to][from] = weight;  // For undirected graph
}

void dijkstra(Graph* g, int origin) {
    int distance[MAX_VERTICES]; //keeps track of min distance
    bool permanent[MAX_VERTICES]; //marks if permanently visited

    for (int i = 0; i < MAX_VERTICES; ++i) { 
        distance[i] = INT_MAX; //starting distance is max
        permanent[i] = false;
    }

    distance[origin] = 0; //distance of origin is 0

    for (int count = 0; count < MAX_VERTICES; ++count) { //iterates for as many vertices are present
        int min_distance = INT_MAX; //min distance initialised to max
        int min_vertex = -1; 

        for (int v = 0; v < MAX_VERTICES; ++v) {
            if (!permanent[v] && distance[v] < min_distance) { //finds min distance
                min_distance = distance[v]; 
                min_vertex = v;
            }
        }

        if (min_vertex == -1) {
            break; // No reachable vertices left
        }

        permanent[min_vertex] = true;

        for (int v = 0; v < MAX_VERTICES; ++v) {
            if (!permanent[v] && g->adjacency_matrix[min_vertex][v] != INT_MAX && distance[min_vertex] != INT_MAX && distance[min_vertex] + g->adjacency_matrix[min_vertex][v] < distance[v]) {
                distance[v] = distance[min_vertex] + g->adjacency_matrix[min_vertex][v]; //v is not permanently visited, there is a direct edge from min_vertex to v, and updating the distance through min_vertex results in a shorter path
            }
        }
    }

    Node nodes[MAX_VERTICES];
    for (int i = 0; i < MAX_VERTICES; ++i) {
        nodes[i].vertex = i;
        nodes[i].distance = distance[i];
    }

    qsort(nodes, MAX_VERTICES, sizeof(Node), compareNodesByDistance); //qsort calls compare distance function

    
    for (int i = 0; i < MAX_VERTICES; ++i) {
        if (permanent[nodes[i].vertex]) {
            printf("%c ", 'A' + nodes[i].vertex);
        }
    }
    printf("\n");

    qsort(nodes, MAX_VERTICES, sizeof(Node), compareNodesByVertex);  // Sort nodes based on alphabetical order

    for (int i = 0; i < MAX_VERTICES; ++i) {
        if (permanent[nodes[i].vertex] && distance[nodes[i].vertex] != INT_MAX) {
            printf("The length of the shortest path between %c and %c is %d\n", 'A' + origin, 'A' + nodes[i].vertex, distance[nodes[i].vertex]);
        }
    }
}

void delete_graph(Graph* g) {
    free(g);
}