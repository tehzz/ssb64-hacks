# Hitbox "Refactoring"

Hack to allow for hitboxes, hurtboxes, normal models, and collision to be selectively combined. This lets you see, for example, where a hitbox is on the actual model, instead of just on the mess of yellow hurtboxes.

**Currently uses the expansion pak ):**

**Collision display probably only works with normal model on, but this is not enforced in the code yet...**

### "Controls"
During a battle:
* D-PAD UP: toggle *normal model* on/off
* D-PAD Right: toggle *hurtboxes* on/off
* D-PAD Down: toggle *hitboxes* on/off
* D-PAD Left: toggle *collision diamond* on/off

### Build Instructions
1. Clone repository
2. Place a big-endian NTSC-U `Super Smash Bros. (U) [!].z64` ROM in `../ROM/`, or modify line 10 of `main.asm` to point to a valid SSB64 ROM
3. Run `make`

### Things To Do
1. Modify code that handles "non-owned" (?) projectiles like Link's bombs
2. Test on console lol
3. Deal with collision (only seems to work when there is an original base model)
4. Fit character model hitbox code back within the original routine
5. Make hitboxes/hurtboxes transparent when overlayed on normal character model (probably goes against #4, unless I make a routine to check for an expansion pak...?)
