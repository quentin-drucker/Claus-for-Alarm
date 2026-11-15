# Knit + Tin startup assets

Startup artwork for **Claus for Alarm**. `provenance.json` records asset filenames and hashes.

The splash combines red knit/Fair Isle textures, a chunky logo, knitting needles, a riveted subtitle plate, a camel mascot, a Santa hat and rolling yarn. The animation runs in the **browser loading shell**, available before Godot starts, with the **Claus for Alarm** title.

- Editable layout/animation: `web/startup_shell.template.html`.
- Rebuild: `python art_src/tools/generate_startup_shell.py` -> self-contained `web/shell.html`.
- Web preset uses `html/custom_html_shell`; all art/fonts are embedded (no external font/CDN requests).
- Download scarf uses actual byte progress; engine/menu preparation uses a status message. Download progress stays real; owner follow-up adds a four-second hold after the menu and fonts are ready so the title/hat reveal can finish. This does not eliminate shader stalls.
- `title_screen.gd` signals the shell after `RenderingServer.frame_post_draw`; the overlay holds for four seconds after menu/font readiness, then fades to the existing village menu. Native/editor startup stays on the title scene.
- Reduced motion stops CSS animation; load errors show a retry control.
- Play now clones the same overlay before map loading. A persistent `scripts/ui/map_loading.gd` loads the map resource,
  replaces the scene and signals the shell after the first map draw. Minimum reveal time is 2.7 seconds from showing
  the map overlay, followed by the existing fade; slower loads keep it up longer. This is a preparation indicator,
  not a fake download percentage. Native Play uses a simple title/status fallback; the sweater art is Web-only.

Font credits: Bowlby One by Vernon Adams; New Rocker by Pablo Impallari, Brenda Gallo and Rodrigo Fuenzalida. Their original licenses remain here. Owner's later typography pass replaces the displayed title/subtitle with Grenze Gotisch, body text with New Rocker and small details with Barlow, using `assets/fonts/`. The generator embeds all three current fonts and their full OFL notices.
