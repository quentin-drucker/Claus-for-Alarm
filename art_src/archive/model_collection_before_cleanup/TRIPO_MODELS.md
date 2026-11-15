# Tripo model exports

Eight exports moved from Downloads into the existing model folders. Export folders and FBXs use the game's names. All 48 source files were verified by SHA-256 after the move and rename.

| Model folder | Character / tower | FBX |
| --- | --- | --- |
| Model0 | Camel Claus | [camel_claus_tripo.fbx](Model0/camel_claus_tripo/camel_claus_tripo.fbx) |
| Model2 | Avalanche Cannon | [avalanche_cannon_tripo.fbx](Model2/avalanche_cannon_tripo/avalanche_cannon_tripo.fbx) |
| Model3 | Biathlon Ranger | [biathlon_ranger_tripo.fbx](Model3/biathlon_ranger_tripo/biathlon_ranger_tripo.fbx) |
| Model4 | Slope Wax Sprayer | [slope_wax_sprayer_tripo.fbx](Model4/slope_wax_sprayer_tripo/slope_wax_sprayer_tripo.fbx) |
| Model5 | Snow Sorcerer | [snow_sorcerer_tripo.fbx](Model5/snow_sorcerer_tripo/snow_sorcerer_tripo.fbx) |
| Model6 | Ski Resort Ticket Booth | [ski_resort_ticket_booth_tripo.fbx](Model6/ski_resort_ticket_booth_tripo/ski_resort_ticket_booth_tripo.fbx) |
| Model7 | Hockey Slapper | [hockey_slapper_tripo.fbx](Model7/hockey_slapper_tripo/hockey_slapper_tripo.fbx) |
| Model8 | Snowboard Trickster | [snowboard_trickster_tripo.fbx](Model8/snowboard_trickster_tripo/snowboard_trickster_tripo.fbx) |

Each export includes five JPEG maps: base color, metallic, normal, packed RM, and roughness. Internal `.fbm` directories and texture filenames retain their original names to preserve the export's texture references. FBX contents were not modified or re-exported. This operation verifies file integrity, not rendering, texture resolution in a DCC, or rigging quality.

Model1's existing AccuRIG export is separate and unchanged. Model9 (Winter Games Lodge) and Model10 (Track Gritter) remain deferred.

These are source assets under `art_src/.gdignore`; collecting them does not add them to runtime scenes or change the release roster.

Original folder/FBX names and source-file hashes are recorded in [the import manifest](TRIPO_IMPORT_MANIFEST.json).
