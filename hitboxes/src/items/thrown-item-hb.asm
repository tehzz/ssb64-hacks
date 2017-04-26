//bass-n64
//=== Thrown Item Hitbox Display ===============================================
//  This routine is nearly identical to the routine for rendering Link's bombs.
// This seems to affect thrown items and certain pokemon
//==============================================================================

// Replace the entire routine from 80171C7C to 80171D34

pushvar pc
origin  0xEC6BC
base    0x80171C7C

//---stack map------------------------------------
// + 0x14 <- ra
// + 0x18 <- s0
// + 0x1C <- *(a0 + 0x84)
// base + 0 <- 0

scope drawThrownItem: {
  nonLeafStackSize(2)
  constant  checkIfNeeded(0x80171C10)
  constant  drawNormalModel(0x80014038)
  constant  drawCollisionDiamond(0x801719AC)
  constant  drawHitboxSquare(0x80171410)

  prologue:
          subiu sp, sp, {StackSize}
          sw    ra, 0x0014(sp)
          sw    s0, 0x0018(sp)
          or    a1, a0, r0
          lw    a0, 0x0084(a0)
          sw    a1, {StackSize} + 0 (sp)
          jal   checkIfNeeded
          sw    a0, 0x001C(sp)
  // if( !checkIfNeeded ) goto epilogue
          lw    a0, 0x001C(sp)
          beqz  v0, epilogue
          lw    a1, {StackSize} + 0 (sp)

  get_hbFlag_state:
        lbuAddr(s0, data.hitboxFlags, 0)
  model_check:
          andi  at, s0, def.hbFlags.hideModel
          bnez  at, hitbox_checks
          nop
  draw_model:
          jal   drawNormalModel
          or    a0, a1, r0

  hitbox_checks:
  // hitbox and hurtbox are drawn as a pair (maybe this is why there're two checks?)
          andi  at, s0, (def.hbFlags.hitbox | def.hbFlags.hurtbox)
          beqz  at, epilogue
          lw    a0, 0x001C(sp)
          lw    a1, {StackSize} + 0 (sp)
  // load addr for in-game hitbox bit check
          lw    t6, 0x02CC(a0)
          sll   t8, t6, 0x11
          bltz  t8, epilogue          // original checks for >= 0 to continue with hitboxes
          lw    t9, 0x0248(a0)
          // load two addr that are  specifically check when drawing hitboxes
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
  nopUntilPC(0x80171D34, "Replacement drawThrownItem Routine Overflow")
}
pullvar pc

if {defined v} {        // Verbose Print info [-d v on cli]
  print "included throw-item-hb.asm \n"
}
