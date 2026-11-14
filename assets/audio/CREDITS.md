# Audio provenance ledger (DEC-035, P18-T02/T10)

Every audio file shipped in the game, where it came from, and its license. Add a row before adding a file.
No BTD6 (or any other game's) samples, melodies or recordings.

## SFX — original, code-synthesized

Generator: `scripts/audio/sfx_synth.gd` (sine/triangle tones, filtered noise, exponential envelopes; no samples).
Author: team Camel Claus. License: original work, owned by the team. Rebuild:
`godot --headless --path . -s res://scripts/audio/sfx_synth.gd` (deterministic seed 20261114).
Format: 16-bit mono WAV, 22050 Hz, peak-normalized to 0.8; loudness set per sound in `scripts/audio/audio_router.gd`.

| File (`sfx/`) | Event (HYB-M M-02) | Recipe |
|---|---|---|
| `pop_1`..`pop_5.wav` | `layer_broken` Powder, Blue, Mint, Violet, Coral (camo variants share) | low-passed noise crump + short sine thump; lower/fuller per depth |
| `pop_heavy.wav` | `layer_broken` Black / White / Purple | longer noise crumble + two grit bursts + low thump |
| `immune.wav` | `enemy_immune` | two inharmonic sine partials (1.76/2.69 kHz), fast decay |
| `leak.wav` | `enemy_leaked` | triangle C5 → G4 warning, no pitch randomization |
| `place.wav` | `tower_placed` | sine thump 150→60 Hz + soft noise |
| `upgrade.wav` | `tower_upgraded` | bell arpeggio C5-E5-G5 |
| `sell.wav` | `tower_sold` | bells G5 → D5 |
| `cannon.wav` | `attack_fired` avalanche_cannon_* | rising low "woom" then noise blast + thump |
| `ranger.wav` | `attack_fired` biathlon_ranger_* | high-passed noise snap + short tone |
| `throw.wav` | `attack_fired` snowball_rookie_* | rising filtered-noise whoosh |
| `wax.wav` | `status_applied` slope_wax_sprayer_* | low-passed noise + falling sine splat |
| `chime.wav` | `attack_fired` snow_sorcerer_* | noise swish + C6/E6 bells |
| `ticket.wav` | `income_collected` | noise flick + G6/C7 bells |
| `hero_shot.wav` | `attack_fired` camel_claus_* | triangle pluck 340→170 Hz + click |
| `frenzy.wav` | `ability_used` snowball_frenzy | noise swell + G4-C5-E5-G5 ascent |
| `focus.wav` | `ability_used` focused_shot | two noise clicks + tone |
| `level_up.wav` | `hero_level_up` | bells D5 → A5 |
| `click.wav` | any Button pressed | tiny sine tap + noise |
| `deny.wav` | `purchase_failed` | triangle B♭3 → G3 |
| `round_start.wav` | `round_started` | bells G4 → C5 |
| `round_complete.wav` | `round_complete` | bells C5-E5-G5(+C6) |
| `../sfx_smoke_blip.wav` | P01 Web unlock smoke test only (not used in game) | Python-synthesized blip, original |

## Music — slots (`music/`)

Drop files named `menu`, `gameplay`, `victory`, `defeat` (`.ogg` preferred, `.mp3` works; WAV not supported for
looping). Menu and gameplay loop; victory/defeat play once. Fill one row per file when it lands.

| File | Source (tool / site) | Author | License / terms | Date | Notes |
|---|---|---|---|---|---|
| — | | | | | |
