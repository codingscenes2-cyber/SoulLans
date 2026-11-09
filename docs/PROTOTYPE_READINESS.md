# Prototype readiness map

Last updated: 2026-11-09

Latest headless validation: [Godot project validation run #144 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42567132487). Android PBR export: [run #12 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42567132362). CI downloaded the 1K CC0 Concrete Floor 01 and Rock Wall 17 diffuse, OpenGL normal and roughness maps from Poly Haven, imported them, and exported an ARM64 APK. Physical-device visual/performance QA is still pending.

This is a readiness snapshot, not a claim that the game is finished or device-tested. The new PBR APK is debug-signed with a runner-generated key, so it will not update an installation signed by a different key. Preserve the old install until a stable signing-key migration plan is agreed.

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
| Ashen Kingdom level | **PBR material and lighting pass exported; CI green** | Ground/road now use Poly Haven Concrete Floor 01 diffuse, OpenGL normal and roughness maps; stone structures and rocks use Rock Wall 17 maps with world-triplanar projection. Procedural sky, warm key light, cool fill and distance fog improve depth. Art is still an early pass; device visual/performance QA and imported production meshes remain. |
| Characters / animation / audio | **Not production-ready** | Placeholder geometry; no production character rigs, animation sets, combat audio or VFX. |
| Android export | **0.3.0 ARM64 debug APK exported** | [Run #12](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42567132362) fetched/imported six 1K PBR maps and exported the APK (32,062,133 bytes). SHA-256: `6a9dca978db374546413b001d4bf18be40b98a6d870d8ca1ebeb13a10751e06c`. Export job passed; new run will add explicit apksigner verification. Debug key is ephemeral, so this build cannot update installs signed by other keys. |\n| Prototype package | **Debug prototype candidate; device QA pending** | Install and launch on the target phone, test sensor-landscape auto-rotation, touch controls, route traversal, combat, save persistence, frame pacing and crashes. This is not a release-signed build. |

## Prototype build gate

1. Keep the Godot headless CI checks green.
2. Add and run repeatable gameplay checks for the two enemy archetypes, heavy attack, block, parry, flask, death/recovery and Sanctuary rest.
3. Validate the new connected Ashen Kingdom route, then add an intentional exploration loop, traversal beats and at least one encounter beyond the training arena.
4. [x] Run and validate the Android debug export workflow. Run #6 produced and uploaded an ARM64 debug APK; signature verification passed.
5. Install the APK on the target Android device and record launch, controls, route, combat, orientation, performance, persistence and crash results.
6. After device QA, publish a clearly labelled prototype candidate with commit ID, file size and SHA-256. A release-signed build is a later gate.

## Current decision

**0.3.0 PBR debug APK exported; physical-device visual QA is the next gate.** The project remains an early prototype. Imported character models, animation, audio, authored exploration and target-device QA remain.
