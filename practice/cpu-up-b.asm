//bass-n64
//=== CPU Always Up-B [bit] ====================================================
// CPUs will always up-b when off-stage. All credit to bit
// "there's something which checks if a cpu has passed over the stage while
// recovering which can prevent it using its upb recovery move again.
// killing that check allows them to use it again"
//==============================================================================

pushvar pc
origin  0x0AFFBC
base    0x8013557C
scope upb_fix: {
  // remove checking instruction
          nop
}
pullvar pc


// Verbose Print info [-d v on cli]
if {defined v} {
  print "included cpu-up-b.asm\n"
  print "CPU Up-B Fix Added!\n\n"
}
