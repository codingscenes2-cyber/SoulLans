# Production roadmap

Complete a small, tested vertical slice before expanding into a large world. Do not mark work complete until it has been run and verified.

## 0. Engine and project foundation
- [x] Godot 4 project configuration and main scene.
- [x] Mobile-compatible GL Compatibility renderer baseline.
- [x] Runtime graybox arena.
- [x] Placeholder player, enemy and touch HUD.
- [x] Validate project import and parser in Godot 4.x through GitHub Actions headless import.
- [x] Add an arm64 Android debug export preset and a GitHub Actions export workflow.
- [x] Export and explicitly apksigner-verify ARM64 PBR debug APK 0.3.0 (run #14; six 1K CC0 PBR maps imported; device install pending).
- [ ] Install and test on target hardware, including sensor-landscape rotation.
- [x] Add automated headless import/startup check to CI; latest recorded runs passed.

## 1. Player controller and camera
- [x] Basic third-person movement and gravity.
- [x] Basic sprint and stamina drain.
- [x] Stamina regeneration delay after sprint, dodge and attacks.
- [x] Basic dodge action and stamina cost.
- [x] Basic melee prototype with startup/active timing and a physics overlap query.
- [x] Touch camera drag and analog virtual joystick prototype.
- [ ] Camera collision and sensitivity tuning.
- [x] Lock-on target cycling across living enemy archetypes.
- [ ] Jump, fall, landing and traversal.
- [x] Animation-driven player locomotion and combat state integration (verified clip switching; visual/device tuning remains).

## 2. Combat foundation
- [x] WeaponData resource schema with Ashen Iron Sword and Ashen Watch Dagger definitions; light attack reads damage, stamina cost, range and timing.
- [x] Prototype weapon cycling on desktop Q and the mobile weapon button.
- [ ] Weapon-specific movesets and animation-driven attack families.
- [x] Basic light-attack startup/active timing and physics hit query.
- [ ] Add weapon-specific animation-driven hit windows and full attack families.
- [x] Prototype light and heavy attacks; heavy attack has increased damage/poise, longer windup/recovery and higher stamina cost.
- [ ] Charged, sprint and jump attacks.
- [x] Prototype dodge invulnerability window.
- [x] Directional block with stamina drain and guard-break penalty; timed parry staggers the training enemy (prototype).
- [ ] Riposte, backstab and hyperarmour.
- [x] Enemy poise and stagger response prototype.
- [ ] Damage types, resistances and status effects.
- [ ] Combat feedback, hit-stop, sound and VFX.

## 3. Character art and animation

**The current capsule characters, stretched noise floor and flat lighting are known quality blockers.** Detailed production gates, target budgets, candidate asset sources, animation inventory and milestone exit criteria are in [docs/ART_ANIMATION_ASSET_ROADMAP.md](docs/ART_ANIMATION_ASSET_ROADMAP.md).
- [ ] Deliver visual overhaul per [Art, Character and Animation Production Roadmap](docs/ART_ANIMATION_ASSET_ROADMAP.md).
- [x] Import and validate CC0 Quaternius humanoid base model and 65-bone shared skeleton.
- [x] Merge and validate 85 Quaternius UAL1 + UAL2 clips (16,575 animation channels) onto the hero rig with name-matched GLB pipeline.
- [x] Drive player idle, jog, sprint, roll, sword attack, guard and death clips from gameplay state using cross-faded AnimationPlayer transitions.
- [ ] Replace AnimationPlayer state switching with a tuned AnimationTree blend graph and weapon-specific layered animation.
- [ ] Replace enemy capsule stand-ins with distinct rigged enemy models; hero rig is now integrated, but armour and weapon attachments remain.
- [x] Replace stretched noise ground with CC0 PBR concrete ground and rock-wall materials.
- [ ] Add separate ash/soil/stone blend and material decals.
- [ ] Build modular Ashen Kingdom architecture and authored prop set.
- [ ] Complete environment lighting, fog, sky, VFX and audio pass.
- [ ] Implement LODs, mobile texture compression and measured performance budgets.

## 4. Enemy AI and encounters
- [x] Basic training enemy chase and attack prototype.
- [x] Training enemy state machine: idle, patrol, investigate, chase, windup, recovery, stagger and death.
- [x] NavigationAgent3D path query integration with direct-steering fallback; bake a NavigationRegion3D before relying on pathfinding.
- [x] Training enemy telegraphed attack wind-up and recovery.
- [x] Second enemy archetype prototype: Ashen Watch Shield Guard mitigates frontal hits, takes pressure from repeated attacks and exposes a timed guard-break opening.
- [ ] Telegraph-based attack selection for varied enemy archetypes.
- [ ] Group encounters, ranged enemies, elites and mini-bosses.
- [x] First boss framework: quest-gated Ashen Regent, three combat phases, telegraphed slam, unique reward, boss HUD and persistent throne-gate progression; additional bosses and arena tuning remain.

## 5. First vertical slice — Ashen Kingdom
- [x] Initial connected graybox route: arena, broken gate, ruined road, roadside landmarks and walled outer courtyard (headless CI passed; runtime validation pending).
- [ ] Add traversal beats, encounter spaces and a complete exploration loop.
- [x] First procedural environment art pass: noise-textured stone, ruined arches, rock clusters, dead trees, ridges and banners.\n- [ ] Import and integrate selected external CC0/Quaternius 3D models with verified provenance.
- [ ] Three regular enemy archetypes and one elite (two basic archetypes are now present in the combat test arena).
- [x] Prototype Sanctuary checkpoint, rest, death/respawn and Soul Essence recovery loop.
- [x] Enemy reset-on-rest prototype.
- [ ] World persistence rules and full checkpoint playtest.
- [ ] One NPC, dialogue system and branching quest. (Warden Eira, interact prompt path, persistent three-defeat quest and one-time Soul Essence reward implemented; CI verification and in-game playtest pending.)
- [ ] One multi-phase region boss. (Ashen Regent implementation committed: Warden quest unlock, three escalating combat phases, a parry-interruptible radial slam, live boss HUD, permanent defeat record, defeat event and an openable road beyond the gate; CI regression test added, validation/playtest pending.)
- [ ] Playtest, difficulty tuning and performance budget.

## 6. RPG systems
- [ ] Character creation and eight starting classes.
- [x] Vigor, Endurance, Strength and Dexterity attributes with Sanctuary-only Soul Essence levelling and weapon scaling.
- [ ] Intelligence, Faith, Arcana and Mind.
- [x] Soul Essence reward, death-drop and recovery prototype.
- [x] Soul Essence level-up cost curve and attribute spending prototype.
- [x] Three-charge healing flask, 45 HP restore and Sanctuary refill prototype.
- [x] Persistent inventory with stackable item quantities, saved weapon equipment, Ashen Tonic and enemy/boss material drops; mobile inventory panel, three-stage weapon upgrades (+12% damage per level) and regression tests added.\n- [ ] Armour slots, equip load, item sorting, tooltips and broader consumables.
- [x] Three-stage weapon upgrades using Ashen Scrap, Tempered Plates and the unique Regent Core; +12% weapon damage per level, upgrade only at the Sanctuary.\n- [ ] Armour upgrades, infusions, relics and talismans.
- [ ] Spell schools, focus resource and status effects.
- [x] Versioned JSON save/load foundation for player/world state with periodic autosave.
- [x] Add last-known-good backup recovery, corrupt-primary restoration, legacy-save defaults and headless death/recovery/levelling regression tests.
- [ ] Device interruption, long-session and full persistence playtests.

## 7. World, story and content
- [ ] Lore bible and narrative state graph.
- [ ] NPC schedules, memory, relationships and quest outcomes.
- [ ] Factions, reputation and persistent world events.
- [ ] Hollow Forest, Velmora, Frostfall Highlands, Ember Depths, Sunken Catacombs and Forgotten Citadel.
- [ ] Seven distinct endings with prerequisite flags.
- [ ] Day/night, weather, exploration rewards and fast travel.

## 8. Audio, UI and accessibility
- [ ] Combat, environment, UI and creature audio.
- [ ] Music and ambience implementation.
- [x] First mobile inventory/equipment panel plus quest and boss HUD prototypes.\n- [ ] Map, quest journal, settings and accessibility options.
- [ ] Remappable controls, sensitivity, subtitles and readability options.

## 9. Android optimisation and release
- [ ] Profile CPU/GPU/memory on target Android hardware.
- [ ] LODs, occlusion, texture compression and object pooling.
- [ ] Graphics presets, frame pacing and thermal testing.
- [ ] Save migration and regression test suite.
- [ ] Signed release APK and versioned source archive.
- [ ] Verify APK install/launch and gameplay on target Android hardware before prototype announcement.
- [ ] Produce release-signed APK and verify external upload link before release announcement.
