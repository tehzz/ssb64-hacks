//bass-n64
//=== Customizable Hitbox Display =========================
// In battle D-Pad handler to switch model/hurtbox/hitbox
// memory address
// UP    -> Toggle Model
// Right -> Toggle Hurtbox
// Down  -> Toggle Hitbox
// Left  -> Toggle Collision
//=========================================================

//---Hook--------------------------------------------------
// This is within the button handler for a battle
// Original Code
// lb     t4, 0x0008(a0)
// addiu  v0, a2, 0x01BC    #Make Pointer to Buttons

pushvar pc
origin  0x5CB08
base    0x800E1308

scope dpad_hook: {
          j     dpad_handle
          addiu v0, a2, 0x001BC
}

pullvar pc

//---D-PAD Handler-----------------------------------------
// cheap registers (at, t4, t6, t5)
//--Register Map---------
// at : u16 button masks
// t4 : u16 new button presses
// t5 : u8  data.hitboxFlags
// t6 : u32 &data.hitboxFlags
scope dpad_handle: {
  constant dpadRight(0x0100)
  constant  dpadLeft(0x0200)
  constant  dpadDown(0x0400)
  constant    dpadUp(0x0800)

  // grab new button presses
          lw    t4, 0x01B0(a2)
          lhu   t4, 0x0002(t4)
  // grab data.hitboxFlags
          la    t6, data.hitboxFlags
          lbu   t5, 0x0000(t6)
  up:     // D-PAD UP = Models
          andi  at, t4, dpadUp
          beqz  at, right
          andi  at, t4, dpadRight
  // toggle model bit
          xori  t5, t5, def.hbFlags.hideModel
  right:
          beqz  at, down
          andi  at, t4, dpadDown
  // toggle hurtbox bit
          xori  t5, t5, def.hbFlags.hurtbox
  down:
          beqz  at, left
          andi  at, t4, dpadLeft
  // toggle hitbox bit
          xori  t5, t5, def.hbFlags.hitbox
  left:
          beqz  at, epilogue
          nop
  // toggle collision bit
          xori  t5, t5, def.hbFlags.collision
  epilogue:
  // store hitbox flags back into RAM
          sb    t5, 0x0000(t6)
  // return to code flow
          j     dpad_hook + 0x8
          lb    t4, 0x0008(a0)        // original line 1
}

if {defined v} {        // Verbose Print info [-d v on cli]
  print "included dpad-handle.asm \n"
}
