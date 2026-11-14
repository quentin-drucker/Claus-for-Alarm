# Claus for Alarm — Commands (P00-T10)

Run from the project root (`Claus for Alarm/`) in Git Bash.

```bash
GODOT="/c/Program Files/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe"

"$GODOT" --version                                   # expect 4.7.2.stable.official
"$GODOT" -e --path .                                 # open editor
"$GODOT" --headless --path . --import                # refresh import/UID cache
"$GODOT" --path .                                    # run main scene
"$GODOT" --headless --path . -s res://tests/<t>.gd   # run a test (exit 1 = fail)
for t in test_data test_map test_match test_combat test_towers test_upgrades test_hero test_ui test_full_run test_audio; do "$GODOT" --headless --path . -s res://tests/$t.gd || echo "$t FAILED"; done

# Web export (preset "Web" in export_presets.cfg: single-threaded, no GDExtension, desktop VRAM compression)
rm -rf build/web && mkdir -p build/web
"$GODOT" --headless --path . --export-release "Web" build/web/index.html   # exit 0, no ERROR/WARNING lines
"$GODOT" --headless --main-pack build/web/index.pck --quit-after 5   # exported data loads: no ERROR lines
python -m http.server 8000 -d build/web              # then open http://localhost:8000 (never file://)
```

Web templates installed: `%APPDATA%/Godot/export_templates/4.7.2.stable/` (incl. `web_nothreads_*`).

## Web smoke test (match build, since P07)

Expected `build/web/`: `index.html`, `index.js`, `index.wasm` (~39 MB, ~10 MB gzipped), `index.pck`,
`index.audio.worklet.js`, `index.audio.position.worklet.js`, `index.png`, `index.icon.png`, `index.apple-touch-icon.png`.

1. Export, then the export check: `--main-pack build/web/index.pck --quit-after 5` prints no ERROR lines (since P13
   the main scene is the title screen, so no STATE line until Play).
2. Zip for itch (index.html at the zip root) — see `docs/PUBLISHING.md`; extract the zip into an empty folder and serve
   *that* folder (`python -m http.server 8000 -d <folder>`), so the test covers the exact upload.
3. Browser console (F12): `Build configuration: ... single-threaded`, `STATE BOOT -> PREPARE`, 0 errors/warnings.
4. Press `1`, place two Rookies beside the track, click one: info card shows three upgrade buttons, Target + Sell.
   Click Bottom (`Long-Distance Lob $90`): card shows 0-0-1, range 40, invested $290. Click Target: First → Last.
5. `Space` starts round 1; snowballs pop; `F` = 2×. Round 1 ends in Prepare with 0 leaks if both Rookies cover the
   first bend; cash = 650 − 400 − 90 + 20 pops + 101 bonus = **$281**, lives 150.

No COOP/COEP headers needed while thread support stays off. Automated with playwright-cli against
`http://localhost:8000` (see SESSION_LOG). Evidence: `docs/logs/evidence/p09_web_*` (G4), `p07_web_*` (G3). P01 smoke scene is gone
(tag `p01-web-smoke`).

## Art pipeline (P15, Blender 5.3 via MCP or the Blender Python console)

Scripts in `art_src/tools/` rebuild each asset from scratch, save the `.blend` in `art_src/` and export the GLB to
`assets/models/` (`exec(open(r"<project>/art_src/tools/<script>.py").read())`):

| Asset | Run | Output |
|---|---|---|
| Rookie elf | `build_elf_rookie.py`, then `rig_elf.py` | `art_src/characters/elf_rookie.blend`, `assets/models/elf_rookie.glb` |
| Snowball shell + marker band | `build_snowball.py` | `art_src/enemies/snowball_shells.blend`, `snowball_shell.glb`, `snowball_marker.glb` |
| Lodge | `build_lodge.py` | `art_src/environment/lodge.blend`, `lodge.glb` |
| QA renders | set `ASSET = "elf_rookie" \| "snowball" \| "lodge"`, run `qa_render.py` | `docs/logs/evidence/p15_<asset>_{clay_turnaround,silhouette,closeup}.png` |

Headless (no editor needed; same scripts, Windows paths inside the `r'...'` strings):

```bash
BLENDER="/c/Program Files/Blender Foundation/Blender 5.3/blender.exe"
T='C:\Users\qdruc\Projects\Godot\Camel Claus\Claus for Alarm\art_src\tools'
"$BLENDER" -b --python-expr "exec(open(r'$T\build_elf_rookie.py').read()); exec(open(r'$T\rig_elf.py').read())"   # ~5 s: .blend + .glb + elf_eye.png
"$BLENDER" -b art_src/characters/elf_rookie.blend --python-expr "ASSET='elf_rookie'; PREFIX='p15b'; exec(open(r'$T\qa_render.py').read())"
```

`PREFIX` picks the evidence file prefix (default `p15`). The eye texture Godot extracts (`assets/models/elf_rookie_elf_eye.png`)
keeps `compress/mode=0`, `mipmaps/generate=false` in its `.import` (set once via `godot_import_set`); reimport the `.glb`
after an export with `godot_import_set` (the editor only rescans on focus).

Checks: `check_rig_reuse.py` (Blender, with `elf_rookie.blend` open) measures how the Rookie actions transfer to
other elf proportions; `python art_src/tools/zoom_crop.py in.png out.png x y w h scale` makes nearest-neighbour zooms of
game-camera captures for readability checks.

Shared helpers and the palette: `cc_art.py` (`metaball_mesh` = continuous sculpted forms, `band_elements` = trims that
follow a garment's real cross-section, `export_glb`). After re-export: reimport in Godot (focus the editor), run the
tests, then the Web export check above.
