# Publishing Claus for Alarm (itch.io)

Every verified milestone leaves an upload-ready ZIP in `build/archive/` (git-ignored, local only):
`claus_for_alarm_<milestone>_web_<commit>.zip` — `index.html` at the zip root, single-threaded Web export
(no SharedArrayBuffer / COOP-COEP needed).

**Latest candidate (final, 2026-11-15 09:10): `build/archive/claus_for_alarm_final_web_deb4aa6.zip`** (adds DEC-052 no pixelation + wafting gusts, DEC-053 camel menu; Chrome 0 console errors). Superseded: `claus_for_alarm_final_web_b36c973.zip` (36,712,224
bytes): everything on `main` at `b36c973` — fonts, vignette/powder finish (DEC-050), Ticket Booth tickets, ambient
snow + gusts (DEC-051). Release export 0 ERROR/WARNING; Chrome match smoke 0 console errors (`p17t07_web_snowfall.png`).
Not yet uploaded to itch.io by this session.

Previous candidate (Dev 13 audit, 2026-11-15 07:45): `build/archive/claus_for_alarm_dev13audit_web_e71f47a.zip`
(36,364,182 bytes, SHA-256 `2f624688...778ff8`): upgrades audit + new attack/special/pop VFX, and it also contains the
parallel session's loading splash + floating menu Rookie (main at `e71f47a`). Clean-worktree export, extracted copy on
`http://localhost:8148/`, browser smoke in `docs/logs/evidence/dev13_audit_web_smoke.txt` (local only, not hosted).
Previous candidate (no audit, no splash):  `build/archive/claus_for_alarm_dev13_web_c10e144.zip`** (34,694,272 bytes,
SHA-256 `72bc5de9...79ba5c`). Exported from a clean worktree of commit `c10e144` (default HTML shell), extracted copy
served at `http://localhost:8147/` and smoke-tested in Chrome (local only, not hosted): see
`docs/logs/evidence/dev13_web_smoke.txt` and `dev13_final_web_*.png`.
**Fallback (Dev 12 RC): `build/archive/claus_for_alarm_rc_web_d098ca5.zip`** (served from `build/rc_d098ca5` on :8143).
Older ZIPs in `build/archive/` are history only.
Note: commits after `c10e144` on `main` (`3c766c1` browser loading splash, `381bee2` 4 s splash hold, by a parallel
session) are **not** in the Dev 13 ZIP. Shipping them needs a new export from that commit and a fresh browser check.

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
4. Description: controls line — `1`–`7` pick a defender (7 = Camel Claus) · click to place/select/collect tickets · upgrades in the sidebar when a defender is selected · hover tickets to collect · `Q`/`E` hero abilities · `T` target · `Space` start round ·
   `P` pause · `F` speed 1×/2×/4× · `Esc`/right-click cancel. Genre: Strategy; tags: tower-defense, winter, christmas.
5. Visibility: **Draft** (or Restricted) → **Save** → open the page in a private window: game loads, round 1 plays,
   F12 console has 0 errors.
6. Before the deadline (Sun Nov 15, 10:00 AM, `docs/HACKATHON.md`): set **Public**, copy the URL into the submission
   and onto the studio website.

## Updating an existing page

Uploads → delete or hide the old ZIP → add the new ZIP → tick *played in the browser* again → Save → recheck step 5.
(itch keeps the embed settings.) Optional later: `butler push build/web <user>/claus-for-alarm:html5`.
