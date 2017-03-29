OUTPUT=hbtest.z64
SOURCE=main.asm
BFLAGS=-create

all: build

build:
	bass $(BFLAGS) -o $(OUTPUT) $(SOURCE)

verbose:
	bass $(BFLAGS) -d v -o $(OUTPUT) $(SOURCE)

sym:
	bass $(BFLAGS) -sym $(subst .z64,-sym.txt,$(OUTPUT)) -o $(OUTPUT) $(SOURCE)
