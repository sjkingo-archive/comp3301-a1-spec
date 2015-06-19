#include <stdio.h>
#include <stdlib.h>

#include "common.h"

/* combo - spawn 1 busy thread and 1 nice thread and wait for TEST_LENGTH and exit cleanly */

#define TEST_LENGTH 10

int main(void) {
    pth_init();

    pth_t t1 = spawn_with_attr("busy", 1, 2, busy_thread, NULL);
    printf("Spawned busy thread with id %p\n", t1);
    pth_t t2 = spawn_with_attr("nice", 1, 2, nice_thread, NULL);
    printf("Spawned nice thread with id %p\n", t2);

    printf("main thread now sleeping for %d seconds...\n", TEST_LENGTH);
    pth_sleep(TEST_LENGTH);

    pth_kill();

    return 0;
}
