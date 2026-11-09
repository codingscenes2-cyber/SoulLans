# Prototype readiness map

Last updated: 2026-11-09

Latest headless validation: [Godot project validation run #134 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42566158315). The Ashen Kingdom art pass passed headless import and scene startup. Android export: [debug export run #9 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42566158484). The ARM64 APK was signed and verified by apksigner (v1, v2 and v3), downloaded from the Actions artifact and independently SHA-256 checked. CI does not replace hands-on Android gameplay testing.

This is a readiness snapshot, not a claim that the game is finished or device-tested. The 0.2.1 debug APK has a verified signature; physical-device install and gameplay QA are still pending.

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
| Ashen Kingdom level | **Connected route with first procedural art pass; CI green** | Added noise-textured stone, ruined arches, rock clusters, dead trees, distant ridges and faction banners around the road/courtyard. The layout remains a prototype; collision, traversal, lighting and mobile visual QA remain. External Quaternius/Poly Haven models are identified as licensed sources but are not bundled in this build. |
| Characters / animation / audio | **Not production-ready** | Placeholder geometry; no production character rigs, animation sets, combat audio or VFX. |
| Android export | **0.2.1 ARM64 debug APK built and signature verified** | [Run #9](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42566158484) exported 24,196,306 bytes; apksigner verified v1/v2/v3. Sensor-landscape orientation is configured in both project and Android preset. Artifact expires 23 Nov 2026. SHA-256: `983ab1669cddfd0a888b3d958c8b9efb3cf5b623bf245ac10aa63ecf0f9e5241`. Physical-device orientation and gameplay are not yet tested. |
| Prototype package | **Debug prototype candidate; device QA pending** | Install and launch on the target phone, test sensor-landscape auto-rotation, touch controls, route traversal, combat, save persistence, frame pacing and crashes. This is not a release-signed build. |

## Prototype build gate

1. Keep the Godot headless CI checks green.
2. Add and run repeatable gameplay checks for the two enemy archetypes, heavy attack, block, parry, flask, death/recovery and Sanctuary rest.
3. Validate the new connected Ashen Kingdom route, then add an intentional exploration loop, traversal beats and at least one encounter beyond the training arena.
4. [x] Run and validate the Android debug export workflow. Run #6 produced and uploaded an ARM64 debug APK; signature verification passed.
5. Install the APK on the target Android device and record launch, controls, route, combat, orientation, performance, persistence and crash results.
6. After device QA, publish a clearly labelled prototype candidate with commit ID, file size and SHA-256. A release-signed build is a later gate.

## Current decision

**0.2.1 debug APK built; physical-device QA is the next gate.** The project remains an early prototype. Procedural environment dressing is in place, but external production models, character rigs, animation/audio, authored exploration and target-device QA remain.
