#include <signal.h>
#include <stdio.h>
#include <sys/time.h>
#include <unistd.h>

void timer_tick(int sig) {
    printf("Tick\n");
    sleep(1);
    printf("leaving preemption\n");
}

int main(void) {
    struct sigaction act;
    act.sa_handler = timer_tick;
    if (sigaction(SIGPROF, &act, NULL) < 0) {
        perror("sigaction");
        return 1;
    }
    printf("Trapped SIGPROF\n");

    struct timeval t;
    t.tv_sec = 1;
    t.tv_usec = 0;

    struct itimerval timer;
    timer.it_interval = t;
    timer.it_value = t;

    if (setitimer(ITIMER_PROF, &timer, NULL) < 0) {
        perror("setitimer");
        return 1;
    }
    printf("Set timer\n");
    while(1) {
        printf("loop\n");
    }

    return 0;
}
