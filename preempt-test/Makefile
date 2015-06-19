CC=gcc
CFLAGS=-Wall -Wextra -g -std=gnu99

.PHONY: all
all: preempt

.PHONY: clean
clean:
	rm -f preempt *.o

preempt: preempt.o
	$(CC) -o $@ $<
