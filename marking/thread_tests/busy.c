#include <stdio.h>
#include <stdlib.h>

#include "common.h"

/* busy - spawn argv[1] busy threads and wait for TEST_LENGTH and exit cleanly */

#define TEST_LENGTH 5

int main(int argc, char **argv) {
    long num_threads;

    if (argc != 2) {
        fprintf(stderr, "Usage: %s num_threads\n", argv[0]);
        exit(1);
    }

    num_threads = strtol(argv[1], NULL, 10);
    printf("Using %ld threads\n", num_threads);

    pth_init();

    for (long i = 1; i <= num_threads; i++) {
        char *name = malloc(1024);
        sprintf(name, "busy%ld", i);
        pth_t t = spawn_with_attr(name, 1, 5, busy_thread, NULL);
        printf("Spawned thread #%ld with id %p\n", i, t);
        free(name);
    }

    printf("main thread now sleeping for %d seconds...\n", TEST_LENGTH);
    pth_sleep(TEST_LENGTH);

    pth_kill();

    return 0;
}
