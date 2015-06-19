#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "common.h"

/* order - test thread ordering to make sure the library picks threads correctly */

#define TEST_LENGTH 10

static void *busy_thread_log(void *arg __attribute__((unused))) {
    char *name = malloc(1024);
    pth_attr_t a = pth_attr_of(pth_self());
    pth_attr_get(a, PTH_ATTR_NAME, &name);
    while (1) {
        printf("%s\n", name);   
        fflush(stdout);
    }
    free(name);
    return NULL;
}

int main(void) { 
    unsigned int num_threads = 3;

    int pipefd[2];
    if (pipe(pipefd) < 0) {
        perror("pipe");
        return 1;
    }

    int pid = fork();
    if (pid == 0) {
        /* redirect the pipe to stdin */
        close(STDIN_FILENO);
        dup(pipefd[0]);
        close(pipefd[1]);

        execlp("uniq", "uniq", NULL);
        _exit(10);
    } else {
        /* redirect stdout to the pipe */
        close(STDOUT_FILENO);
        dup(pipefd[1]);
        close(pipefd[0]);

        pth_init();

        for (unsigned int i = 1; i <= num_threads; i++) {
            char *name = malloc(1024);
            sprintf(name, "thread%d", i);
            unsigned int c, t;
            switch (i) {
                case 1:
                    c = 1;
                    t = 5;
                    break;
                case 2:
                    c = 2;
                    t = 10;
                    break;
                case 3:
                    c = 3;
                    t = 8;
                    break;
            }
            spawn_with_attr(name, c, t, busy_thread_log, NULL);
            free(name);
        }

        pth_sleep(TEST_LENGTH);

        pth_kill();

        return 0;
    }
}
