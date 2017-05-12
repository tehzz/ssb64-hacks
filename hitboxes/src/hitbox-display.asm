//bass-n64
//=== Customizable Hitbox Display =========================
// Allow for any of model, hurtbox, hitbox, and collision-box
// to be displayed at any time
//=========================================================

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
          j     render.draw_boxes

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
//--End Hook--------------------------------------------------------------------

align(4)
// Want to render model -> collision -> hurtbox -> hitbox(es), since that's
// the order the game renders.
// This is the best chance to keep a semi-okay register setup...
scope render: {
  constant moorState(0x80046A58)
  // on ROM routine that renders a character's hurtbox
  constant renderHurtbox(0x800F2584)

  model:
      lbuAddr(t0, data.hitboxFlags, 0)
          andi  at, t0, def.hbFlags.hideModel   // check if model should be hidden
          bnez  at, draw_boxes        // If model is hidden, do not draw collision!
          nop
          j     hook.render_model
          nop

  collision:
  // Collision can only be drawn when there is a normal base model...
      lbuAddr(t0, data.hitboxFlags, 0)
          andi  at, t0, def.hbFlags.collision
          beqz  at, draw_boxes
          nop
          j     hook.render_collision
          nop

  draw_boxes:
  // To prevent console crashes (for eg 1P Mode or 4 players in CSS)
  //   don't render hit/hurtboxes when there is already a model being rendered
  //  if ( hbFlags.hideModel || Mooring == 0x3EA ) { render }
      lbuAddr(t0, data.hitboxFlags, 0)
          andi  at, t0, def.hbFlags.hideModel
          bnez  at, hurtbox           // TRUE, no model, so continue
          // nop (Branch Delay)
      lwAddr(t0, moorState, 0)
          lw    t0, 0x0000(t0)
          ori   at, r0, 0x03EA        // seems to be the value in battle...
          bne   t0, at, epilogue      // != 3EA, model and not in battle, don't draw boxes
          nop

  hurtbox:
  // The hurtbox code is already routines, could maybe just call them here!
      lbuAddr(t0, data.hitboxFlags, 0)
          andi  at, t0, def.hbFlags.hurtbox
          beqz  at, hitbox
          nop
  // Call renderHurtbox ourselves
  // Maybe eventually put in the 0x3EA check to "unmoor" hurtbox?
          jal   renderHurtbox
          lw    a0, 0x0074(s6)

  hitbox:
  // have to isolate why it is only drawn sometimes.... (eg outside of battle)
      lbuAddr(t0, data.hitboxFlags, 0)
          andi  at, t0, def.hbFlags.hitbox
          beqz  at, epilogue
          nop
          j     hook.render_hitbox
          nop

  epilogue:
          lw    v0, 0x0020(s8)        // original instruc at 800F3648
          j     hook.end
          addiu at, r0, 0x0001        // original instruc at 800F364C
}
if {defined v} {        // Verbose Print info [-d v on cli]
  print "included hitbox-display.asm \n"
}
