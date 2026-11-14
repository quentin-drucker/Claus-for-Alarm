# Claus for Alarm — Commands (P00-T10)

Run from the project root (`claus-for-alarm/`) in Git Bash.

```bash
GODOT="/c/Program Files/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe"

"$GODOT" --version                                   # expect 4.7.2.stable.official
"$GODOT" -e --path .                                 # open editor
"$GODOT" --headless --path . --import                # refresh import/UID cache
"$GODOT" --path .                                    # run main scene
"$GODOT" --headless --path . -s res://tests/<t>.gd   # run a test (exit 1 = fail)

# Web export (preset "Web" is created in P01)
mkdir -p build/web
"$GODOT" --headless --path . --export-release "Web" build/web/index.html
python -m http.server 8000 -d build/web              # then open http://localhost:8000
```

Web templates installed: `%APPDATA%/Godot/export_templates/4.7.2.stable/` (incl. `web_nothreads_*`).
