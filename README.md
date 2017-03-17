# Index of Various SSB64 Hacks

This is my collection of smash 64 hacks and assorted assembly/bass files need to run them. There are two main types: "library" and "build." The "library" files are common to a lot of hacks, and can easily be applied to new hacks. The "build" files are individual hacks that you can apply to games.

## Library
* ### /LIB/
N64 register definitions for bass + an evergrowing list of ssb64 routine constants. Various macros I use too.
* ### /dma-loader/
Constant in-RAM dma loading code that allows for custom DMAing of ROM to RAM data whenever needed.
* ### /bootstrap/
Copy-and-paste start for a new hack. Includes above

## Actual, Useful Code
* ### /hitboxes/
A "refactoring" of the rouintes that draw hurtboxes, hitboxes, and regular models to allow for those three to be seen in any combination
