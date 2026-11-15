# Deferred work and optional extensions

Owner scope decisions, 2026-11-14. These are possible later tasks, not current submission requirements or promises to implement them.

| Item | Current decision | Possible later work |
| --- | --- | --- |
| Additional model rigging | Deferred for time constraints. Use the already-rigged final Rookie; do not re-rig it. Other supplied models may remain unrigged. | Rig other characters if time permits and the owner reopens the work. |
| Complex character animation | Deferred. Prefer simple shared whole-object activity feedback for working towers, such as a small bob, pulse, tilt or recoil, without requiring skeletons. This is intended direction, not a claim that animations are implemented. | Bespoke attacks, locomotion, facial animation and per-character animation libraries. |
| Winter Games Lodge / Monkey Village | No creation or inclusion in the hackathon submission. Retain concept references only. | Optional later expansion/extension. |
| Cannon barrel/recoil assembly (P16-T04) | Deferred. The proof recoils the single Tripo mesh as a whole on a visual pivot (P15-A03). | Separate barrel, swivel and sled in the source and animate the barrel only. |
| Remaining Tripo models | Inspected and profiled only (P15-A01); Cannon is the only prepared/integrated one. | Prepare Ranger, Wax, Sorcerer, Booth and Camel Claus in small verified batches after the Cannon review; AccuRIG Rookie needs minimal clips or an agreed fallback before it replaces `elf_rookie.glb`. |
| Track Gritter / Spike Factory | No creation or inclusion in the hackathon submission. Retain concept references only. | Optional later expansion/extension. |

This animation/rigging decision supersedes earlier mandatory shared-rig, re-rig and detailed animation production requirements for the current build. It does not change gameplay behavior or otherwise expand the tower roster. The authoritative source-model list is [art_src/models/README.md](../art_src/models/README.md).
