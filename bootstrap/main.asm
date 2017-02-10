//bass-n64
arch n64.cpu
endian msb

//---Rouintes, macros, defines, etc----
include "../LIB/lib.bass"

// insert SSB U big-endian rom
origin 0x0
insert "../ROM/Super Smash Bros. (U) [!].z64"

// Unlock Everything  [bit]
origin 0x042B3B
base 0x8000A3DE8
dl 0x7F0C90

//===DMA'd Routines========================================
//- These routines need to be moved into active RAM.
// Structure looks like:
// DMA {
//    ${screen} {
//        ROM
//        RAM
//        SIZE
//    }
// }
//-----------------------------------------------


// set initial ROM base for free space
origin 0x00F5F500

scope DMA {
  //---Code DMA'd into RAM on game boot----------
  scope boot {
    // set RAM base for DMA'd code
    // and save ROM, RAM, and SIZE for DMA Loader
    base 0x80392A00   // <-- change away from frame buffers/steal from heap

    constant ROM(origin())
    constant RAM(pc())
    variable SIZE(0)

    //---Code to be DMA'd:
    // Note: The ASM files include the DMA'd routine,
    // and the hook to that routine from the natural code flow
    align(4)
    //---End Code to Be DMA'd

    // update SIZE variable
    variable SIZE(origin()-ROM)
    // --- Print out info on DMA stuff
    // Verbose Print info [-d v on cli]
    if {defined v} {
      print "Boot DMA Parameters:\n"
      printDMAInfo(ROM, RAM, SIZE)
    }
  }
}

scope loader {
  // insert the hack file loader in constantly loaded memory space
  // -> right now: inserted over old debug strings
  // Verbose Print info [-d v on cli]
  if {defined v} {
    print "\nGenerating DMA hack loader code: \n\n"
  }

  include "dma-loader/main.asm"
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "\nHack Compiled!! \n\n"
}
