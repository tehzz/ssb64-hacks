//bass-n64
// This files contains everything necessary for including the custom hitbox
// code. It should make it easy to combine with other hacks in this repository.
//------------------------------------------------------------------------------

align(4)
//--Defs--------------------------------------
include "src/def/hb-defs.bass"
// u8 def.hbFlags

//--.data / static variables------------------
include "src/data/hb-global-vars.asm"
// u32 *def.hbFlags -> data.hitboxFlags

//--.text / Code------------------------------
include "src/hitbox-display.asm"            // for character model hit-/hurt-boxes
include "src/own-projectiles-hb.asm"        // full replacement for on ROM routine (no DMA'd code)
include "src/dpad-handle.asm"               // toggle models in game with d-pad

include "src/items/link-bomb-hb.asm"        // full replacement for on ROM routine (no DMA'd code)
include "src/items/thrown-item-hb.asm"      // full replacement for on ROM routine (no DMA'd code)
include "src/items/beamsword-hb.asm"        // full replacement for on ROM routine (no DMA'd code)
include "src/items/bob-omb-hb.asm"          // full replacement for on ROM routine (no DMA'd code)

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included hitbox.asm\n"
}
