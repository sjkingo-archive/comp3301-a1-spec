PTH_CONFIG=../work/.lib_under_test/pth-config

CC=gcc
CFLAGS=-Wall -Wextra -std=gnu99 $(shell $(PTH_CONFIG) --cflags)
LDFLAGS=$(shell $(PTH_CONFIG) --ldflags) -Wl,-rpath,$(shell $(PTH_CONFIG) --libdir)
LIBS=$(shell $(PTH_CONFIG) --libs)

TESTS=greedy_test1 greedy_test2 edf
STATIC_TESTS=greedy_test1_static greedy_test2_static edf_static

.PHONY: all
all: $(TESTS)

.PHONY: static
static: $(STATIC_TESTS)

.PHONY: clean
clean:
	rm -f core $(TESTS) $(STATIC_TESTS) *.o sched.log

greedy_test1: greedy_test1.o
	$(CC) -o $@ $< $(LDFLAGS) $(LIBS)

greedy_test2: greedy_test2.o
	$(CC) -o $@ $< $(LDFLAGS) $(LIBS)

edf: edf.o
	$(CC) -o $@ $< $(LDFLAGS) $(LIBS)

greedy_test1_static: greedy_test1.o
	$(CC) -o $@ $< $(LDFLAGS) $(LIBS) -static

greedy_test2_static: greedy_test2.o
	$(CC) -o $@ $< $(LDFLAGS) $(LIBS) -static

edf_static: edf.o
	$(CC) -o $@ $< $(LDFLAGS) $(LIBS) -static
