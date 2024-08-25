#include "t3.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>

//view dublin is a series of nodes (locations) you must travel to in order to reach final destination 
//egdes between these nodes (roads,bus routes, train tracks)
//each edge has a weight depending on how long it would take you to travel to the location
//use a Dijkstra algorithm
//used 

//Output:
// Loaded 4806 vertices
// Loaded 6179 edges
//StopId    Name    Latitude Longitude

#define MAX_BUFFER 256
#define MAX_VERTICES 100

typedef struct {
    int adjacency_matrix[MAX_VERTICES][MAX_VERTICES];
    int num_nodes;
    int distance[MAX_VERTICES];
    bool permanent[MAX_VERTICES];
    int parent[MAX_VERTICES];
} Graph;

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

void add_edge(Graph* g, int from, int to, int weight) {
    g->adjacency_matrix[from][to] = weight;
    g->adjacency_matrix[to][from] = weight;
}

int load_edges (char *fname){
//loads the edges from the CSV file of name fname
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

int load_vertices (char *fname){
//loads the vertices from the CSV file of name fname
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
    }
}

void shortest_path(int startNode, int endNode){
//Implement Dijkstra here
// prints the shortest path between startNode and endNode, if there is any
}

void free_memory (void){
// frees any memory that was used
//same as past tasks??
}