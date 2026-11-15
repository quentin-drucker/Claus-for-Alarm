# Web startup shell

`shell.html` is generated from `startup_shell.template.html` and `art_src/ui/startup/` by:

```text
python art_src/tools/generate_startup_shell.py
```

The release Web export preset uses this shell automatically. Export the game again after changing it; existing archive ZIPs and old local servers do not acquire the loader automatically. Upload all files from the resulting export together.

The sweater animation displays while the engine/pack download and the menu prepares. The title scene calls `window.clausMenuReady()` after its first drawn frame. The loader then waits for its fonts and holds for four seconds before fading, at the owner's request so cached loads do not cut off the title/hat reveal. Returning to the menu does not replay the loader. CSS animation may still pause during browser main-thread stalls; this is loading presentation, not a fix for first-use rendering costs.

Owner-requested temporary reuse from the pre-hackathon **Camel Claus The North Pole** project. See `art_src/ui/startup/README.md`, `provenance.json` and root `CREDITS.md` for asset/font provenance. No old game's Profile/Transition autoloads or gameplay code are imported.
