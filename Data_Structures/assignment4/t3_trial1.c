#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <limits.h>
#include "t3.h"

#define MAX_BUFFER 256
#define MAX_VERTICES 100

typedef struct {
    int adjacency_matrix[MAX_VERTICES][MAX_VERTICES];
    int num_nodes;
    int distance[MAX_VERTICES];
    bool permanent[MAX_VERTICES];
    int parent[MAX_VERTICES];
} Graph;

void init_graph(Graph* g, int num_nodes) {
    g->num_nodes = num_nodes;

    for (int i = 0; i < MAX_VERTICES; ++i) {
        g->distance[i] = INT_MAX;
        g->permanent[i] = false;
        g->parent[i] = -1; // Initialize parent array
        for (int j = 0; j < MAX_VERTICES; ++j) {
            g->adjacency_matrix[i][j] = INT_MAX;
        }
    }
}

void add_edge(Graph* g, int from, int to, int weight) {
    g->adjacency_matrix[from][to] = weight;
    g->adjacency_matrix[to][from] = weight; // Assuming undirected graph
}

void shortest_path(int startNode, int endNode) {
    g->distance[startNode] = 0;

    for (int count = 0; count < g->num_nodes; ++count) {
        int min_distance = INT_MAX;
        int min_vertex = -1;

        for (int v = 0; v < g->num_nodes; ++v) {
            if (!g->permanent[v] && g->distance[v] < min_distance) {
                min_distance = g->distance[v];
                min_vertex = v;
            }
        }

        if (min_vertex == endNode) {
            break; // Reached the destination node
        }

        g->permanent[min_vertex] = true;

        for (int v = 0; v < g->num_nodes; ++v) {
            if (!g->permanent[v] && g->adjacency_matrix[min_vertex][v] != INT_MAX &&
                g->distance[min_vertex] != INT_MAX &&
                g->distance[min_vertex] + g->adjacency_matrix[min_vertex][v] < g->distance[v]) {
                g->distance[v] = g->distance[min_vertex] + g->adjacency_matrix[min_vertex][v];
                g->parent[v] = min_vertex; // Update parent for path reconstruction
            }
        }
    }

    if (g->permanent[endNode]) {
        printf("Shortest Path Order: ");
        print_path(g, startNode, endNode);
        printf("\n");

        qsort(g->distance, g->num_nodes, sizeof(int), compareDistance);
        printf("The length of the shortest path between %c and %c is %d\n", 'A' + startNode, 'A' + endNode, g->distance[endNode]);
    }
}

void print_path(Graph* g, int startNode, int endNode) {
    if (startNode == endNode) {
        printf("%c ", 'A' + startNode);
        return;
    }

    print_path(g, startNode, g->parent[endNode]);
    printf("%c ", 'A' + endNode);
}

int compareDistance(const void* a, const void* b) {
    return (*(int*)a - *(int*)b);
}

int next_field(FILE *f, char *buf, int max) {
    int i = 0, end = 0, quoted = 0;

    for (;;) {
        buf[i] = fgetc(f);
        if (buf[i] == '"') {
            quoted = !quoted;
            buf[i] = fgetc(f);
        }
        if (buf[i] == ',' && !quoted) {
            break;
        }
        if (feof(f) || buf[i] == '\n') {
            end = 1;
            break;
        }
        if (i < max - 1) {
            ++i;
        }
    }

    buf[i] = 0;
    return end;
}

int load_edges(char* fname, Graph* g) {
    FILE* f = fopen(fname, "r");
    if (!f) {
        printf("Unable to open %s\n", fname);
        return 0;
    }

    char buf[MAX_BUFFER];
    int end;

    while (!feof(f)) {
        end = next_field(f, buf, MAX_BUFFER); // Read vertex1
        int vertex1 = atoi(buf);

        end = next_field(f, buf, MAX_BUFFER); // Read vertex2
        int vertex2 = atoi(buf);

        end = next_field(f, buf, MAX_BUFFER); // Read weight
        int weight = atoi(buf);

        add_edge(g, vertex1, vertex2, weight);
    }

    fclose(f);
    printf("Loaded %d edges\n", g->num_nodes);
    return 1;
}



int load_vertices(char* fname, Graph* g) {
    FILE* f = fopen(fname, "r");
    if (!f) {
        printf("Unable to open %s\n", fname);
        return 0;
    }

    char buf[MAX_BUFFER];
    int end;

    while (!feof(f)) {
        end = next_field(f, buf, MAX_BUFFER); // Read StopId
        int stopId = atoi(buf);

        end = next_field(f, buf, MAX_BUFFER); // Read Name
        printf("%d %s ", stopId, buf);

        end = next_field(f, buf, MAX_BUFFER); // Read Latitude
        float latitude = atof(buf);
        printf("%f ", latitude);

        end = next_field(f, buf, MAX_BUFFER); // Read Longitude
        float longitude = atof(buf);
        printf("%f\n", longitude);

        // Do something with stopId, latitude, and longitude
    }

    fclose(f);
    printf("Loaded %d vertices\n", g->num_nodes);
    return 1;
}

void free_memory(Graph* g) {
    // Any cleanup or memory freeing needed
    free(g);
}