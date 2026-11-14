# Audio provenance ledger (DEC-036, P18-T02/T10)

Every audio file shipped in the game, where it came from, and its license. Add a row before adding a file.
No BTD6 (or any other game's) samples, melodies or recordings; BTD6 informed the *style* only (HYB-A A-10, REF-A V-11).

## Source: Willosuna (all SFX and music)

Author: **Willosuna** — https://willosuna.itch.io/ (downloaded 2026-11-14, free "Lite"/demo editions).
License (identical in every pack's `LICENSE.txt`): royalty free for personal and commercial games; editing allowed;
**attribution not required** (we credit anyway); **not allowed:** reselling or sharing the audio files themselves as a
pack / sound library, or registering them with Content ID. Author states the packs are made without AI.

| Pack (itch.io page) | Used for |
|---|---|
| Christmas SFX Lite v2 — `willosuna.itch.io/christmas-sfx-lite` | crunch_heavy, immune, place, place_hero, upgrade, sell, ticket, level_up, round_start, round_complete, chime |
| Cozy UI SFX Lite v2 — `willosuna.itch.io/cozy-ui-sfx-lite` | crunch (12 snow-crunch variants), leak, deny, focus_on, focus_off, click, hover |
| Combat SFX Lite — `willosuna.itch.io/pixel-combat-sfx-lite` | cannon_fire, ranger, hero_shot |
| Magic Spells SFX Lite v2.1 — `willosuna.itch.io/magic-spells-sfx-lite` | fireball, frenzy, ability_ready |
| Game & UI Sound Effects (Free) — `willosuna.itch.io/free-game-ui-sound-pack` | throw, cannon_boom, wax |
| Card Game SFX Lite v2 — `willosuna.itch.io/card-game-sfx-lite` | ticket_bank, ticket_spawn |
| Christmas Music Pack (free demo) v2 — `willosuna.itch.io/christmas-music-pack` | all music |

### SFX (`sfx/`) — built by `scripts/audio/build_sfx.py`

Processing: leading silence trimmed, long tails shortened with a fade where noted, levelled to −20 dBFS active RMS,
peak ≤ −1 dBFS, mono 44.1 kHz OGG Vorbis. Pitch/variant/level variation happens at runtime in
`scripts/audio/audio_router.gd`.

| File | Source file (pack) | Event (HYB-M M-02) |
|---|---|---|
| `crunch_01..12.ogg` | `snow_crunch_01..12.wav` (Cozy UI) | `layer_broken` Powder…Coral (pitched per layer) |
| `crunch_heavy.ogg` | `snowball_hit_01.wav` (Christmas) | `layer_broken` Black / White / Purple |
| `immune.ogg` | `ornament_clink_01.wav` (Christmas) | `enemy_immune` |
| `leak.ogg` | `alert_01.wav` (Cozy UI) | `enemy_leaked` |
| `throw.ogg` | `throw.wav` (Game & UI) | `attack_fired` Snowball Rookie |
| `cannon_fire.ogg` | `smoke_puff_01.wav` (Combat), cut 0.45 s | `attack_fired` Avalanche Cannon |
| `cannon_boom.ogg` | `explosion_small.wav` (Game & UI) | `enemy_hit` from a Cannon |
| `ranger.ogg` | `muzzle_flash_01.wav` (Combat), cut 0.4 s | `attack_fired` Biathlon Ranger |
| `chime.ogg` | `celesta_magic_01.wav` (Christmas), cut 0.7 s | `attack_fired` Snow Sorcerer |
| `fireball.ogg` | `fire_cast_01.wav` (Magic), cut 0.8 s | `attack_fired` Sorcerer fireball |
| `wax.ogg` | `splash.wav` (Game & UI) | `status_applied` Slope Wax Sprayer |
| `hero_shot.ogg` | `punch_whoosh_01.wav` (Combat) | `attack_fired` Camel Claus |
| `place.ogg` | `elf_poof_01.wav` (Christmas) | `tower_placed` |
| `place_hero.ogg` | `tree_star_01.wav` (Christmas), cut 1.2 s | `tower_placed` Camel Claus |
| `upgrade.ogg` | `unlock_01.wav` (Christmas) | `tower_upgraded` |
| `sell.ogg` | `coin_01.wav` (Christmas) | `tower_sold` |
| `deny.ogg` | `deny_01.wav` (Cozy UI) | `purchase_failed` |
| `ticket.ogg` | `jingle_collect_01.wav` (Christmas) | `income_collected` |
| `ticket_bank.ogg` | `chip_single_01.wav` (Card Game) | `income_banked` |
| `ticket_spawn.ogg` | `card_deal_01.wav` (Card Game) | `pickup_spawned` |
| `frenzy.ogg` | `arcane_blast_01.wav` (Magic) | `ability_used` Snowball Frenzy |
| `focus_on.ogg` / `focus_off.ogg` | `scan_01.wav` / `toggle_off_01.wav` (Cozy UI) | `ability_used` Focused Shot on/off |
| `level_up.ogg` | `levelup_01.wav` (Christmas) | `hero_level_up` |
| `ability_ready.ogg` | `spell_ready_01.wav` (Magic) | `ability_ready` |
| `round_start.ogg` | `sleigh_bells_jingle_01.wav` (Christmas) | `round_started` |
| `round_complete.ogg` | `reward_01.wav` (Christmas) | `round_complete` |
| `click.ogg` / `hover.ogg` | `click_01.wav` / `hover_01.wav` (Cozy UI) | any Button pressed / hovered |

### Music (`music/`) — the composer's OGG files, unchanged

| File | Source track (Christmas Music Pack demo) | Use |
|---|---|---|
| `menu.ogg` | `we_wish_you_menu_loop` — "We Wish You a Merry Menu", F major, 138 BPM, seamless | title screen |
| `gameplay.ogg` | `town_snowy_village_loop` — "Snowy Village", G major, 104 BPM, seamless | rounds 1–15 |
| `gameplay_late.ogg` | `god_rest_ye_sleigh_chase_loop` — sleigh chase, 168 BPM, seamless | rounds 16+ (escalation) |
| `victory.ogg` | `victory` jingle | match won |
| `defeat.ogg` | `game_over` jingle | match lost |

Carol melodies in the music are public domain (per the pack README); the arrangements/recordings are Willosuna's.

## Other files

| File | Source | License |
|---|---|---|
| `sfx_smoke_blip.wav` | P01 Web-unlock smoke test (not used in game); Python-synthesized by the team | original work |

## Submission credit line (hackathon form)

Sound effects and music: Willosuna (willosuna.itch.io) — Christmas SFX, Cozy UI SFX, Combat SFX, Magic Spells SFX,
Game & UI SFX, Card Game SFX and Christmas Music Pack (free editions), used under the Willosuna royalty-free license.
