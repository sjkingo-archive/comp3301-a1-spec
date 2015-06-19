PTH_CONFIG=../../pth-2.0.7-marker/pth-config

CC=gcc
CFLAGS=-Wall -Wextra -g -std=gnu99 $(shell $(PTH_CONFIG) --cflags)
LDFLAGS=$(shell $(PTH_CONFIG) --ldflags) -Wl,-rpath,$(shell $(PTH_CONFIG) --libdir)
LIBS=$(shell $(PTH_CONFIG) --libs)

PROGS=timeout busy combo spec order

.PHONY: all
all: $(PROGS)

timeout: timeout.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

busy: busy.o common.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

combo: combo.o common.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

spec: spec.o common.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

order: order.o common.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

.PHONY: clean
clean:
	rm -f core *.o $(PROGS) sched.log
