<!-- BEGIN:godot-mcp -->
@AGENTS.md
<!-- END:godot-mcp -->

# Claus for Alarm (hackathon entry)

Winter-sports tower defense by team Camel Claus: toy-like athletes and the camel hero Camel Claus defend a snowy
college ski course against layered rolling snowballs. Godot 4.7.2, GDScript, Compatibility renderer, browser build.
Theme: festive / Christmas at Conn; secret sub-theme: Winter Sports (see `docs/HACKATHON.md`).

@docs/CONVENTIONS.md

## Project hierarchy (master plan §11.1)

Before any feature implementation, read `references/design/00_Camel_Claus_MASTER_Development_Plan.md` and the exact
sections of `references/design/01_Camel_Claus_Hybrid_Gameplay_and_Balance.md`,
`references/design/02_Camel_Claus_Hybrid_Art_UI_Audio.md` and `references/design/03_Camel_Claus_Hybrid_3D_Assets_Blender.md`
referenced by that task ID. `references/research/BTD6_*.md` are secondary inspiration/numeric baseline with explicit
version gaps; never silently treat them as exact implementation specs. Work in small verified phases (only the task
IDs the owner authorized), keep game mechanics independent of visual assets, test Godot editor **and** Web, update
master checkboxes only after evidence, and do not overwrite approved files or start later phases without authorization.

- Art, UI, audio and models follow design docs 02 and 03; if something needed is undecided there, ask instead of inventing.
- After each session, append an entry to `docs/logs/SESSION_LOG.md` (template: master plan §12.2).
- Git: after every verified step (each task batch, phase, plan/log update), commit and immediately `git push` to
  `origin`, then confirm `git status -sb` shows `main...origin/main` with nothing ahead. Report the pushed commit hash
  in each status update. No AI attribution in commits.
- Keep `references/design/00_Camel_Claus_MASTER_Development_Plan.md` current every step (checkboxes with evidence,
  status table, decision log, new deviations) and push it with the work. Leave design docs 01/02/03 unchanged
  unless they contain factually incorrect info; record owner changes as decisions in the master plan instead
  (balance follows BTD6 — don't re-tune the specs).
- Roster: `docs/REGISTRY.md`. Open assumptions: `docs/IMPLEMENTATION_ASSUMPTIONS.md`. Commands: `docs/COMMANDS.md`.
- `art_src/` holds Blender sources and has a `.gdignore`; export game-ready `.glb` into `assets/models/`.
