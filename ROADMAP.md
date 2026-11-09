# Production roadmap

Complete a small, tested vertical slice before expanding into a large world. Do not mark work complete until it has been run and verified.

## 0. Engine and project foundation
- [x] Godot 4 project configuration and main scene.
- [x] Mobile-compatible GL Compatibility renderer baseline.
- [x] Runtime graybox arena.
- [x] Placeholder player, enemy and touch HUD.
- [x] Validate project import and parser in Godot 4.x through GitHub Actions headless import.
- [x] Add an arm64 Android debug export preset and a manual GitHub Actions export workflow (first export pending).
- [ ] Verify debug APK export, install and test on target hardware.
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
- [ ] Animation-driven locomotion and combat state integration.

## 2. Combat foundation
- [x] WeaponData resource schema with Ashen Iron Sword and Ashen Watch Dagger definitions; light attack reads damage, stamina cost, range and timing.
- [x] Prototype weapon cycling on desktop Q and the mobile weapon button.
- [ ] Weapon-specific movesets, equipment UI and weapon switching.
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
- [ ] Select original or correctly licensed humanoid character assets.
- [ ] Establish scale, skeleton and retargeting conventions.
- [ ] Player idle/walk/run/sprint blend tree.
- [ ] Dodge directions, attacks, block, parry and hit reactions.
- [ ] Enemy locomotion, telegraphs, attacks and death animations.
- [ ] Boss phase transitions and signature animation sets.
- [ ] Mobile LODs, texture compression and material budgets.

## 4. Enemy AI and encounters
- [x] Basic training enemy chase and attack prototype.
- [x] Training enemy state machine: idle, patrol, investigate, chase, windup, recovery, stagger and death.
- [x] NavigationAgent3D path query integration with direct-steering fallback; bake a NavigationRegion3D before relying on pathfinding.
- [x] Training enemy telegraphed attack wind-up and recovery.
- [x] Second enemy archetype prototype: Ashen Watch Shield Guard mitigates frontal hits, takes pressure from repeated attacks and exposes a timed guard-break opening.
- [ ] Telegraph-based attack selection for varied enemy archetypes.
- [ ] Group encounters, ranged enemies, elites and mini-bosses.
- [ ] Boss framework with phase data, arena boundaries and rewards.

## 5. First vertical slice — Ashen Kingdom
- [x] Initial connected graybox route: arena, broken gate, ruined road, roadside landmarks and walled outer courtyard (headless CI passed; runtime validation pending).
- [ ] Add traversal beats, encounter spaces and a complete exploration loop.
- [ ] Finished art pass for one compact region.
- [ ] Three regular enemy archetypes and one elite (two basic archetypes are now present in the combat test arena).
- [x] Prototype Sanctuary checkpoint, rest, death/respawn and Soul Essence recovery loop.
- [x] Enemy reset-on-rest prototype.
- [ ] World persistence rules and full checkpoint playtest.
- [ ] One NPC, dialogue system and branching quest.
- [ ] One multi-phase region boss.
- [ ] Playtest, difficulty tuning and performance budget.

## 6. RPG systems
- [ ] Character creation and eight starting classes.
- [x] Vigor, Endurance, Strength and Dexterity attributes with Sanctuary-only Soul Essence levelling and weapon scaling.
- [ ] Intelligence, Faith, Arcana and Mind.
- [x] Soul Essence reward, death-drop and recovery prototype.
- [x] Soul Essence level-up cost curve and attribute spending prototype.
- [x] Three-charge healing flask, 45 HP restore and Sanctuary refill prototype.
- [ ] Inventory, equipment, equip load and broader consumables.
- [ ] Weapon/armour upgrades, infusions, relics and talismans.
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
- [ ] HUD, inventory, map, quest journal and settings.
- [ ] Remappable controls, sensitivity, subtitles and readability options.

## 9. Android optimisation and release
- [ ] Profile CPU/GPU/memory on target Android hardware.
- [ ] LODs, occlusion, texture compression and object pooling.
- [ ] Graphics presets, frame pacing and thermal testing.
- [ ] Save migration and regression test suite.
- [ ] Signed release APK and versioned source archive.
- [ ] Verify APK install/launch and upload link before release announcement.
