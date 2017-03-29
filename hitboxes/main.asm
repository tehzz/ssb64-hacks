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

//===DMA'd Data and Routines====================================================

// set initial ROM base for free space
origin 0x00F5F500

scope DMA {
  //---Code DMA'd into RAM on game boot----------
  scope boot {
    // set RAM base for DMA'd code
    // and save ROM, RAM, and SIZE for DMA Loader
    base 0x80400000

    constant ROM(origin())
    constant RAM(pc())
    variable SIZE(0)

    align(4)
    //--Defs--------------------------------------
    include "src/hitbox-defs.bass"
    // u8 def.hbFlags

    //--.data / static variables------------------
    include "src/hitbox-global-vars.asm"
    // u32 *def.hbFlags -> data.hitboxFlags

    //--.text / Code------------------------------
    include "src/hitbox-display.asm"        // for character model hit-/hurt-boxes
    include "src/own-projectiles-hb.asm"    // full replacement for on ROM routine
    include "src/dpad-handle.asm"           // toggle models in game with d-pad

    // update SIZE variable
    variable SIZE( origin()-ROM )

    // Verbose Print info [-d v on cli]
    if {defined v} {
      print "Boot DMA Parameters:\n"
      printDMAInfo(ROM, RAM, SIZE)
    }
  }
}

scope loader {
  // shamelessly stolen from bit
  nonLeafStackSize(0)
  origin 0x1234
  base   0x80000634
  {
          jal    bootDMA
  }

  origin 0x33204
  base   0x80032604

  bootDMA: {
          subiu sp, sp, {StackSize}
          sw    ra, 0x0014(sp)
          jal   fn.ssb.managedDMA   // target of hooked jal above
          nop
  // DMA custom code on boot
          li    a0, DMA.boot.ROM
          la    a1, DMA.boot.RAM
          li    a2, DMA.boot.SIZE
          jal   fn.ssb.managedDMA
          nop
  // epilogue
          lw    ra, 0x0014(sp)
          jr    ra
          addiu sp, sp, {StackSize}
  }
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "\nHack Compiled!! \n\n"
}
