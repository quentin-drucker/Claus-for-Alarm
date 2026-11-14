# Rookie skeleton reuse check (P15-T10, 2026-11-14)

Method (`art_src/tools/check_rig_reuse.py`): rebuild the Rookie's 15-bone rig (`root, hips, spine, head, cap_tip,
upper_arm/forearm/hand .L/.R, thigh/foot .L/.R`) with each planned build's proportions, copy the Rookie's bone rolls,
play the Rookie's own `idle_loop` and `attack`, and measure the worst angle between each bone's world direction and the
Rookie's. Sanity check: identity build = 0.0° on every bone.

| Build (width × depth × height) | Arms (upper/fore/hand R) | Left arm | Spine / head | Legs |
|---|---|---|---|---|
| Biathlon Ranger — slim, tall (0.85 × 1.0 × 1.12) | 10.4° / 9.2° / 5.5° | 9.5° | 0° / 0° | ≤ 2.7° |
| Slope Wax Sprayer — broad (1.25 × 1.1 × 0.95) | 9.9° / 10.0° / 7.0° | 9.0° | 0° / 0° | ≤ 3.2° |
| Snow Sorcerer — short (1.0 × 1.0 × 0.85) | 5.9° / 6.0° / 3.5° | 5.4° | 0° / 0° | ≤ 3.5° |
| Cannon / Booth operator — stocky (1.15 × 1.1 × 0.9) | 8.8° / 9.0° / 5.4° | 8.1° | 0° / 0° | ≤ 4.3° |

**Verdict: the skeleton is reusable for all five other elves** (same bone names, hierarchy, sockets and Godot binding).
Spine, head and legs transfer unchanged. Arm poses drift 4–10° when proportions change, because Blender keys are
rest-relative. Fix at no cost: `rig_elf.py` already poses arms by world direction (`pose_bone` with a Vector), so
re-running `key()` on each variant's rig re-bakes exact poses.

What each elf needs adapted:
- **All:** a per-build proportion table (bone head/tail scale) + per-garment weight lists (`ALLOWED`), as done for the Rookie.
- **Biathlon Ranger:** a two-handed long launcher. Needs a left-hand target on the weapon per pose (left arm aimed at a
  `weapon_hand_l` point on the prop) and `muzzle_A` on the barrel, not the hand.
- **Slope Wax Sprayer:** back tank. Add the B-03 `backpack` socket on `spine`; hose nozzle in the right hand (two-hand
  hold like the Ranger).
- **Snow Sorcerer:** padded robe. Either weight the robe skirt to `hips` + both `thigh` bones (smooth blend), or add two
  short `robe` bones. Staff in the right hand; `effect_center` raised to the staff crystal.
- **Avalanche Cannon / Ticket Booth:** mechanical towers (HYB-B B-05.2/B-05.6). The machine needs its own pivots
  (`aim_swivel`, `fire_recoil` bones). An elf operator, if wanted, reuses this skeleton unchanged as a child prop.
- **Hero (Camel Claus):** different species, not this skeleton (needs neck chain, jaw, hooves; B-04).
