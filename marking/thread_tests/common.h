#ifndef COMMON_H
#define COMMON_H

#include "pth.h"

pth_t spawn_with_attr(char *name, unsigned int deadline_c, 
        unsigned int deadline_t, void *func, void *arg);

void *busy_thread(void *arg __attribute__((unused)));
void *nice_thread(void *arg __attribute__((unused)));

#endif
