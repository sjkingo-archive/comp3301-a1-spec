VC=valac
PKGS=posix gio-2.0 Gcc Pth
OBJS=main.vala input.vala test.vala thread.vala
VC_OPTS=--vapidir=.
GCC_OPTS=-lpth -lm -lpcre -ldl -lselinux -static

CHECKSUM=checksum.md5

.PHONY: all
all: a1test

.PHONY: clean
clean:
	rm -f core a1test *.c $(CHECKSUM)

a1test: $(OBJS) 
	$(VC) -o $@ $(VC_OPTS) $(foreach p,$(PKGS),--pkg=$(p)) $(foreach o,$(GCC_OPTS),-X $(o)) $^
	strip $@
	md5sum $@ > $(CHECKSUM)
