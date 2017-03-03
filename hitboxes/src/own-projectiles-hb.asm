//bass-n64
//=== "Own" Projectiles Hitbox Display ===============================
// Render "self" or "own" projectiles as either the model, or the
// hitbox, or both--based on data.hitboxFlags flag
// This class includes things like Link's boomerage, Mario's fireballs,
// and beam swords. Doesn't include things like Link's bombs...
//====================================================================

// at 8016753C is a series of checks for projectiles. Set it up to
// check for model and hitbox based on these enums
// might just want to replace the whole routine... for flag stack saving?

pushvar pc
origin 0xE1F60
base   0x80167520

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
          andi  at, s1, def.hbFlags.hideModel
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
          andi  at, s1, def.hbFlags.hitbox
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
  nopUntilPC(0x801675CC, "Replacement Projectile Rendering Routine")
}
pullvar pc

print "included own-projectiles-hb.asm \n"
