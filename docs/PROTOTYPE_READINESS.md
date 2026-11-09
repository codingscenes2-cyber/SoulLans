# Prototype readiness map

Last updated: 2026-11-09

Latest completed validation: [GitHub Actions run #99 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42564648199). The headless save/progression suite also passed in [run #97](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42564586387). The first Android export attempt [run #1 failed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42564764601) because the SDK setup action requested Google's removed `tools` package. [Run #2](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42564839680) then exposed a redundant license-acceptance pipe that exited on SIGPIPE after licenses were already accepted. The workflow now uses setup-android v4.0.2 and relies on its built-in license acceptance; [retry #3 is queued](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42564895704). CI does not replace hands-on gameplay or Android device testing.

This is a readiness snapshot, not a claim that a finished Android build exists. "CI green" means Godot headless import and main-scene startup passed in GitHub Actions; it does not prove full gameplay or device compatibility.

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
| Android export | **Preset and manual CI pipeline committed; first export pending** | `export_presets.cfg` targets arm64 debug APK. A manual/targeted GitHub Actions workflow installs Godot 4.3 templates, Java 17 and Android SDK packages; run #1 is queued. Export success, artifact inspection and device install are not yet verified. |
| Prototype package | **Not ready** | Must pass gameplay smoke tests, Android export, install/launch and basic device QA before sharing an APK as a usable prototype. |

## Prototype build gate

1. Keep the Godot headless CI checks green.
2. Add and run repeatable gameplay checks for the two enemy archetypes, heavy attack, block, parry, flask, death/recovery and Sanctuary rest.
3. Validate the new connected Ashen Kingdom route, then add an intentional exploration loop, traversal beats and at least one encounter beyond the training arena.
4. Run and validate the new Android debug export workflow; resolve any SDK/template/preset issues without committing signing secrets.
5. Export a debug APK, install it on the target Android device, and record launch, controls, orientation, performance and crash results.
6. Only then publish a clearly labelled prototype APK with commit ID, file size and SHA-256. A release-signed build is a later gate.

## Current decision

**Continue development; do not announce a prototype APK yet.** The project is at an early connected-graybox stage. The largest blockers are runtime gameplay verification and encounter tuning, a fuller exploration loop, the first verified Android export, and device QA.
