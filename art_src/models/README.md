# Active source models

One named folder and one FBX per model. Texture directories retain their exported relative names so dependencies stay together. `art_src/.gdignore` excludes source assets from runtime imports.

| Model | Active FBX |
| --- | --- |
| Snowball Rookie | [Rigged final](snowball_rookie/snowball_rookie_rigged.fbx) |
| Camel Claus | [FBX](camel_claus/camel_claus.fbx) |
| Avalanche Cannon | [FBX](avalanche_cannon/avalanche_cannon.fbx) |
| Biathlon Ranger | [FBX](biathlon_ranger/biathlon_ranger.fbx) |
| Slope Wax Sprayer | [FBX](slope_wax_sprayer/slope_wax_sprayer.fbx) |
| Snow Sorcerer | [FBX](snow_sorcerer/snow_sorcerer.fbx) |
| Ski Resort Ticket Booth | [FBX](ski_resort_ticket_booth/ski_resort_ticket_booth.fbx) |
| Hockey Slapper | [FBX](hockey_slapper/hockey_slapper.fbx) |
| Snowboard Trickster | [FBX](snowboard_trickster/snowboard_trickster.fbx) |

Reference images are collected in `references/`. Older Rookie FBXs/GLB and historical manifests are retained in `../archive/model_collection_before_cleanup/`; those old manifests describe the pre-cleanup paths and are not the current model index.

Use the existing AccuRIG Rookie as the authoritative Rookie model. No additional rigging or complex per-character animation is required for the current time-limited build. Other models use simple shared whole-object activity animation when implemented. See [deferred work](../../docs/DEFERRED_WORK.md).

All 79 original files were preserved and hash-verified during reorganization. No FBX contents or textures were re-exported. Runtime integration and visual/rig validation are separate tasks.
