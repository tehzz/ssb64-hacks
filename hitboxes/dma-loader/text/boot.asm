//bass-n64
//===Boot DMA Hook and Wrapper=============================

//---Hook------------------------------
// Redirect an very early call to fn.ssb.managedDMA to DMA
// custom code along with its original target
// Original Code at ROM 0x001234:
//    jal   0x800A1980
//    or    a0, r0, r0


pushvar pc

{
  origin 0x13B0
  base   0x800007B0
            jal boot_load_wrapper
}

pullvar pc

//---End Hook--------------------------

//---Wrapper Routine-------------------
// This just wraps the call to hackLoader to call it with proper CSS
// enum and inits the global Alt-Char-State addresses

scope boot_load_wrapper: {
  nonLeafStackSize(0)
  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  // First, perform the original call this replaced
            jal   0x800A1980
            nop
  // Then, call custom code for DMA
            jal   hackLoader
            ori   a0, r0, data.hacks.enum.boot

  // epilogue
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included boot.asm for DMA loader\n"
}
