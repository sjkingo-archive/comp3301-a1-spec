#include <pth.h>
#include <stdio.h>

void *thread_func_greedy(void *arg __attribute__((unused))) {
    char *name = (char *)pth_ctrl(PTH_CTRL_GETNAME, pth_self());
    while (1) {
        int a = 1+0;
    }
    return NULL;
}

int main(void) {
    pth_init();

    /* t=0      T1      0/5
     * t=100    T2      0/10
     * t=200    T3      1/10
     * t=300    T3      0/10
     * t=400    nop
     * t=500    T1      0/5
     * t=600    nop
     * t=700    nop
     * t=800    nop
     * t=900    nop
     * etc
     */

    pth_attr_t a1 = pth_attr_new();
    pth_attr_set(a1, PTH_ATTR_NAME, "T1");
    pth_attr_set(a1, PTH_ATTR_DEADLINE_C, 1);
    pth_attr_set(a1, PTH_ATTR_DEADLINE_T, 5);
    pth_t t1 = pth_spawn(a1, thread_func_greedy, NULL);
    printf("Spawned \"T1\", 1/5 thread with id %p\n", (void *)t1);
    pth_attr_destroy(a1);

    pth_attr_t a2 = pth_attr_new();
    pth_attr_set(a2, PTH_ATTR_NAME, "T2");
    pth_attr_set(a2, PTH_ATTR_DEADLINE_C, 1);
    pth_attr_set(a2, PTH_ATTR_DEADLINE_T, 10);
    pth_t t2 = pth_spawn(a2, thread_func_greedy, NULL);
    printf("Spawned \"T2\", 2/5 thread with id %p\n", (void *)t2);
    pth_attr_destroy(a2);

    pth_attr_t a3 = pth_attr_new();
    pth_attr_set(a3, PTH_ATTR_NAME, "T3");
    pth_attr_set(a3, PTH_ATTR_DEADLINE_C, 2);
    pth_attr_set(a3, PTH_ATTR_DEADLINE_T, 10);
    pth_t t3 = pth_spawn(a3, thread_func_greedy, NULL);
    printf("Spawned \"T3\", 2/10 thread with id %p\n", (void *)t3);
    pth_attr_destroy(a3);

    pth_sleep(10);
    pth_exit(0);
    return 0;
}
