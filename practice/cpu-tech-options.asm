//bass-n64
//=== CPU Tech Option Randomizer [bit] =========================================
// Fine-grained control over CPU tech options. Possibly extend this with a menu?
// Shamelessly stolen from bit:
//   https://github.com/abitalive/SuperSmashBros/blob/master/Patches/cpu_tech_cancel.asm
//==============================================================================

//--- Control Constants --------------------------------------------------------
scope TECH_CHANCE {
  constant Total(100)
  constant Forward(30)
  constant Backward(30)
  constant InPlace(30)
  // Non-tech chance is (Total - forward - backward - in-place)
}
constant ZCancelChance(100)
//------------------------------------------------------------------------------

//--- Routine Hooks ------------------------------------------------------------
//-- Tech Hooks ----------------------------------------------------------------
pushvar pc
origin  0x0BB3C0
base    0x80140980
scope tech_hook1: {
  constant hook_end(0x801409A4)
          jal tech_routine
          nop
          j   hook_end
          nop

  nopUntilPC(hook_end, "First Tech Hook")
}

origin  0x0BE034
base    0x801435F4
scope tech_hook2: {
  constant hook_end(0x80143620)
          jal tech_routine
          nop
          j   hook_end
          nop

  nopUntilPC(hook_end, "Second Tech Hook")
}
pullvar pc
//--- End Routine Hooks --------------------------------------------------------

//--- Tech Custom Routine ------------------------------------------------------
align(4)
scope tech_routine: {
  constant cpuTechRollFn(0x80144700)
  constant cpuTechInPlaceFn(0x80144660)
  constant noTechFn(0x80144498)
  // Enumeration of tech directions for cpu tech routines?
  scope TECH_DIRECTIONS {
    constant Forward(0x49)
    constant Backward(0x4a)
  }

  nonLeafStackSize(0)
  prologue:
          subiu sp, sp, {StackSize}
          sw    ra, 0x14 (sp)
          lui   t0, 0x800A
          lw    t0, 0x50E8 (t0) // Pointer to pointers
  state_check_loop: {
          lw    t1, 0x78 (t0) // Pointer
          beq   t1, s0, cpu_check
          nop
          b     state_check_loop
          addiu t0, 0x74 // Increment pointer
  }

  cpu_check:
          lbu   t2, 0x22 (t0) // Player status
          beqz  t2, handle_man_player // If status == CPU
          nop
  poll_RNG:
          jal   fn.ssb.getRandomInt
          lli   a0, TECH_CHANCE.Total

  cpu_tech_forward:
          sltiu t1, v0, TECH_CHANCE.Forward
          beqz  t1, cpu_tech_backward
          nop
          move  a0, s0
          jal   cpuTechRollFn
          lli   a1, TECH_DIRECTIONS.Forward
          b     epilogue
          nop
  cpu_tech_backward:
          sltiu t2, v0, (TECH_CHANCE.Forward +  TECH_CHANCE.Backward)
          beqz  t2, cpu_tech_in_place
          nop
          move  a0, s0
          jal   cpuTechRollFn
          lli   a1, TECH_DIRECTIONS.Backward
          b     epilogue
          nop
  cpu_tech_in_place:
          sltiu t2, v0, (TECH_CHANCE.Forward +  TECH_CHANCE.Backward + TECH_CHANCE.InPlace)
          beqz  t2, cpu_no_tech
          nop
          jal   cpuTechInPlaceFn
          move  a0, s0
          b     epilogue
          nop
  cpu_no_tech:
  // No need to check rng value, as all other options have been exhausted
          jal   noTechFn
          move  a0, s0
          b     epilogue
          nop
  // For non-cpu players, handle normally...?
  handle_man_player:
          jal   0x80144760 // Handle Tech roll?
          move  a0, s0
          bnezl v0, epilogue
          nop
          jal   0x801446BC // Handle Tech in place?
          move  a0, s0
          bnezl v0, epilogue
          nop
          jal   noTechFn // Handle No tech?
          move  a0, s0
          nop
  epilogue:
          lw    ra, 0x14 (sp)
          jr    ra
          addiu sp, {StackSize}
}
//--- End Routine --------------------------------------------------------------

// Verbose Print info [-d v on cli]
if {defined v} {
  print "included cpu-tech-options.asm\n"
  print "CPU Random Tech Hack Added!\n\n"
}
