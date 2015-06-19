#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/time.h>
#include <signal.h>
#include <unistd.h>

static long pid = -1;
static long timeout = 1;

void timer_expired(int sig __attribute__((unused))) {
    if (kill((pid_t)pid, SIGKILL) < 0) {
        if (errno == ESRCH) {
            /* do nothing, process didn't exist */
            exit(0);
        } else {
            perror("kill");
            exit(4);
        }
    } else {
        printf("Killed pid %ld after timeout\n", pid);
        exit(10);
    }
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s pid timeout\n", argv[0]);
        fprintf(stderr, "   if pid does not exit within timeout seconds,\n"
                        "   force it to exit by sending it SIGKILL.\n");
        exit(1);
    }

    pid = strtol(argv[1], NULL, 10);
    timeout = strtol(argv[2], NULL, 10);
    if (pid == -1 || timeout == -1) {
        fprintf(stderr, "Invalid arguments\n");
        exit(2);
    }

    struct sigaction sig;
    sig.sa_handler = timer_expired;
    if (sigaction(SIGALRM, &sig, NULL) < 0) {
        perror("sigaction");
        exit(3);
    }

    struct timeval v;
    v.tv_sec = timeout;
    v.tv_usec = 0;

    struct itimerval it;
    it.it_interval = v;
    it.it_value = v;

    if (setitimer(ITIMER_REAL, &it, NULL) < 0) {
        perror("setitimer");
        exit(3);
    }

    while (1) {
        char buf[1024];
        read(STDIN_FILENO, buf, sizeof(buf));
    }
    return 5;
}
