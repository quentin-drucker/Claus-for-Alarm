# Remodeled Rookie menu showcase

Owner-requested menu-only use of `art_src/models/snowball_rookie/snowball_rookie_rigged.fbx`.
`art_src/tools/prepare_menu_rookie.py` runs in background Blender, bakes the supplied pose into one static mesh,
normalizes its height/facing and exports `assets/models/menu/rookie_showcase.glb` and `rookie_menu.blend`.
The original FBX is untouched. There are no skeletal animation clips in this export.

`scenes/ui/rookie_showcase.gd` renders this in its own transparent viewport with gentle bob, yaw and tilt.
It hides behind help/settings and in narrow windows; browser reduced-motion preference stops its motion.
The old in-game Rookie GLB/profile and the deferred gameplay replacement remain unchanged.

Maps are 1024 px PNG, mipmapped, desktop VRAM-compressed. Verify `path.s3tc` and `vram_texture: true`
in their import records after rebuilding. This session forced stale texture imports to rebuild by adding a
PNG text metadata chunk (pixels unchanged), without editing generated Godot cache files.

Review evidence: `docs/logs/evidence/menu_rookie_web.png`.
