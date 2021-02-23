all: x86http

ASM=nasm
LD=ld.lld

LIBS=-dynamic-linker /lib/ld-musl-x86_64.so.1 -lc

NASMFLAGS=
LDFLAGS=-s --library-path=/usr/lib

DEBUG_NASMFLAGS=-g
DEBUG_LDFLAGS=-g --library-path=/usr/lib

ASM_INPUT=x86http.asm
ASM_OBJ=x86http.asm.o
OUT=x86http

INSTALLDIR=$(HOME)/.local/bin

RM=/bin/rm
CP=/bin/cp

.PHONY: x86http
x86http:
	$(ASM) -f elf64 $(ASM_INPUT) -o $(ASM_OBJ) $(NASMFLAGS)
	$(LD) $(LIBS) $(ASM_OBJ) -o $(OUT) $(LDFLAGS)

debug:
	$(ASM) -f elf64 $(ASM_INPUT) -o $(ASM_OBJ) $(DEBUG_NASMFLAGS)
	$(LD) $(LIBS) $(ASM_OBJ) -o $(OUT) $(DEBUG_LDFLAGS)

install:
	test -d $(INSTALLDIR) || mkdir -p $(INSTALLDIR)
	install -pm 755 $(OUT) $(INSTALLDIR)

uninstall:
	$(RM) $(INSTALLDIR)/$(OUT)

clean:
	if [ -e "$(OUT)" ] || [ -e "$(ASM_OBJ)" ]; then $(RM) $(OUT) $(ASM_OBJ); fi
