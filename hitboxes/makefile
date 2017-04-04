OUTPUT=hbtest.z64
SOURCE=main.asm
BFLAGS=-create
verbose=-d v

all: build

build:
	bass $(BFLAGS) -o $(OUTPUT) $(SOURCE)

verbose:
	bass $(BFLAGS) $(verbose) -o $(OUTPUT) $(SOURCE)

symbols:
	bass $(BFLAGS) -sym $(subst .z64,-sym.txt,$(OUTPUT)) -o $(OUTPUT) $(SOURCE)

vsym:
	bass $(BFLAGS) $(verbose) -sym $(subst .z64,-sym.txt,$(OUTPUT)) -o $(OUTPUT) $(SOURCE)
