# Production roadmap

Complete a small, tested vertical slice before expanding into a large world. Do not mark work complete until it has been run and verified.

## 0. Engine and project foundation
- [x] Godot 4 project configuration and main scene.
- [x] Mobile-compatible GL Compatibility renderer baseline.
- [x] Runtime graybox arena.
- [x] Placeholder player, enemy and touch HUD.
- [ ] Validate project import and parser in Godot 4.x.
- [ ] Configure Android export preset and test install on target hardware.
- [ ] Add automated headless import/startup check to CI.

## 1. Player controller and camera
- [x] Basic third-person movement and gravity.
- [x] Basic sprint and stamina drain.
- [x] Basic dodge action and stamina cost.
- [x] Basic melee range/damage prototype.
- [ ] Touch joystick and camera drag.
- [ ] Camera collision, sensitivity and lock-on target switching.
- [ ] Jump, fall, landing and traversal.
- [ ] Animation-driven locomotion and combat state integration.

## 2. Combat foundation
- [ ] Weapon data resources and weapon-specific movesets.
- [ ] Attack startup/active/recovery windows and hitbox timing.
- [ ] Light, heavy, charged, sprint and jump attacks.
- [ ] Dodge i-frames, backstep, block, guard break and parry.
- [ ] Riposte, backstab, stagger, poise and hyperarmour.
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
- [ ] State-machine AI: idle, patrol, detect, investigate, chase, combat, attack, defend, dodge, stagger, retreat, death.
- [ ] NavigationAgent3D pathfinding and obstacle avoidance.
- [ ] Telegraph-based attack selection and recovery windows.
- [ ] Group encounters, ranged enemies, elites and mini-bosses.
- [ ] Boss framework with phase data, arena boundaries and rewards.

## 5. First vertical slice — Ashen Kingdom
- [ ] Graybox route, combat spaces and traversal landmarks.
- [ ] Finished art pass for one compact region.
- [ ] Three regular enemy archetypes and one elite.
- [ ] One Sanctuary checkpoint and rest/death/recovery loop.
- [ ] One NPC, dialogue system and branching quest.
- [ ] One multi-phase region boss.
- [ ] Playtest, difficulty tuning and performance budget.

## 6. RPG systems
- [ ] Character creation and eight starting classes.
- [ ] Vigor, Endurance, Strength, Dexterity, Intelligence, Faith, Arcana and Mind.
- [ ] Soul Essence levelling and death-drop recovery.
- [ ] Inventory, equipment, equip load and consumables.
- [ ] Weapon/armour upgrades, infusions, relics and talismans.
- [ ] Spell schools, focus resource and status effects.
- [ ] Versioned save/load and backup/restore tests.

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
