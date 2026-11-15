# Website review and refresh — November 15, 2026

## Assessment of the previous site

The existing public site had a clear play link, recognizable winter colors, and a useful content outline. Its main weakness was evidence: a generic SVG slope represented a now much more developed 3D game, all three screenshots were missing, and team/model/audio credits were placeholders. The process explanation covered coding but did not show the visual development pipeline. Controls described the old six-unit roster and only 2× speed.

The supplied jam rubric makes this significant: the studio website is 25 points, process is 10, and theme integration is 15. A judge should be able to see the actual game, understand both themes, and inspect the work behind it quickly. No numerical score is assigned without the judges' evaluation.

## Implemented locally

- A winter-lodge visual identity using actual game fonts, spruce, snow, festive red, and a menu image presented as a lift pass.
- Real browser captures, seven runtime defender portraits, and enlargeable reference sheets; no screenshot placeholders.
- Current controls, Camel Claus hero, 25-round objective, and 1×/2×/4× speed.
- Solo creator credit for Quentin Drucker: game design, creative direction, AI-assisted development, gameplay/balance/economy/progression, upgrade synergies, 3D asset creation, rigging, animation, and audio integration.
- GPT contact sheets → Tripo AI → AccuRig source-rig preparation → Blender/Godot integration, with the deferred AccuRig replacement distinguished from the runtime Rookie.
- Master-plan diagram linking downloadable copies of the four real Markdown documents; saved prompt excerpts and full prompt downloads.
- Specific environment attribution, shipped-audio ledger, local fonts and licenses. The current audio ledger records Willosuna, not Pixabay; no unsupported Pixabay asset attribution was added.

## Useful final polish after the final build

1. Replace the menu/gameplay captures only if the final build changes their appearance. Prefer one populated mid-round capture showing enemies, attack effects, and upgraded defenders. The present gameplay image is accurately captioned as between rounds.
2. Add a short actual gameplay clip if time allows. It would communicate animation and combat more quickly than another paragraph. No simulated trailer or fabricated capture is needed.
3. Upload the final game to the existing itch.io project, then verify a complete browser run and both public links without signing in. Website QA does not establish the final game's release readiness.
4. Publish the reviewed `website/` directory through the existing GitHub Pages workflow. This refresh has not been committed, pushed, or published by this session.
5. Use the saved full prompts as the starting point for the submission form's 3–5 best prompts. The three on-page excerpts are samples, not a replacement for the full form response.

## Verification

Browser QA: all image sources load; all page-local assets and downloads return HTTP 200; no broken anchors or duplicate IDs; all three play links match the provided itch.io URL. No horizontal overflow at 320, 390, 768, 1024, and 1440px. Image dialog opens, closes with its button and Escape, and restores keyboard focus. Controls disclosure works. JavaScript syntax check passed; browser console reports no errors or warnings.

Visuals reviewed at desktop and mobile sizes. Local screenshots are in `build/website-desktop.png`, `build/website-mobile.png`, `build/website-process.png`, and full-page captures `build/website-1440.png` / `build/website-390.png` (build files are not part of the public site).

The Godot MCP tools are unavailable in this session, so the requested Godot process/error tool checks could not run. No game scenes or gameplay code were changed for this website refresh.
