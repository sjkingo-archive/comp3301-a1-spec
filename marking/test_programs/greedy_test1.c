#include <pth.h>
#include <stdio.h>
#include <limits.h>

void *thread_func_greedy(void *arg __attribute__((unused))) {
    char *name = (char *)pth_ctrl(PTH_CTRL_GETNAME, pth_self());
    unsigned int i = 0;
    unsigned int max = INT_MAX;
    while (i < max) {
        i++;
    }
    fprintf(stderr, "exiting\n");
    _exit(0);
    return NULL;
}

int main(void) {
    pth_init();

    pth_attr_t a1 = pth_attr_new();
    pth_attr_set(a1, PTH_ATTR_NAME, "greedy1");
    pth_t t1 = pth_spawn(a1, thread_func_greedy, NULL);
    printf("Spawned \"greedy1\" thread with id %p\n", (void *)t1);
    pth_attr_destroy(a1);

    pth_sleep(5);
    pth_exit(0);
    return 0;
}
