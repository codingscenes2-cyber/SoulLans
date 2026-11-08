# Character assets and animation pipeline

## Asset pipeline
Use original or properly licensed assets only. Record asset name, creator, source, licence, modification and attribution in ASSET_CREDITS.md.

Preferred interchange format: glTF 2.0 / GLB. Keep consistent world scale, apply transforms before export, separate render meshes from collision meshes, use sensible pivots, and validate materials in Godot.

### Character asset requirements
- Player: humanoid base mesh, skeleton, material slots, head/face options and armour attachment points.
- Enemies: shared humanoid rig where practical; creature rigs may be separate.
- NPCs: compatible skeletons and reusable animation libraries where possible.
- Weapons: separate meshes with grip/origin markers and collision/hitbox attachment points.
- Bosses: bespoke silhouette, rig, attack telegraphs and phase-change presentation.

### Environment asset requirements
Modular architecture, terrain, cliffs, rocks, vegetation, props, decals, doors, destructibles and landmark meshes. Use collision proxies, LODs and compressed textures. Build one polished Ashen Kingdom region before producing distant regions.

## Player animation list
Idle and variations; start/stop; walk, jog, sprint and turn-in-place; jump, fall and land; directional dodges and backstep; weapon-specific light, heavy and charged attacks; sprint and jump attacks; combos; block, parry, riposte and backstab; hit reactions, stagger, knockdown, get-up and death; item use and spell casting.

## Enemy animation list
Idle, patrol, alert, investigate, locomotion, turn, attack windups, attack releases, recovery, block, dodge, stagger, knockdown, get-up, retreat and death.

## Boss animation list
Arena entrance, locomotion, phase transitions, signature attacks, punish windows, stagger, death and reward sequence.

## Godot implementation
- Use AnimationPlayer for authored clips and AnimationTree for blending/state transitions.
- Start with a locomotion blend space and explicit combat state machine.
- Drive hitbox activation from authored animation events or deterministic combat timers.
- Keep damage timing synchronized with attack active frames.
- Separate visual animation state from authoritative combat state.
- Do not use placeholder capsule meshes as final characters.
- Do not claim animation complete until transitions and combat timing are tested in-game.

## Android constraints
Use LODs, skeleton and material budgets, compressed textures, limited real-time lights and measured animation complexity. Profile on actual target hardware before increasing scene complexity.
