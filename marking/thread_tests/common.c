#include <stdlib.h>

#include "common.h"

pth_t spawn_with_attr(char *name, unsigned int deadline_c, 
        unsigned int deadline_t, void *func, void *arg) {
    pth_t t;
    pth_attr_t a = pth_attr_new();
    pth_attr_set(a, PTH_ATTR_NAME, name);
    pth_attr_set(a, PTH_ATTR_DEADLINE_C, deadline_c);
    pth_attr_set(a, PTH_ATTR_DEADLINE_T, deadline_t);
    t = pth_spawn(a, func, arg);
    pth_attr_destroy(a);
    return t;
}

void *busy_thread(void *arg __attribute__((unused))) {
    while (1);
    return NULL;
}

void *nice_thread(void *arg __attribute__((unused))) {
    while (1) pth_yield(NULL);
    return NULL;
}
