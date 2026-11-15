# Camel Claus studio website

Static site; no build step or dependencies. Open `index.html` directly, or run:

```powershell
python -m http.server 8156 --bind 127.0.0.1 --directory website
```

Then open http://127.0.0.1:8156/ .

The existing public URL is https://quentin-drucker.github.io/Claus-for-Alarm/ . The November 15 refresh is currently local; it has not been published by the website editing session.

- `index.html`: game presentation, creator credit, process, asset attribution.
- `style.css`: responsive winter-lodge design. New Rocker and Barlow are bundled with licenses in `fonts/`.
- `config.js`: shared itch.io URL and progressive image-viewer enhancement. Keep the three HTML fallback links synchronized if the URL changes.
- `img/`: original captures, reference sheets, and runtime portraits copied without editing. Source mapping: `img/README.md`.
- `process/`: public copies of the four design documents, two prompt archives, and credit ledgers. Planning documents retain historical and deferred work, explicitly labeled on the page. Workstation root paths are removed from public copies.
- `REVIEW.md`: assessment, verification, and final polish priorities.

## Design direction

Use the game's own visual language: spruce noticeboard, snow background, festive red controls, New Rocker display type, and a menu screenshot treated as a winter-games lift pass. Keep body text plain and readable. Process numbering denotes the actual sequence; document numbering matches the real files. Avoid unrelated stock art or invented gameplay imagery.

## Credits

The site credits Quentin Drucker as solo creator, including game design, AI-assisted development, 3D asset creation, rigging, animation, and audio integration. AccuRig source preparation is distinguished from the deferred runtime replacement. Main-menu environment attribution to lumoize (CC BY 4.0) is in the credits section; retain the adaptation notes. The shipped audio ledger credits Willosuna. Only add Pixabay attribution when an actual asset and its source are identified.

## Publishing

Pages currently serves the `gh-pages` branch, containing this folder only. The repository's established workflow is to commit the reviewed website changes to `main`, then publish the subtree. Do not stage unrelated game work. Do not run the publication command until the final website is intended to go live.

```powershell
$websiteCommit = git subtree split --prefix website main
git push origin "${websiteCommit}:refs/heads/gh-pages" --force-with-lease
```

After publication, verify the public website in a private browser window. Updating the build on the same itch.io project uses the same play link; changing the itch.io project slug would require updating the site's links.
