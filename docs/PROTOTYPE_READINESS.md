# Prototype readiness map

Last updated: 2026-11-09

Latest headless validation: [Godot project validation run #122 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42565383559). The save/progression suite passed in [run #97](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42564586387). Android export is now successful: [debug export run #6 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42565383797). The APK was signed and verified by apksigner (v2 and v3), uploaded as a GitHub Actions artifact, downloaded and independently SHA-256 checked. CI does not replace hands-on gameplay or Android device testing.

This is a readiness snapshot, not a claim that the game is finished or device-tested. The first Android debug APK exists and has a verified signature; no physical-device install or gameplay test has been performed yet.

## Status map

| Workstream | Current state | Evidence / remaining gate |
|---|---|---|
| Godot project foundation | **CI green** | Godot 4 project imports and main scene starts headlessly. |
| Player movement and camera | **Prototype implemented** | Movement, sprint, dodge, orbit camera, lock-on toggle and touch joystick exist. Needs camera collision, target switching and device feel test. |
| Mobile HUD | **Prototype implemented / CI green** | Touch movement, camera drag, attack, heavy, block, parry, dodge, lock, interact, weapon, flask and attribute buttons. Safe-area/resolution QA remains. |
| Combat | **Prototype implemented / CI green** | Light/heavy attacks, stamina, dodge i-frames, directional block, guard break, timed parry, poise and stagger. Animation-driven hitboxes, ripostes, damage types and feedback remain. |
| Enemy AI | **Two archetypes and three placements; CI green** | Training Hollow and Ashen Watch Shield Guard are placed in the arena, with an additional Training Hollow in the outer courtyard. Guard pressure/opening is implemented; encounter balance and runtime testing remain. |
| Sanctuary / death loop | **Prototype implemented; core logic regression-tested** | Rest, respawn, Soul Essence drop/recovery, flasks and attribute levelling. Device interruption and full checkpoint playtests remain. |
| Save system | **Backup recovery and regression suite CI green** | Versioned saves, temp-file replacement, last-known-good backup restoration, legacy version-1 defaults, death/recovery and levelling are covered by headless regression tests. Device interruption and long-session testing remain. |
| Ashen Kingdom level | **Connected graybox route and courtyard encounter; CI green** | Arena connects through a broken gate and ruined road into a walled outer courtyard. A Training Hollow now occupies the courtyard; a sealed destination gate and primitive lanterns provide landmarks. Runtime navigation, authored traversal, NPCs and environmental art remain. |
| Characters / animation / audio | **Not production-ready** | Placeholder geometry; no production character rigs, animation sets, combat audio or VFX. |
| Android export | **Debug APK built and signature verified** | [Run #6](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42565383797) exported an ARM64 APK (24,187,949 bytes); apksigner verified v2/v3. The artifact expires 23 Nov 2026. SHA-256: `bf4c9db464c10652f7b6627f45e049573a52abecd707801a24e537c7e7f0221e`. APK has not been installed on a physical device. |
| Prototype package | **Debug prototype candidate; device QA pending** | Install and launch on the target phone, test touch controls, route traversal, combat, save persistence, orientation, frame pacing and crashes. This is not a release-signed build. |

## Prototype build gate

1. Keep the Godot headless CI checks green.
2. Add and run repeatable gameplay checks for the two enemy archetypes, heavy attack, block, parry, flask, death/recovery and Sanctuary rest.
3. Validate the new connected Ashen Kingdom route, then add an intentional exploration loop, traversal beats and at least one encounter beyond the training arena.
4. [x] Run and validate the Android debug export workflow. Run #6 produced and uploaded an ARM64 debug APK; signature verification passed.
5. Install the APK on the target Android device and record launch, controls, route, combat, orientation, performance, persistence and crash results.
6. After device QA, publish a clearly labelled prototype candidate with commit ID, file size and SHA-256. A release-signed build is a later gate.

## Current decision

**First debug APK built; physical-device QA is the next gate.** The project remains an early connected-graybox prototype. The largest blockers are runtime gameplay verification and encounter tuning, a fuller exploration loop, production assets/animation/audio and target-device QA.
