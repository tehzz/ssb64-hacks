//bass-n64
//=== Naive VS Mode Final Destination Fix ======================================
// This is Guy Perfect's simple vs mode fd fix. This skips a JAL to an unloaded
// (for vs mode) routine.
//==============================================================================

pushvar pc
origin  0x80484
base    0x80104C84

// original: jal 80192764
scope fd_fix {
          nop
}

if {defined v} {        // Verbose Print info [-d v on cli]
  print "included naive-fd-fix.asm \n"
}
