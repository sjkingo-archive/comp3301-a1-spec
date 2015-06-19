#include <stdio.h>
#include <stdlib.h>

#include "common.h"

/* spec - implements the sample thread system in the spec */

#define TEST_LENGTH 10

int main(void) {
    pth_init();

    pth_t t1 = spawn_with_attr("A", 1, 5, busy_thread, NULL);
    printf("Spawned thread A with id %p\n", t1);
    pth_t t2 = spawn_with_attr("B", 2, 10, busy_thread, NULL);
    printf("Spawned thread B with id %p\n", t2);
    pth_t t3 = spawn_with_attr("C", 3, 8, busy_thread, NULL);
    printf("Spawned thread C with id %p\n", t3);

    printf("main thread now sleeping for %d seconds...\n", TEST_LENGTH);
    pth_sleep(TEST_LENGTH);

    pth_kill();

    return 0;
}
