//bass-n64
//=== CPU Z-Cancel [bit] =======================================================
// Fine-grained control over CPU Z-Canceling
// Shamelessly stolen from bit:
//   https://github.com/abitalive/SuperSmashBros/blob/master/Patches/cpu_tech_cancel.asm
//==============================================================================

//--- Control Constants --------------------------------------------------------
scope Z_CANCEL_CHANCE {
  constant Total(100)
  constant Success(99)
}
//--- End Control Constants ----------------------------------------------------

//--- Routine Hooks ------------------------------------------------------------
pushvar pc
origin  0x0CB478
base    0x80150A38
scope z_cancel_hook: {
          jal z_cancel_routine
          nop
}

pullvar pc
//--- End Routine Hooks --------------------------------------------------------

//--- Z-Cancel Custom Routine --------------------------------------------------
align(4)
scope z_cancel_routine: {
  constant StackSize(0x20)
  prologue:
          subiu sp, sp, StackSize
          sw    ra, 0x1C (sp)
          sw    v0, 0x10 (sp) // Save v0
          sw    v1, 0x14 (sp) // Save v1
          sw    a0, 0x18 (sp) // Save a0
          lui   t0, 0x800A
          lw    t0, 0x50E8 (t0) // Pointer to pointers
  loop: {
          lw    t1, 0x78 (t0) // Pointer
          beq   t1, a0, cpu_check
          nop
          b     loop
          addiu t0, 0x74 // Update pointer
  }
  cpu_check:
          lbu   t2, 0x22 (t0) // Player status
          beqz  t2, original // If status == CPU
          nop
          jal   fn.ssb.getRandomInt
          lli   a0, Z_CANCEL_CHANCE.Total
  cpu_cancel:
          sltiu t1, v0, Z_CANCEL_CHANCE.Success
          beqz  t1, no_cancel
          nop
          b     epilogue
          lli   at, 0x01
  no_cancel:
          b     epilogue
          lli   at, 0x00
  original:
          lw    t6, 0x0160 (v1)
          slti  at, t6, 0x0B
  epilogue:
          lw    ra, 0x1C (sp)
          lw    v0, 0x10 (sp) // Restore v0
          lw    v1, 0x14 (sp) // Restore v1
          lw    a0, 0x18 (sp) // Restore a0
          jr    ra
          addiu sp, StackSize
}

//--- End Routine --------------------------------------------------------------

// Verbose Print info [-d v on cli]
if {defined v} {
  print "included cpu-z-cancel.asm\n"
  print "CPU Z-Canceling Control Hack Added!\n\n"
}
