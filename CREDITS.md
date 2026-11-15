# Claus for Alarm — credits

## Main-menu environment

Public credit placement (owner decision, 2026-11-15): the **game website's credits**, together with the other contributors; no credit overlay on the main menu. This file preserves attribution with the project. Website publishing handoff: `website/README.md`.

**Christmas Low-poly Scene** by **[lumoize](https://sketchfab.com/lumoize)**.

- Original model: https://sketchfab.com/3d-models/christmas-low-poly-scene-7984bd6024db4b89928ddeb625eebac0
- License: **[Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)**.
- Author/license verified against the model's public Sketchfab API record on 2026-11-15; snapshot: `art_src/environment/christmas_village/source_attribution.json`.
- Adaptations for this game: FBX converted to GLB, scene rescaled/recentered around the tree, static geometry batched with source smooth shading preserved, material roughness/emission adjusted, rink given a clearer blue tint, source object motion baked to a looping timeline, and a wide-angle orbit camera/lighting, winter sky, distance fog and snow horizon added in Godot. Material animation unsupported by Blender's FBX importer is represented with steady emissive lights.
- The author is credited for the original environment; these game-specific adaptations are by the Claus for Alarm project. No endorsement is implied.

## Temporary browser startup artwork

The "Knit + Tin" sweater/Fair Isle textures, Santa hat and camel splash artwork are reused at the owner's request from their pre-hackathon **Camel Claus The North Pole** test project. Adapted here with the title **Claus for Alarm**, browser animation and actual download progress. Source provenance: `art_src/ui/startup/provenance.json`. These are reused test-project assets, not newly created for this game.

The original copied splash used **Bowlby One** by Vernon Adams; its source/license remain in `art_src/ui/startup/`. The current game and splash use the typography below.

## Game and loading-screen fonts

- **Grenze Gotisch**: The Grenze Gotisch Project Authors (https://github.com/Omnibus-Type/Grenze-Gotisch), titles and announcements.
- **New Rocker**: Pablo Impallari, Brenda Gallo and Rodrigo Fuenzalida, main interface text.
- **Barlow**: The Barlow Project Authors (https://github.com/jpt/barlow), compact information and numbers.

All three are under SIL OFL 1.1. Full notices are retained in `assets/fonts/OFL_*.txt` and embedded in the distributed Web shell. Reused from the owner's earlier project; source hashes and format-conversion notes: `assets/fonts/provenance.json` and `README.md`. Add these font credits to the website alongside the other contributors; no main-menu credit overlay.

## Audio

Music, sound effects and ambience by **Willosuna**. The detailed asset/license ledger is [assets/audio/CREDITS.md](assets/audio/CREDITS.md).

## Engine and other assets

Built with **Godot Engine**. Tower source models supplied by the project owner were generated with Tripo AI; the Rookie source rig was prepared in AccuRIG. Per-asset preparation/provenance is recorded under `art_src/models/` and in the development log.
