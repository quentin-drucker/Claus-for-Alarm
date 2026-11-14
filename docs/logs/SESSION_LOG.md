# Session log

Append one entry per session (template: master plan §12.2). Evidence files go in `docs/logs/evidence/`.

#### SESSION 2026-11-13 — Claude (Opus 5.5) — P00 (T01–T11)
- **Goal:** document setup + audit; no gameplay code.
- **Read:** master plan §§1–7, P00; HYB-M M-00/M-01/M-06/M-13; HYB-A A-00; HYB-B B-00/B-17.
- **Repo commit before:** `b1c1bc8`; baseline checkpoint `d1567e1` (P00-T05).
- **Files changed:** design-doc paths fixed (`docs/design|research` → `references/design|research`, `cc-v-0` → real path,
  title → Claus for Alarm); `CLAUDE.md`, `docs/CONVENTIONS.md`, `references/README.md`; new `docs/REGISTRY.md`,
  `docs/IMPLEMENTATION_ASSUMPTIONS.md`, `docs/COMMANDS.md`, this log; removed empty stubs `docs/PLAN.md`, `docs/DEVLOG.md`,
  `docs/ART_DIRECTION.md` (superseded by master plan / design 02–03).
- **Verified:** Godot `4.7.2.stable.official.ed1daf0bf` at the `.mcp.json` path; Web templates 4.7.2 incl. nothreads;
  `project.godot` = GL Compatibility, Jolt 3D; headless boot OK ("no main scene" expected — blank project, no scripts/scenes).
- **Not verified:** Godot MCP connection — this session was opened on the parent folder so `.mcp.json` was not loaded,
  and `addons/godot_mcp` is not installed yet. Optional `BTD6_reference_balance_data.json` absent (non-blocking).
- **Known conflict resolved:** CONVENTIONS "Art pipeline" (pixel_bake primitive workflow from North Pole) contradicted
  HYB-B anti-primitive charter → replaced with pointer to design 03; `pixel_bake.py` kept as legacy reference only.
- **Owner decisions needed:** D-02…D-12 (all PROPOSED), hackathon deadline/submission rules, repo public vs private.
- **Next suggested tasks:** P01-T01…T04 (minimal main scene, editor run, Web preset), after opening a Claude session in
  `claus-for-alarm/` so the Godot MCP loads.
