# Main-menu Christmas village

Original: **Christmas Low-poly Scene**, **lumoize**, Sketchfab.
https://sketchfab.com/3d-models/christmas-low-poly-scene-7984bd6024db4b89928ddeb625eebac0

License: **CC BY 4.0**, https://creativecommons.org/licenses/by/4.0/.
Public API attribution snapshot and original source SHA-256: `source_attribution.json`.

`christmas_low_poly_scene.fbx` is a byte-verified copy of the owner's downloaded FBX. The download is preserved. No companion texture files were supplied or required; the FBX uses solid-color materials.

Rebuild with Blender:

```text
blender --background --factory-startup --python art_src/tools/prepare_menu_village.py
```

Outputs: `art_src/prepared/christmas_village.blend`, `assets/models/menu/christmas_village.glb` and its preparation report.

Derived changes: normalize scale by 100, recenter using the central tree's mesh bounds rather than its offset pivot, combine static geometry, retain animated-object hierarchies, bake frames 2–490 at 24 fps into one concurrent animation. Smoke motion remains from the source. FBX material animation is not supported by Blender's importer, so lights use steady emission rather than claiming the original animated material behavior survived.

The title-screen background has its own SubViewport/world. `scenes/ui/menu_background.gd` adds lights and a perspective camera orbiting tree XZ (0, 0); FOV, radius, height and speed are exposed. Buttons are normal 2D controls above it. Menu art never enters the match scene.

Full attribution is in root `CREDITS.md`. Owner decision (2026-11-15): public attribution belongs in the game website's credits alongside all other contributors, with no main-menu credit overlay. Copy-ready credit and publishing TODO: `website/README.md`.

Owner lighting revision (2026-11-15): batching preserves the source polygons' smooth/flat shading. Only the ice sheet gets a separate `RinkIce` material (linear base RGB 0.22/0.55/0.70, roughness 0.55, metallic 0.22); house glass retains its original shared material. Godot menu lighting uses sun 0.7 / ambient 0.35 and linear tonemapping. Orbit height is 6.5 m, with the existing 72-degree lens. A procedural winter sky, depth fog from 16 to 44 m and a snow plane at y=-0.65 m extend the horizon. These are derived/runtime adaptations; the source FBX is unchanged.
