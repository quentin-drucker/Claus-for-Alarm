# Publishing Claus for Alarm (itch.io)

Every verified milestone leaves an upload-ready ZIP in `build/archive/` (git-ignored, local only):
`claus_for_alarm_<milestone>_web_<commit>.zip` — `index.html` at the zip root, single-threaded Web export
(no SharedArrayBuffer / COOP-COEP needed). Latest: **`claus_for_alarm_p10p13_web_b3620ca.zip`** (P10 hero + P13 title/settings, ~10 MB).

## Rebuild the ZIP

```bash
GODOT="/c/Program Files/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
rm -rf build/web && mkdir -p build/web
"$GODOT" --headless --path . --export-release "Web" build/web/index.html
"$GODOT" --headless --main-pack build/web/index.pck --quit-after 5      # no ERROR lines
H=$(git rev-parse --short HEAD); (cd build/web && python -c "import zipfile,os,sys; z=zipfile.ZipFile(sys.argv[1],'w',zipfile.ZIP_DEFLATED); [z.write(f) for f in sorted(os.listdir('.')) if not f.endswith('.zip')]" ../archive/claus_for_alarm_MILESTONE_web_$H.zip)
```

Then run the Web smoke test in `docs/COMMANDS.md` against the extracted ZIP.

## Upload checklist (first time)

1. itch.io → **Upload new project**. Title *Claus for Alarm*; Kind of project: **HTML**.
2. Uploads → add the ZIP → tick **This file will be played in the browser**.
3. Embed options: **Embed in page**, viewport **1280 × 720** (the game stretches to any size); tick
   **Fullscreen button**; leave **SharedArrayBuffer support** OFF; Mobile friendly OFF (mouse + keyboard game).
   Launch: *Click to launch in fullscreen* off; *Automatically start on page load* off is fine (the click also unlocks audio).
4. Description: controls line — `1`–`6` pick a defender · click to place/select/collect tickets · upgrade buttons on the selected card · `T` target · `Space` start round ·
   `P` pause · `F` 2× speed · `Esc`/right-click cancel. Genre: Strategy; tags: tower-defense, winter, christmas.
5. Visibility: **Draft** (or Restricted) → **Save** → open the page in a private window: game loads, round 1 plays,
   F12 console has 0 errors.
6. Before the deadline (Sun Nov 15, 10:00 AM, `docs/HACKATHON.md`): set **Public**, copy the URL into the submission
   and onto the studio website.

## Updating an existing page

Uploads → delete or hide the old ZIP → add the new ZIP → tick *played in the browser* again → Save → recheck step 5.
(itch keeps the embed settings.) Optional later: `butler push build/web <user>/claus-for-alarm:html5`.
