"""P18: build the game's SFX/music/ambience from the licensed Willosuna packs (DEC-037/038).

Not run by Godot. Usage (Python 3.10+ with numpy + soundfile):
    python scripts/audio/build_sfx.py <dir with the unzipped Willosuna packs> assets/audio

Each slot below names the source file(s) inside the packs; several sources become variants
`<slot>_01.ogg, _02...` that the router picks from at random. Every file is trimmed (leading
silence), optionally shortened with a fade, loudness-levelled to the same active RMS, peak-limited
and written as mono 44.1 kHz OGG Vorbis. Provenance per slot: assets/audio/CREDITS.md.
"""
import glob
import os
import shutil
import sys

import numpy as np
import soundfile as sf

RMS_TARGET_DB = -20.0
PEAK_CEILING_DB = -1.0

# slot: (source basenames (variants), max seconds or None)
SFX = {
    # Snowball layers (frequent): 12 recorded snow crunches, pitched per layer depth by the router.
    "crunch": ([f"snow_crunch_{i:02d}.wav" for i in range(1, 13)], 0.25),
    # Black / White / Aurora shells: a packed snowball hit + 4 fast-attack ice breaks.
    "crunch_heavy": (["snowball_hit_01.wav"] + [f"ice_break_{i:02d}.wav" for i in (1, 2, 6, 10)], 0.4),
    "immune": (["ornament_clink_01.wav"], None),
    "leak": (["alert_01.wav@cozy"], None),
    # Attacks
    "throw": (["throw.wav"], None),                    # Snowball Rookie
    "cannon_fire": (["smoke_puff_01.wav"], 0.45),      # Avalanche Cannon launch
    "cannon_boom": (["explosion_small.wav"], None),    # ... and its blast on impact
    "ranger": (["muzzle_flash_01.wav"], 0.4),          # Biathlon Ranger
    "chime": (["celesta_magic_01.wav"], 0.7),          # Snow Sorcerer
    "fireball": (["fire_cast_01.wav"], 0.8),           # Snow Sorcerer fireball path
    "wax": (["splash.wav"], None),                     # Slope Wax Sprayer: slow landed
    "hero_shot": (["punch_whoosh_01.wav"], None),      # Camel Claus
    # Towers and economy
    "place": (["elf_poof_01.wav"], None),
    "place_hero": (["tree_star_01.wav"], 1.2),
    "upgrade": (["unlock_01.wav@christmas"], None),
    "sell": (["coin_01.wav@christmas"], None),
    "deny": (["deny_01.wav@cozy"], None),
    "ticket": (["jingle_collect_01.wav"], None),       # income collected
    "ticket_bank": (["chip_single_01.wav"], None),     # income banked in the booth
    "ticket_spawn": (["card_deal_01.wav"], None),      # a ticket pops out on the course
    # Hero
    "frenzy": (["arcane_blast_01.wav"], None),
    "focus_on": (["scan_01.wav@cozy"], None),
    "focus_off": (["toggle_off_01.wav@cozy"], None),
    "level_up": (["levelup_01.wav@christmas"], None),
    "ability_ready": (["spell_ready_01.wav"], None),
    # Rounds
    "round_start": (["sleigh_bells_jingle_01.wav"], None),
    "round_complete": (["reward_01.wav@christmas"], None),
    # UI
    "click": (["click_01.wav@cozy"], None),
    "hover": (["hover_01.wav@cozy"], None),
}
# Music: the composer's own OGG files copied unchanged (mastered to -16 LUFS, seamless loops). slot: source.
MUSIC = {
    "menu": "we_wish_you_menu_loop.ogg@music",
    "gameplay": "god_rest_ye_sleigh_chase_loop.ogg@music",  # 168 BPM, all rounds
    "victory": "victory.ogg@music",
    "defeat": "game_over.ogg@music",
}
# Ambience beds: the author's seamless loops copied unchanged. The two market loops are sample aligned
# (calm -> intense crossfade for late waves). slot: source.
AMBIENCE = {
    "wind": "wind_light_loop_01.ogg",
    "market_calm": "winter_market_calm.ogg",
    "market_intense": "winter_market_intense.ogg",
}
# "@pack" picks a file when several packs share a basename.
PACK_HINT = {"cozy": "cozy-ui-sfx-lite", "christmas": "christmas-sfx-lite", "music": "christmas-music-pack"}


def find(src_root: str, name: str) -> str:
    base, _, hint = name.partition("@")
    hits = [p for p in glob.glob(os.path.join(src_root, "**", base), recursive=True)
            if os.sep + "godot" + os.sep not in p and os.sep + "unity" + os.sep not in p]
    if hint:
        hits = [p for p in hits if PACK_HINT[hint] in p]
    if len(hits) != 1:
        sys.exit(f"source {name}: expected 1 match, got {hits}")
    return hits[0]


def process(path: str, max_s: float | None) -> np.ndarray:
    x, sr = sf.read(path, always_2d=True)
    assert sr == 44100, (path, sr)
    m = x.mean(1)
    peak = np.abs(m).max()
    start = max(0, int(np.argmax(np.abs(m) > peak * 0.01)) - int(0.002 * sr))
    m = m[start:]
    if max_s and len(m) > max_s * sr:
        m = m[: int(max_s * sr)]
        fade = int(0.08 * sr)
        m[-fade:] *= np.linspace(1.0, 0.0, fade)
    fade = int(0.008 * sr)
    m[-fade:] *= np.linspace(1.0, 0.0, fade)
    active = m[np.abs(m) > np.abs(m).max() * 0.05]
    rms = np.sqrt(np.mean(active ** 2))
    m *= 10 ** (RMS_TARGET_DB / 20) / rms
    ceiling = 10 ** (PEAK_CEILING_DB / 20)
    if np.abs(m).max() > ceiling:  # loud transient: scale down rather than clip
        m *= ceiling / np.abs(m).max()
    return m


def main() -> None:
    src_root, out_root = sys.argv[1], sys.argv[2]
    sfx_dir, music_dir = os.path.join(out_root, "sfx"), os.path.join(out_root, "music")
    ambience_dir = os.path.join(out_root, "ambience")
    for d in (sfx_dir, music_dir, ambience_dir):
        os.makedirs(d, exist_ok=True)
    for slot, (sources, max_s) in SFX.items():
        for i, name in enumerate(sources):
            out = os.path.join(sfx_dir, f"{slot}_{i + 1:02d}.ogg" if len(sources) > 1 else f"{slot}.ogg")
            sf.write(out, process(find(src_root, name), max_s), 44100, format="OGG", subtype="VORBIS")
            print(slot, "<-", name)
    for slot, name in MUSIC.items():
        shutil.copyfile(find(src_root, name), os.path.join(music_dir, slot + ".ogg"))
        print("music", slot, "<-", name)
    for slot, name in AMBIENCE.items():
        shutil.copyfile(find(src_root, name), os.path.join(ambience_dir, slot + ".ogg"))
        print("ambience", slot, "<-", name)


if __name__ == "__main__":
    main()
