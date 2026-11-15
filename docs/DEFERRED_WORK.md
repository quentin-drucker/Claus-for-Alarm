# Deferred work and optional extensions

Owner scope decisions, 2026-11-14. These are possible later tasks, not current submission requirements or promises to implement them.

| Item | Current decision | Possible later work |
| --- | --- | --- |
| Additional model rigging | Deferred for time constraints. Use the already-rigged final Rookie; do not re-rig it. Other supplied models may remain unrigged. | Rig other characters if time permits and the owner reopens the work. |
| Complex character animation | Deferred. Prefer simple shared whole-object activity feedback for working towers, such as a small bob, pulse, tilt or recoil, without requiring skeletons. This is intended direction, not a claim that animations are implemented. | Bespoke attacks, locomotion, facial animation and per-character animation libraries. |
| Winter Games Lodge / Monkey Village | No creation or inclusion in the hackathon submission. Retain concept references only. | Optional later expansion/extension. |
| Cannon barrel/recoil assembly (P16-T04) | Deferred. The proof recoils the single Tripo mesh as a whole on a visual pivot (P15-A03). | Separate barrel, swivel and sled in the source and animate the barrel only. |
| Remaining Tripo models | Cannon (Dev 8), Ranger and Wax Sprayer (Dev 9), Snow Sorcerer and Ticket Booth (Dev 10) are prepared and integrated for owner review (size/readability approval open; Ranger size kept, DEC-041). Camel Claus: inspected and profiled only. | Camel Claus next; AccuRIG Rookie needs minimal clips or an agreed fallback before it replaces `elf_rookie.glb` (separate task, no re-rig). |
| First-use browser hitches | Measured (Dev 10, `p15d_stutter_web.txt`): repeatable ~100–250 ms frames at the first placement, first round start and first shot of a page load (1.9 s on a fresh profile); none on round 2. Cause not proven (shader/pipeline compile or first audio use). | Warm materials/SFX once at match load, then re-measure. |
| Texture video memory | All 15 Tripo maps upload as uncompressed RGB8 (~86 MB video memory in the browser stress); `compress/mode=2` did not produce S3TC here. | Real VRAM compression (S3TC desktop + ETC2 mobile) and a Web check on a weaker device. |
| Ranger / Wax part motion | Deferred. Both are unrigged single meshes: the reaction moves the whole model on a visual pivot (recoil along the rifle, wax pump/tilt). | Separate the rifle / wand in the source and animate it alone, or rig. |
| Track Gritter / Spike Factory | No creation or inclusion in the hackathon submission. Retain concept references only. | Optional later expansion/extension. |

This animation/rigging decision supersedes earlier mandatory shared-rig, re-rig and detailed animation production requirements for the current build. It does not change gameplay behavior or otherwise expand the tower roster. The authoritative source-model list is [art_src/models/README.md](../art_src/models/README.md).
