# Camel Claus studio website

Static site (no build step). Open `index.html` locally, or serve with `python -m http.server -d website`.

- **itch.io link:** edit `ITCH_URL` at the top of `config.js`.
- **Screenshots:** see `img/README.md`.
- **Team names and credits:** the `#team` section of `index.html`.

## Environment credit to add before release

Owner decision (2026-11-15): credit the main-menu environment here on the game website, alongside the other contributors, **not on the game's main menu**. The site credits still contain placeholders; this is a publication TODO, not a claim that the live site is updated.

Use this credit in `index.html`'s `#team` credits list:

> Main-menu environment: [Christmas Low-poly Scene](https://sketchfab.com/3d-models/christmas-low-poly-scene-7984bd6024db4b89928ddeb625eebac0) by [lumoize](https://sketchfab.com/lumoize), licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Adapted for Claus for Alarm: rescaled, static geometry batched, materials adjusted, source object animation baked, and orbit camera, lighting, sky and fog added. Original material animation is represented by steady emissive lights.

Full attribution/adaptation notes: root `CREDITS.md`. Source metadata and original file hash: `art_src/environment/christmas_village/source_attribution.json`. Keep this credit when updating the site for submission.

## Publish (GitHub Pages, `gh-pages` branch)

Pages serves the `gh-pages` branch, which holds only this folder. After committing changes on `main`:

```bash
git push origin `git subtree split --prefix website main`:refs/heads/gh-pages --force
```

Live at https://quentin-drucker.github.io/Claus-for-Alarm/ about a minute later.
