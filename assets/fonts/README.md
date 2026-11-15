# Game typography

Owner-selected fonts for Claus for Alarm (2026-11-15):

| Font | Role |
| --- | --- |
| Grenze Gotisch, weight 700 | Game title, subtitles, panel headings, round/ability announcements, special-enemy headings, pause/results titles |
| New Rocker Regular | Default body text, menu/action buttons, tower-card names, upgrade buttons, hover descriptions, help/settings and loading status |
| Barlow Medium | Compact prices, counters, dense statistics, keyboard hints, debug text, floating values and small world labels |

The shared theme is `scripts/ui/lodge_theme.gd`; the project default font also covers controls outside that theme.
The browser shell embeds these same fonts and their complete licenses; no remote font service is used at runtime.

`provenance.json` records old-project source paths and original hashes. New Rocker's TTF is copied unchanged.
Grenze Gotisch and Barlow came from the old prototype's WOFF2 files, decoded to TTF using fontTools + Brotli.
Despite its filename, the old Grenze 700 WOFF2 was variable: its `wght` axis was instantiated at 700 with
`fontTools.varLib.instancer.instantiateVariableFont` before saving. Barlow is the static 500/Medium face.
Original sibling files remain unchanged.

SIL OFL 1.1 notices are included beside the fonts. Grenze Gotisch: The Grenze Gotisch Project Authors;
Barlow: The Barlow Project Authors; New Rocker: Pablo Impallari, Brenda Gallo and Rodrigo Fuenzalida.
The two prototype license copies were retrieved from the Google Fonts repository:
https://raw.githubusercontent.com/google/fonts/main/ofl/grenzegotisch/OFL.txt
https://raw.githubusercontent.com/google/fonts/main/ofl/barlow/OFL.txt
