# Claus for Alarm — Hackathon brief

**Event:** Camel Code Jam — Holiday Edition, Connecticut College, Nov 13–15, 2026.
Organizer contact: gwc@conncoll.edu. Submission via the Camel Code Jam submission form.

## Themes

- **Main theme:** Holidays / Christmas at Connecticut College.
- **Secret sub-theme:** **Winter Sports** (revealed Fri Nov 13, 7:30 PM).

Every major design choice (towers, enemies, map, art, audio) should read as festive *and* tie into winter sports.

## Key dates

| When | What |
|---|---|
| Fri Nov 13, 7:30 PM | Sub-theme reveal; **all game and website work must start after this** |
| Sat Nov 14, 11:00 AM–1:00 PM | Technical help on Zoom (Dr. Susan Purrington) |
| **Sun Nov 15, 10:00 AM sharp** | **Submission deadline.** Late = not judged. Editable until the deadline |
| Sun Nov 15, 11:00 AM–4:00 PM | Judging |
| Sun Nov 15, ~6:45 PM | Awards, evening celebration in Olin 014 |

## Rules

- Solo or teams of 2–3 registered Connecticut College students.
- AI-assisted coding is explicitly allowed and encouraged. Godot is permitted.
- Assets: only self-created, AI-generated or properly licensed art, music, sounds and fonts. Credit third-party
  resources. Content appropriate for a campus audience.

## Required deliverables

1. A fully playable **browser game**.
2. A publicly accessible **game studio website** that links to the game.

**Hosting:** Godot Web export on itch.io is accepted. Upload a ZIP with `index.html` + its files, project kind
**HTML**, enable browser play. Either configure SharedArrayBuffer support or use a single-threaded export
(we use single-threaded; see `docs/IMPLEMENTATION_ASSUMPTIONS.md`).

## Submission form needs

- Game URL and studio website URL
- 2–3 sentences: controls, objective, win/lose conditions
- Explanation of both themes
- 3–5 best AI prompts
- Team names and Conn emails
- Credits for external assets
- Course information (only if seeking extra credit)

## Judging (100 points)

| Category | Points |
|---|---:|
| Game quality | 35 |
| Studio website | 25 |
| Theme integration | 15 |
| Creativity | 15 |
| AI development process | 10 |

## What this means for development

- Time budget is roughly Fri 7:30 PM → Sun 10:00 AM (~38 h). Protect the last few hours for building, uploading
  and submitting.
- The website is worth 25 points, so it is a real deliverable, not an afterthought (master plan P20).
- Prioritize a complete, stable game and an attractive website over implementing every BTD6-inspired tower or
  upgrade (master plan §10 fallback builds).
- Test both the game and the website in an **incognito window without login** before submitting.
- Save good AI prompts as we go (`docs/logs/`) for the "best AI prompts" field and the AI-process score.
