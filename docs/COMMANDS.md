# Claus for Alarm — Commands (P00-T10)

Run from the project root (`Claus for Alarm/`) in Git Bash.

```bash
GODOT="/c/Program Files/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe"

"$GODOT" --version                                   # expect 4.7.2.stable.official
"$GODOT" -e --path .                                 # open editor
"$GODOT" --headless --path . --import                # refresh import/UID cache
"$GODOT" --path .                                    # run main scene
"$GODOT" --headless --path . -s res://tests/<t>.gd   # run a test (exit 1 = fail)
for t in test_data test_map test_match; do "$GODOT" --headless --path . -s res://tests/$t.gd || echo "$t FAILED"; done

# Web export (preset "Web" in export_presets.cfg: single-threaded, no GDExtension, desktop VRAM compression)
rm -rf build/web && mkdir -p build/web
"$GODOT" --headless --path . --export-release "Web" build/web/index.html   # exit 0, no ERROR/WARNING lines
"$GODOT" --headless --main-pack build/web/index.pck --quit-after 5   # exported data loads: no ERROR lines
python -m http.server 8000 -d build/web              # then open http://localhost:8000 (never file://)
```

Web templates installed: `%APPDATA%/Godot/export_templates/4.7.2.stable/` (incl. `web_nothreads_*`).

## Web smoke test (P01-T09)

Expected `build/web/`: `index.html`, `index.js`, `index.wasm` (~39 MB, ~10 MB gzipped), `index.pck`,
`index.audio.worklet.js`, `index.audio.position.worklet.js`, `index.png`, `index.icon.png`, `index.apple-touch-icon.png`.

1. Browser console (F12) shows `Build configuration: ... single-threaded` and `SMOKE_READY renderer=gl_compatibility web=true`, 0 errors.
2. Screen shows `PLAY TEST`, an FPS line, a grey-white plane with a red box.
3. Click and press a key: `last input` updates, console prints `SMOKE_INPUT ...`, blip is audible (first gesture unlocks audio).
4. Resize the window: canvas fills it. `F` enters fullscreen, `F` or `Esc` leaves.

No COOP/COEP headers needed while thread support stays off. Automated version of this check: see SESSION_LOG P01 entry
(playwright-cli against `http://localhost:8000`). Evidence lives in `docs/logs/evidence/p01_*`.
