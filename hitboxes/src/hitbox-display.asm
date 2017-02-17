//bass-n64

//=== Customizable Hitbox Display =========================
// Allow for any of model, hurtbox, hitbox, and collision-box
// to be displayed at any time
//=========================================================

//--- assembler only defines --------------------
scope def {
  scope hbFlags {
     // a "hide model" flag, so 0x0 == show only the model
    constant hideModel(0b00000001)    //0x01
    constant   hurtbox(0b00000010)    //0x02
    constant    hitbox(0b00000100)    //0x04
    constant collision(0b00001000)    //0x08
  }

  constant renderHurtbox(0x800F2584)
}

//---.data---------------------------------------
align(8)
scope data {
  // u8 hbFlags; set to 0x00 to initially show the normal model
  hitboxFlags:
  db  0x00

  // pad to take up a word
  db 0, 0, 0
}

//---.text---------------------------------------
//--Hooks into model rendering routine
pushvar pc
scope hook {
// Main split; Five Instructions from 2C00 to 2C14
  origin 0x6E400
  base   0x800F2C00
  beginning:
          j     render
          nop
          j     end
          nop
          nop

//----Beginning of code that renders the normal character model-----------------
  origin 0x6E414
  base   0x800F2C14
  render_model:

// End of render_model code, jr ra back to render custom routine
// 800F2FC8 lw     t7, 0x0B4C(s8)
//          addiu  at, r0, 0x0003
//          bnel   t7, at, 0x800F364C
//          lw     v0, 0x0020(s8)
  origin 0x6E7CC
  base   0x800F2FCC
          j     render.collision
          nop
//------------------------------------------------------------------------------

//----Beginning of collision diamond and grab-box rendering---------------------
  origin 0x6E7D8
  base   0x800F2FD8
  render_collision:

// End of render_collision; jump back to custom render routine
// original code is "b 0x800F3648" (branch to end of model rendering), so
// just replace the branch with a jump to custom code
  origin 0x6EB04
  base   0x800F3304
          j     render.hurtbox

//------------------------------------------------------------------------------

//----Beginning of Hitbox rendering code----------------------------------------
  origin 0x6EB58
  base   0x800F3358
  render_hitbox:
// End of render_hitbox; jump back to custom render routine
  origin 0x6EE48
  base   0x800F3648
          j     render.epilogue
          nop
//------------------------------------------------------------------------------


//----End of all code that deals with model rendering---------------------------
// Real end is a 800F3648, but need space to jump back from rendering hitboxes
// Take two instructions from 800F3648 and 800F364C and put in render.epilogue
  origin 0x6EE50
  base   0x800F3650
  end:
}
pullvar pc

align(4)
// Want to render model -> collision -> hurtbox -> hitbox(es), since that's
// the order the game renders. This is the best chance to keep a semi-okay register setup...
scope render: {
  // Branch between an explicit model only path and an individual components path
      lbuAddr(t0, data.hitboxFlags, 0)
          //beqzl t0, only_model
          //nop
  model:
  // if not just the model, check for each component
          lli   at, def.hbFlags.hideModel
          and   at, t0, at            // check if model should be hidden
          bnez  at, collision
          nop
          j     hook.render_model
          nop

  collision:
      lbuAddr(t0, data.hitboxFlags, 0)
          lli   at, def.hbFlags.collision
          and   at, t0, at
          beqz  at, hurtbox
          nop
          j     hook.render_collision
          nop

  hurtbox:
  // The hurtbox code is already routines, could maybe just call them here!
      lbuAddr(t0, data.hitboxFlags, 0)
          lli   at, def.hbFlags.hurtbox
          and   at, t0, at
          beqz  at, hitbox
          nop
  // Call renderHurtbox ourselves
  // Maybe eventually put in the 0x3EA check to "unmoor" hurtbox?
          jal   def.renderHurtbox
          lw    a0, 0x0074(s6)

  hitbox:
  // have to isolate why it is only drawn sometimes.... (eg outside of battle)
      lbuAddr(t0, data.hitboxFlags, 0)
          lli   at, def.hbFlags.hitbox
          and   at, t0, at
          beqz  at, epilogue
          nop
          j     hook.render_hitbox
          nop

  epilogue:
          lw    v0, 0x0020(s8)        // original instruc at 800F3648
          j     hook.end
          addiu at, r0, 0x0001        // original instruc at 800F364C


  only_model:
}

// at 8016753C is a series of checks for projectiles. Set it up to
// check for model and hitbox based on these enums

pushvar pc
origin 0xE1F60
base   0x80167520
// might just want to replace the whole routine... for flag stack saving?
scope projectile_hb {
  nonLeafStackSize(2)
  constant projecModelFn1(0x80167454)
  constant projecModelFn2(0x801674B8)
  constant collisionFn(0x801671F0)
  constant hitboxFn(0x80166E80)

  prologue:
          subiu sp, sp, {StackSize}
          sw    ra, 0x0014(sp)
          sw    s0, 0x0018(sp)
          sw    s1, 0x001C(sp)
          sw    a1, {StackSize} + 4 (sp)
  // set up v0 and s0
          lw    v0, 0x0084(a0)
          or    s0, r0, a0
  // grab hitbox flag state
      lbuAddr(s1, data.hitboxFlags, 0)
  model_check:
          lli   at, def.hbFlags.hideModel
          and   at, s1, at
          bnez  at, hitbox_check
          nop
  draw_projectile_model:
  // code from game...
          jal   projecModelFn1
          nop
          lw    t9, {StackSize} + 4 (sp)
          jalr  ra, t9
          or    a0, r0, s0
          jal   projecModelFn2
          nop
  hitbox_check:
          lli   at, def.hbFlags.hitbox
          and   at, s1, at
          beqz  at, epilogue
          nop
  draw_projectile_hitbox:
          jal   hitboxFn
          or    a0, r0, s0
  epilogue:
          lw    ra, 0x0014(sp)
          lw    s0, 0x0018(sp)
          addiu sp, sp, {StackSize}
          jr    ra
          lw    s1, 0x001C(sp)

  // Nop rest of orignal routine
  if ( pc() >= 0x801675CC) {
    error "Replacement Proejectile Hitbox Routine is too Big!!"
  }
  while (pc() < 0x801675CC) {
    nop
  }

}
pullvar pc

print "included hitbox-display.asm \n"
