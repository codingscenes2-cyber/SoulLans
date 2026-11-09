# Prototype readiness map

Last updated: 2026-11-09

Latest completed validation: [GitHub Actions run #98 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42564605405). It validates headless import, main-scene startup and the save/progression regression suite. The follow-up initial-spawn fix is in [run #99 — pending](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42564648199). CI does not replace hands-on gameplay or Android device testing.

This is a readiness snapshot, not a claim that a finished Android build exists. "CI green" means Godot headless import and main-scene startup passed in GitHub Actions; it does not prove full gameplay or device compatibility.

## Status map

| Workstream | Current state | Evidence / remaining gate |
|---|---|---|
| Godot project foundation | **CI green** | Godot 4 project imports and main scene starts headlessly. |
| Player movement and camera | **Prototype implemented** | Movement, sprint, dodge, orbit camera, lock-on toggle and touch joystick exist. Needs camera collision, target switching and device feel test. |
| Mobile HUD | **Prototype implemented / CI green** | Touch movement, camera drag, attack, heavy, block, parry, dodge, lock, interact, weapon, flask and attribute buttons. Safe-area/resolution QA remains. |
| Combat | **Prototype implemented / CI green** | Light/heavy attacks, stamina, dodge i-frames, directional block, guard break, timed parry, poise and stagger. Animation-driven hitboxes, ripostes, damage types and feedback remain. |
| Enemy AI | **Two archetypes and three placements; CI green** | Training Hollow and Ashen Watch Shield Guard are placed in the arena, with an additional Training Hollow in the outer courtyard. Guard pressure/opening is implemented; encounter balance and runtime testing remain. |
| Sanctuary / death loop | **Prototype implemented** | Rest, respawn, Soul Essence drop/recovery, flasks and attribute levelling. Full persistence regression tests remain. |
| Save system | **Backup recovery and regression suite CI green** | Versioned saves, temp-file replacement, last-known-good backup restoration, legacy version-1 defaults, death/recovery and levelling are covered by headless regression tests. Device interruption and long-session testing remain. |
| Ashen Kingdom level | **Connected graybox route and courtyard encounter; CI green** | Arena connects through a broken gate and ruined road into a walled outer courtyard. A Training Hollow now occupies the courtyard; a sealed destination gate and primitive lanterns provide landmarks. Runtime navigation, authored traversal, NPCs and environmental art remain. |
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

**Continue development; do not announce a prototype APK yet.** The project is at an early connected-graybox stage. The largest blockers are runtime gameplay verification and encounter tuning, a fuller exploration loop, Android export setup and device QA.
