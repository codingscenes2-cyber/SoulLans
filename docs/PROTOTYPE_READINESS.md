# Prototype readiness map

Last updated: 2026-11-09

Latest completed validation: [GitHub Actions run #86 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42559840675). The new connected-route commit is in [run #87 — currently running](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42564392624). CI validates headless import and scene startup, not hands-on gameplay.

This is a readiness snapshot, not a claim that a finished Android build exists. "CI green" means Godot headless import and main-scene startup passed in GitHub Actions; it does not prove full gameplay or device compatibility.

## Status map

| Workstream | Current state | Evidence / remaining gate |
|---|---|---|
| Godot project foundation | **CI green** | Godot 4 project imports and main scene starts headlessly. |
| Player movement and camera | **Prototype implemented** | Movement, sprint, dodge, orbit camera, lock-on toggle and touch joystick exist. Needs camera collision, target switching and device feel test. |
| Mobile HUD | **Prototype implemented / CI green** | Touch movement, camera drag, attack, heavy, block, parry, dodge, lock, interact, weapon, flask and attribute buttons. Safe-area/resolution QA remains. |
| Combat | **Prototype implemented / CI green** | Light/heavy attacks, stamina, dodge i-frames, directional block, guard break, timed parry, poise and stagger. Animation-driven hitboxes, ripostes, damage types and feedback remain. |
| Enemy AI | **Two archetypes committed; CI pending for latest change** | Training Hollow plus Ashen Watch Shield Guard. Guard pressure/opening is implemented; encounter balance and runtime testing remain. |
| Sanctuary / death loop | **Prototype implemented** | Rest, respawn, Soul Essence drop/recovery, flasks and attribute levelling. Full persistence regression tests remain. |
| Save system | **Foundation implemented** | Versioned JSON save and autosave. Backup/corrupt-save recovery and migration tests remain. |
| Ashen Kingdom level | **Initial connected graybox route committed; CI pending** | Arena now connects through a broken gate and roadside approach into a walled outer courtyard with a sealed destination gate and primitive lantern landmarks. No authored traversal, NPCs, encounter placement along the route or environmental art yet. |
| Characters / animation / audio | **Not production-ready** | Placeholder geometry; no production character rigs, animation sets, combat audio or VFX. |
| Android export | **Not configured / not verified** | Export preset, SDK/JDK, templates, signing and actual device install still required. |
| Prototype package | **Not ready** | Must pass gameplay smoke tests, Android export, install/launch and basic device QA before sharing an APK as a usable prototype. |

## Prototype build gate

1. Keep the Godot headless CI checks green.
2. Add and run repeatable gameplay checks for the two enemy archetypes, heavy attack, block, parry, flask, death/recovery and Sanctuary rest.
3. Validate the new connected Ashen Kingdom route, then add an intentional exploration loop, traversal beats and at least one encounter beyond the training arena.
4. Configure Android export templates, SDK/JDK and a debug export preset without committing signing secrets.
5. Export a debug APK, install it on the target Android device, and record launch, controls, orientation, performance and crash results.
6. Only then publish a clearly labelled prototype APK with commit ID, file size and SHA-256. A release-signed build is a later gate.

## Current decision

**Continue development; do not announce a prototype APK yet.** The project is at an early connected-graybox stage. The largest blockers are route validation and encounter design, runtime gameplay verification, Android export setup and device QA.
