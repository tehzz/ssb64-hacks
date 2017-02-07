//bass-n64
//===============================================
//--- DMA Loader Code
//===============================================
// This routine DMAs code from ROM
//  -> Hacks need to expose a RAM, ROM, and SIZE bass constant
//------------------------------------------------

origin 0x42F10
base 0x800A41C0
// alt origin 0x3BB20; alt base 0x8003AF20

//---.data and defs--------------------
align(4)
scope data {
  include "data/dma-hacks.bass"
}
//---End .data-------------------------

//---.text-----------------------------
align(4)
scope text {
  // Loader routines:
  //  void hackLoader( a0: hackEnum )
  //  void heapStealer( a0: u32 RAMaddress )
  include "text/hack-loader.asm"

  // Include whichever screen you want to DMA on.
  // Remember to set up struct in "data/dma-hacks.bass"
  // include "text/boot.asm"
  // include "text/css.asm", etc.


}
//---End .text-------------------------


// Check Total Size
errorOnAddr(origin(), 0x4310C, "Hack Loader Size", 0x10)

// Verbose Print info [-d v on cli]
if {defined v} {
  print "\nSuccessfully compiled dma-loader.asm!\n"
  print "Compiled Size: 0x"; printHex(origin()-0x42F10)
  print " bytes\n"
  print "0x"; printHex(0x4310C-origin()); print " remaining free bytes\n\n"
}
