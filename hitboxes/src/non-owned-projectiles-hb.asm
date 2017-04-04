//bass-n64
//=== "Non-Own" Projectiles Hitbox Display =====================================
//   Render "not-self" or "non-own" projectiles as either the model, or the
//  hitbox, or both--based on data.hitboxFlags flag
//  This class includes things like Link's bombs
//==============================================================================

// Replace the entire routine from 8017224C to 80172310

pushvar pc
origin  0xECC8C
base    0x8017224C

//---stack map------------------------------------
// + 0x14 <- ra
// + 0x18 <- s0
// + 0x1C <- *(a0+0x84)
// base + 0 <- a0
//---reg map--------------------------------------
// s0 = hitbox flag state

scope drawNonOwnedProjectile: {
  nonLeafStackSize(2)
  constant  checkIfNeeded(0x80171C10)
  constant  drawNormalModel(0x80172008)
  constant  drawCollisionDiamond(0x801719AC)
  constant  drawHitboxSquare(0x80171410)

  prologue:
          subiu sp, sp, {StackSize}
          sw    ra, 0x0014(sp)
          sw    s0, 0x0018(sp)
          or    a1, a0, r0
          lw    a0, 0x0084(a0)
          sw    a1, {StackSize} + 0 (sp)    // input a0 register
          jal   checkIfNeeded
          sw    a0, 0x001C(sp)
// check if there is anything to draw...?
          lw    a0, 0x001C(sp)              // this isn't needed....
          beqz  v0, epilogue
          lw    a1, {StackSize} + 0 (sp)    // this really isn't either, since it can be loaded before jal

  get_hitbox_flag_state:
          lbuAddr(s0, data.hitboxFlags,0)
  model_check:
          andi  at, s0, def.hbFlags.hideModel
          bnez  at, hitbox_checks
          nop
  draw_model:
          jal   drawNormalModel
          or    a0, a1, r0
  hitbox_checks:
  // There's only one routine that draws the combined hurtbox/hitbox
          andi  at, s0, (def.hbFlags.hitbox | def.hbFlags.hurtbox)
          beqz  at, epilogue
          lw    a0, 0x001C(sp)
          lw    a1, {StackSize} + 0 (sp)
  // the game has three checks before drawing a hitbox
  // This check is before both hitbox and collision, and it needs to pass
          lw    t6, 0x02CC(a0)
          sll   t8, t6, 0x11
          bltz  t8, epilogue          // original checks for >= 0 to continue
          lw    t9, 0x0248(a0)
  // check 2 and 3: only for hitboxes; only one check needs to pass
  // in game, they pass if != 0; so, load both, OR together, and compare to zero.
  // if == 0, then they have both failed
          lw    t0, 0x010C(a0)
          or    t8, t0, t9
          beqz  t8, epilogue
          nop
  draw_hitbox:
          jal   drawHitboxSquare
          or    a0, a1, r0

  epilogue:
          lw    ra, 0x0014(sp)
          lw    s0, 0x0018(sp)
          jr    ra
          addiu sp, sp, {StackSize}

  // Nop rest of orignal routine
  nopUntilPC(0x80172310, "Replacement drawNonOwnedProjectile Routine Overflow")
}
pullvar pc

if {defined v} {        // Verbose Print info [-d v on cli]
  print "included non-owned-projectiles-hb.asm \n"
}
