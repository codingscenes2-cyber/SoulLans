# SOUL LAND: THE FALLEN REALM

A full 3D third-person Soulslike action RPG for Android, built with Godot 4.

The world was once governed by seven primordial powers: Life, Death, Time, Flame, Void, Memory and Creation. Their authority rested in seven Soul Thrones. Nine centuries ago, the Seventh Throne shattered in the Great Fracture. Kingdoms fell, the dead returned and forgotten powers stirred. The player is bound to the missing Throne, but the truth behind that bond is deliberately obscured.

This is an original game world. Use original characters, locations, dialogue, music and visual assets; do not copy protected Elden Ring content.

## Current status

The repository now contains a playable-prototype foundation: third-person movement and camera orbit, touch controls, timed melee hit detection, a telegraphed melee enemy and a shield-guard archetype with frontal damage mitigation and a guard-break opening, both with poise/stagger, a Sanctuary altar, death/respawn, Soul Essence drops and recovery, four persistent attributes with Sanctuary-only levelling, weapon attribute scaling, and versioned local save data. The first connected Ashen Kingdom graybox route is now committed: the combat arena opens through a broken gate onto a ruined road, roadside rubble and lantern landmarks, then into a walled outer courtyard facing a sealed throne-road gate. The latest completed GitHub Actions workflow has successfully imported the project and launched the main scene headlessly; CI for the route commit is still running.

**This remains an early prototype, not a finished game or verified Android build.** The player and enemy are still primitive placeholders; there are no production character models, animation sets, full weapon movesets, or device performance results. Headless CI success does not replace testing on the target Android device.

## Quick start

1. Install Godot 4.3 or later.
2. Import the project.godot file.
3. Run scenes/main.tscn (F6) or the main project (F5).
4. Desktop controls: WASD move, Shift sprint, Space dodge, E interact/rest/recover, left mouse light attack, H heavy attack (higher damage/poise, slower and more stamina), F hold block, G tap parry (0.22 s timing window), Tab lock-on / cycle nearby enemies, Q cycle weapons, 1–4 level Vigor/Endurance/Strength/Dexterity at the Sanctuary, R use a healing flask, right mouse drag camera. On mobile, use the VIG/END/STR/DEX buttons near the top-right; levelling only works beside the Sanctuary and consumes Soul Essence. The BLOCK and PARRY touch controls provide directional guard and timed parry; a successful parry staggers the training enemy. The FLASK button consumes one of three charges to restore 45 HP; resting at the Sanctuary refills them. The first encounter now includes a basic Training Hollow and a slower Ashen Watch Shield Guard; repeatedly pressure its shield or attack from behind to punish its guard opening. The prototype weapon set currently includes an Ashen Iron Sword and Ashen Watch Dagger.
5. Android export requires Godot export templates and a configured Android SDK/JDK.

## Development pillars

- Deliberate third-person combat with readable telegraphs and recovery windows.
- Exploration-led dark fantasy worldbuilding.
- Distinct weapons, builds, enemies and bosses.
- Meaningful death, checkpoint and recovery loop.
- Touch-first Android UI and performance-conscious rendering.
- Persistent choices, NPC relationships, quests and multiple endings.

The new route is still primitive blockout geometry and has not yet been runtime-tested. See [ROADMAP.md](ROADMAP.md), the [prototype readiness map](docs/PROTOTYPE_READINESS.md) and docs/ for the staged production plan, current build gates and subsystem specifications.
