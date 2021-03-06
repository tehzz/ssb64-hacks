//bass-n64
//===Boot DMA Hook and Wrapper=============================

//---Hook------------------------------
// Redirect an very early call to fn.ssb.managedDMA to DMA
// custom code along with its original target
// Original Code at ROM 0x001234:
//    jal   fn.ssb.managedDMA (0x8002CA0)
//    addiu a2, r0, 0x0100


pushvar pc

{
  origin 0x001234
  base 0x80000634

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
  // First, perform the original DMA call
            jal   fn.ssb.managedDMA
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
