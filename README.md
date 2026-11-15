# Claus for Alarm

A winter-sports tower defense by team **Camel Claus**: toy-like elf athletes and the camel hero Camel Claus defend
a snowy college ski course against layered rolling snowballs. Made in Godot 4.7.2 (GDScript, Compatibility renderer)
for the Christmas at Conn hackathon.

Project page: https://quentin-drucker.itch.io/claus-for-alarm

## Play from this repository

1. Install **Godot 4.7.2** (standard build, not .NET): https://godotengine.org/download/archive/4.7.2-stable/
2. Download this repository (`git clone https://github.com/quentin-drucker/Claus-for-Alarm.git` or
   *Code → Download ZIP*) and extract it.
3. Open Godot, choose **Import**, select `project.godot`, then **Import & Edit**. The first open imports all
   models, textures and audio (about a minute).
4. Press **F5** (Run Project). The game starts at the title screen.

Nothing else is needed: every model, texture, font, sound and script the game uses is in the repository.

### Browser build (optional)

Install the 4.7.2 export templates (*Editor → Manage Export Templates → Download and Install*), then:

```bash
godot --headless --path . --export-release "Web" build/web/index.html
python -m http.server 8000 -d build/web    # open http://localhost:8000 (not file://)
```

## Controls

| Input | Action |
|---|---|
| `1`–`7` or click a shop card | buy a defender, then click beside the track to place it |
| Click a defender | select it: upgrades, target priority, sell |
| Hover tickets | collect Ticket Booth income |
| `Space` | start the next round |
| `F` | game speed 1× / 2× / 4× |
| `P` | pause |
| `T` | cycle target priority of the selected defender |
| `Q` / `E` | Camel Claus abilities (Frenzy / Focus) |
| `Esc` | back / deselect |
| `F8` | toggle the subtle pixel/vignette screen finish (comparison) |

## Repository map

- `scenes/`, `scripts/`, `resources/`, `assets/`: the game. `tests/`: headless tests
  (`godot --headless --path . -s res://tests/<test>.gd`, exit 1 = failure); see `docs/COMMANDS.md`.
- `art_src/`: Blender sources and asset tools (ignored by Godot). `web/`: browser loading shell.
- `docs/`: conventions, art style, architecture, session log. `references/design/`: design documents and master plan.
- `website/`: the project's showcase site. Credits and licences: `CREDITS.md`.
