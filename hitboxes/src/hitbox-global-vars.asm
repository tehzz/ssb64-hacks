//bass-n64
//--- .data / static variables and structs  ------------------------------------
// var *hbFlags data.hitboxFlags;
// use def.hbFlags;
// data.hitboxFlags = 0x00 & ( ~hideModel | ~hitbox | ~hurtbox | ~collision );
//------------------------------------------------------------------------------

align(8)
scope data {
  // *hbFlags data.hitboxFlags
  // set to initially show only the normal model (which should be 0x0)
  hitboxFlags:
  db  ( 0x00 & (~def.hbFlags.hideModel | ~def.hbFlags.hitbox | ~def.hbFlags.hurtbox | ~def.hbFlags.collision) );

  // pad to take up a word
  db 0, 0, 0
}
