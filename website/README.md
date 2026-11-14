# Camel Claus studio website

Static site (no build step). Open `index.html` locally, or serve with `python -m http.server -d website`.

- **itch.io link:** edit `ITCH_URL` at the top of `config.js`.
- **Screenshots:** see `img/README.md`.
- **Team names and credits:** the `#team` section of `index.html`.

## Publish (GitHub Pages, `gh-pages` branch)

Pages serves the `gh-pages` branch, which holds only this folder. After committing changes on `main`:

```bash
git push origin `git subtree split --prefix website main`:refs/heads/gh-pages --force
```

Live at https://quentin-drucker.github.io/Claus-for-Alarm/ about a minute later.
