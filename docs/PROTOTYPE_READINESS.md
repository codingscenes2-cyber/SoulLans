# Prototype readiness map

Last updated: 2026-11-09

Latest headless validation: [Godot project validation run #148 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42567309418). Android PBR export: [run #14 — passed](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42567309495). CI fetched and imported six 1K CC0 PBR maps from Poly Haven (Concrete Floor 01 and Rock Wall 17: diffuse, OpenGL normal, roughness), exported the ARM64 APK and explicitly verified it with apksigner. Physical-device visual/performance QA is pending.

This is a readiness snapshot, not a claim that the game is finished or device-tested. The 0.3.0 debug APK uses an ephemeral runner-generated key, so it will not update an installation signed by a different key. Preserve the old install until a stable signing-key migration plan is agreed.

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
| Characters / animation / audio | **First rigged hero + 85 clips; early integration** | Quaternius humanoid GLB has one Skeleton3D and three valid meshes; CI matches 66 nodes and merges 16,575 channels from 85 CC0 clips. Player state selects idle, jog, sprint, roll, sword attack, guard and death. No enemy rig variants, armour, weapon attachment, AnimationTree blend graph, combat audio or VFX yet. Visual/device QA remains. |
| Android export | **0.3.0 ARM64 PBR debug APK exported and signature verified** | [Run #14](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42567309495) fetched/imported six 1K PBR maps, exported 32,062,133 bytes and passed explicit apksigner verification. SHA-256: `f11a09afd29e40c3be7ec429116a257862c13bd7af23c81b06d5d7af803b15cc`. Artifact expires 23 Nov 2026. Debug key is ephemeral; cannot update an install signed with another key. |\n
## Prototype build gate

1. Keep the Godot headless CI checks green.
2. Add and run repeatable gameplay checks for the two enemy archetypes, heavy attack, block, parry, flask, death/recovery and Sanctuary rest.
3. Validate the new connected Ashen Kingdom route, then add an intentional exploration loop, traversal beats and at least one encounter beyond the training arena.
4. [x] Run and validate the Android debug export workflow. Run #6 produced and uploaded an ARM64 debug APK; signature verification passed.
5. Install the APK on the target Android device and record launch, controls, route, combat, orientation, performance, persistence and crash results.
6. After device QA, publish a clearly labelled prototype candidate with commit ID, file size and SHA-256. A release-signed build is a later gate.

## Current decision

**0.3.0 PBR debug APK exported and signature-verified; physical-device visual QA is the next gate.** The project remains an early prototype. A CC0 Quaternius humanoid base is bundled. CI merges 85 CC0 animation clips (16,575 channels) onto its matching 66-node skeleton, and the player controller selects first-pass movement/combat clips. Armour, weapon attachment, distinct enemy rigs, AnimationTree blending and on-device visual QA remain. Audio, authored exploration and target-device QA remain.
