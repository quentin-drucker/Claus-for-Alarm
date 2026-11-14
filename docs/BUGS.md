# Claus for Alarm — Bug list (P14-T03)

Severity: **blocker** (cannot finish / wrong game state), **high** (misleads the player or breaks a rule),
**medium** (noticeable, workaround exists), **low** (cosmetic / polish). Fixed items keep their commit.

## Technical alpha (2026-11-14, Web build `claus_for_alarm_alpha_web_619af86.zip`)

| ID | Sev | Status | What | Evidence / note |
|---|---|---|---|---|
| BUG-001 | high | FIXED `619af86` | How to Play arrows (`→`) rendered as empty boxes on Web: the default font has no arrow glyph (desktop fell back to a system font) | `p14_web_how_to_play.png`; replaced with `>`. Remaining `→` only in data notes, never shown |
| BUG-002 | medium | OPEN (by design for now) | At 4× in late rounds most per-hit `*` markers are skipped (cap 30 on screen); IMMUNE/leak/income text has its own cap of 60 | Caps visuals only; combat unaffected (`feedback_layer.gd`) |
| BUG-003 | low | OPEN | Below ~20 FPS at 4× the clock hits its 12-steps-per-frame cap and the game runs slower than 4× (never skips or changes events) | `SimClock.MAX_STEPS_PER_FRAME`; raise if Web profiling shows headroom |
| BUG-004 | low | OPEN | Camel Claus reaches level 6 only as round 25 is won, so the double shot never fights in a normal match | DEC-030 Endless makes it matter; no change |
| BUG-005 | low | OPEN | White's cold immunity has no effect: no shipped attack deals cold | Correct per source; matters once a cold attack ships |
| BUG-006 | low | OPEN | Black/White use the same 0.4 m hit radius as other layers (smaller in BTD6) | `IMPLEMENTATION_ASSUMPTIONS.md` |
| BUG-007 | medium | OPEN (P13-T07/T08/T09) | Not yet checked: fullscreen toggle, narrow browser window, colour-independent valid/invalid symbols beyond text | P13 leftovers, not in this session's scope |
| BUG-008 | low | OPEN (tooling) | Another local process can hold port 8000, so `http.server 8000` may serve an old build | Use a free port (8010 used for this test) |

No blockers found: 9/9 test suites pass, Web export 0 errors/warnings, browser rounds 1–5 by mouse/keyboard with
0 console errors (`p14_web_console.log`), all four bot plans win round 25.

## Fresh-player test

(Owner fills this in from `docs/FRESH_PLAYER_TEST.md`.)
