# Art, Character and Animation Production Roadmap

**Project:** SOUL LAND: THE FALLEN REALM  
**Engine:** Godot 4.3+ · **Target:** Android ARM64 first · **Renderer:** GL Compatibility  
**Status:** Production plan. The external models and animation packs below are candidates only; none are integrated until their files are imported, tested and committed.

This plan replaces the current primitive graybox presentation with a coherent authored dark-fantasy visual identity. Build a small number of excellent reusable assets, prove them in the Ashen Kingdom vertical slice, profile them on Android, then scale the pipeline.

## 0. Honest visual diagnosis

The latest in-game screenshot exposes these production blockers:

- Player and enemies are capsule/primitive stand-ins: no readable anatomy, face, armour, hands, weapon grip or character identity.
- The ground's procedural noise is high-contrast, stretched and repetitive. It reads as static, not stone, soil or ash.
- Walls and props share placeholder treatment; masonry, wood, metal, cloth, leather, mud and vegetation are not visually distinct.
- The scene is under-lit. Large areas disappear into black; the horizon lacks atmosphere and depth.
- The environment lacks convincing scale, authored landmark composition, debris layering and foreground/midground/background depth.
- The HUD is functional prototype UI, not final art direction.
- There is no production animation system. Movement and combat rely on controller logic and primitive visuals rather than rigged characters and animation-driven actions.

**Quality rule:** adding more primitive meshes or another full-screen noise texture is not an acceptable art upgrade. Each asset must improve material readability, silhouette, animation, lighting or world composition.

## 1. Visual target and art bible

### 1.1 Chosen direction

Aim for **grounded stylized realism suitable for a mobile Soulslike**: believable proportions, weathered physically based materials, strong silhouettes, restrained colour, readable combat animation and dramatic but legible lighting. Do not chase photorealism at the expense of frame rate or clarity.

Palette:
- Ashen Kingdom: cold slate, charcoal, desaturated soil, dead umber wood and tarnished iron.
- Faction identity: deep oxblood cloth, muted brass and small warm ember lights.
- Magic: reserve saturated colour for readable spell effects and important story objects.
- Characters: darker values than the environment, but armour edges, cloth layers and weapon silhouettes must remain readable.

Create a reference board before production: hero proportions and armour layers; Hollow and Shield Guard silhouettes; Ashen stone, soil, iron, leather and cloth; overcast daylight, ember-lit interiors, night Sanctuary and boss arena; HUD hierarchy and touch-safe zones. Use references for direction only—never copy protected game assets, characters, UI, maps or animations.

## 2. Asset pipeline and technical standards

### 2.1 Authoring and import
- Use Blender for mesh cleanup, UVs, skeleton inspection, LOD generation and GLB export.
- Prefer glTF 2.0 / GLB for Godot runtime assets. Keep editable Blender sources in clearly named source folders, not duplicated into runtime exports.
- Apply transforms, correct scale and forward axis, consistent origins and named materials before export.
- Use one humanoid skeleton convention for player, humanoid enemies and NPCs wherever licence and topology allow.
- Keep source mesh, textures, rig and clips grouped by asset ID.
- Do not ship unused source files, huge 4K maps or duplicate material variants in the APK.
- Import one representative asset and validate it in Godot before batch-importing a pack.

### 2.2 PBR material and texture standard

For important surfaces use a coherent set where available:
- Base colour / albedo.
- Tangent-space normal map (verify OpenGL vs DirectX green-channel convention).
- Roughness.
- Ambient occlusion where useful.
- Metallic only for genuinely metallic surfaces.
- Height/displacement only when mobile cost is justified.

Resolution policy:
- 512 px or 1K for small/background props.
- 1K for most mobile environment materials.
- 2K for hero, boss, large hero props or prominent unique surfaces only when profiling permits.
- 4K is not the default mobile target.

Rules:
- Use real UV/world scale. Never stretch one noise texture over long roads, walls or unrelated objects.
- Use distinct materials for ash/dirt, stone, masonry, wood, leather, cloth and iron.
- Break tiling with controlled albedo variation, decals, vertex colour and mesh variation.
- Keep roughness believable; do not make all stone glossy or all metal black.
- Add normal detail only after base colour and lighting read correctly.
- Use texture atlases for small props where practical.
- Set Android texture compression and mipmaps; verify import settings in the exported APK.

### 2.3 Initial mobile budgets (must be measured on hardware)

These are starting targets, not claims about current performance:
- Main hero: 15k–30k triangles at LOD0; LOD1 around 8k; LOD2 around 3k–4k.
- Regular humanoid: 10k–22k triangles at LOD0.
- Boss: 25k–40k triangles at LOD0, with simplified LODs.
- Small props: generally below 1k triangles; instance repeated rocks, rubble and vegetation.
- Start with 4–8 visible animated humanoids in ordinary encounters until profiling proves more safe.
- Keep skinned mesh material count and draw calls low; share materials/skeletons where possible.
- Prefer one main shadow-casting directional light; use local lights selectively.
- Initial acceptance: stable 30 FPS in representative combat on target phone, without repeated thermal throttling or memory growth. Add 60 FPS only if measured.

## 3. External asset sourcing and licensing

Use original work or sources whose **exact asset page** permits intended use. Re-check the exact pack licence at download time; never infer one pack's licence from another pack by the same publisher.

### Priority candidates

1. **Poly Haven** — CC0 PBR textures, HDRIs and environment models. First stop for stone, soil, rock, metal and lighting resources.  
   https://polyhaven.com/license · https://polyhaven.com/textures · https://polyhaven.com/models

2. **ambientCG** — CC0 PBR materials, HDRIs and models. Use for seamless surface maps and material variation.  
   https://docs.ambientcg.com/license/ · https://ambientcg.com/

3. **Quaternius Universal Base Characters** — six humanoid base characters, animation-friendly topology and humanoid rig; the page states CC0 and provides glTF/FBX. Evaluate the art style and proportions before adopting.  
   https://quaternius.com/packs/universalbasecharacters.html

4. **Quaternius Universal Animation Library** — reusable humanoid locomotion/action clips. Validate the exact release, rig naming and retargeting in Godot before adopting.  
   https://quaternius.itch.io/universal-animation-library

5. **Godot Asset Library listing for Universal Animation Library** — alternative distribution/reference listing; check current package status and version notes.  
   https://store.godotengine.org/asset/quaternius/universal-animation-library/

### Licensing gate
For every imported asset record exact name, author, original URL, download date, licence/version, attribution requirements and modifications in `assets/ASSET_CREDITS.md`. Save licence text/snapshot with the record. Confirm modification, redistribution inside an APK and commercial rights if future commercial release is possible. Check model, texture, rig and animation licences separately. Never rip content from commercial games. If terms are unclear, do not ship it.

These are candidate sources, not assets already downloaded or integrated. Do not claim a pack is included until its files are committed and imported successfully.

## 4. Character model production

### C1 — Player hero
Deliver one fully rigged hero, not a capsule:
- Distinct head, torso, arms, hands, legs, boots and armour silhouette.
- Layered worn armour: padded underlayer, leather straps, metal plates, cloth/tabard, practical gloves and boots.
- Face/head or helmet readable at gameplay camera distance.
- Correctly sized Ashen Iron Sword and dagger with believable hand alignment.
- Shared humanoid skeleton and clean skin weights.
- One 1K–2K texture set with material separation; avoid needless unique materials.
- LOD0/1/2; keep simple gameplay collision separate from render mesh.

Acceptance: hero reads at normal gameplay camera distance; feet contact ground; hands grip weapons; no visible mesh tearing during locomotion/combat clips; Android performance remains within measured budgets.

### C2 — Enemy roster
Build distinct silhouettes and combat readability:
- Training Hollow: ragged damaged humanoid, simple weapon, readable wind-up.
- Ashen Watch Shield Guard: layered armour, large readable shield, visible guard-open state and weak-point cue.
- Ashen ranged enemy: bow or catalyst, clear projectile wind-up.
- Ashen elite: heavier armour and a distinct weapon profile.
- First-region boss: unique proportions, weapon, armour, arena scale and signature silhouette.

Do not create five enemies by recolouring one model. Reuse skeletons/material atlases where sensible, but change silhouette, gear, proportions and animation timing.

### C3 — NPC and boss quality
- One named Ashen Kingdom NPC with face/helmet, idle pose, conversation gestures and quest-state variants.
- One boss with custom head/torso/weapon, phase-specific visual cues, intro/transition/death sequences.
- Boss attacks must remain readable from the camera and not be hidden by HUD.

## 5. Animation production roadmap

### A0 — Skeleton and retargeting proof
Before making dozens of clips:
- Choose base skeleton; inspect bone names, hierarchy, rest pose and scale.
- Import one test GLB with idle, walk and attack.
- Retarget to selected hero and one enemy.
- Confirm root orientation, foot contact, weapon grip, bone roll and playback speed.
- Start with in-place locomotion; let the existing character controller own translation. Use root motion only for authored cinematics/boss actions when synchronisation is reliable.
- Create a test scene to preview every clip.

Gate: no bulk animation import until test clips retarget and play correctly in Godot.

### A1 — Player locomotion
Required clips:
- Idle breathing, relaxed combat idle and lock-on combat idle.
- Start/stop walk; walk forward/back/strafe.
- Jog/run, sprint, sprint start and stop.
- Turn-in-place left/right.
- Eight-direction dodge/roll or directional dodge set.
- Jump start, airborne, falling, landing and recovery.
- Lock-on strafe and backpedal.
- Weapon-ready and weapon-lowered transitions.

Implementation:
- AnimationTree state machine with blend spaces for locomotion.
- Blend by movement speed and direction.
- Smooth transitions; prevent idle/run snapping.
- Footstep timing events drive surface-dependent audio.
- Physics remains authoritative; animation must not cause drifting or speed changes.

### A2 — Player combat
Required clips:
- Sword light combo 1/2/3.
- Heavy, charged heavy, sprint and jump attacks.
- Dagger fast combo and dagger heavy.
- Block enter/hold/release.
- Parry start/success/fail and riposte.
- Front/back/left/right hit reactions.
- Stagger, guard break, knockdown and get-up.
- Death and respawn.
- Healing flask, interaction and weapon swap.

Integration:
- Animation events open/close weapon hitboxes during authored active frames.
- Apply damage once per valid target per attack, not every frame.
- Attack buffering/cancel windows are data-driven.
- Stamina, poise, recovery and invulnerability remain explicit gameplay data.
- Parry visual contact, sound, enemy stagger and input timing must agree.
- Animation playback alone is never proof an attack hit.

### A3 — Enemy animation
Every enemy needs idle, alert, investigate, walk, chase, turn, wind-up, attack, recovery, block/guard where appropriate, hit reactions, stagger, guard break and death.
- Shield Guard: raise, brace, absorb, shield break/open and exposed recovery.
- Ranged enemy: aim, charge, release and reload/recovery.
- Boss: intro, phase transition, signature tells, poise break and death.

### A4 — Animation polish
- Blend upper-body attacks over lower-body movement only where clips/rig support it.
- Remove foot sliding and weapon clipping.
- Tune playback speed to movement and attack timings.
- Add subtle breathing/weight shifts, not exaggerated constant motion.
- Keep hit reactions readable; do not lock input longer than designed.
- Reduce distant animation update rate only after profiling.

## 6. Environment art: Ashen Kingdom rebuild

### E1 — Replace ground and walls first

This is the most visually damaging current issue:
- Remove stretched high-contrast procedural noise from the main floor.
- Use separate PBR surfaces for compacted ash/dirt path, rocky soil, weathered stone, broken masonry and damp patches.
- Correct UV scale so grains and stones have believable world dimensions.
- Add normal/roughness maps, subtle albedo variation and small decal overlays.
- Build road edges, shallow ruts, scattered stones, cracked slabs and footpath wear.
- Separate wall materials from ground materials; add mortar seams, broken edges and dirt accumulation.

Acceptance: no obvious texture stretch from normal camera; no giant repeating pattern in first 30 seconds; material identity is clear at gameplay distance.

### E2 — Modular architecture kit
Build reusable intact/broken wall segments, corners, caps, pillars, arches, lintels, gate frames/leaves/hinges/chains, barricades, stairs, ramps, retaining walls, floor slabs, rubble piles, broken columns, foundations, Sanctuary altar, lanterns, braziers, banners and signposts.

Use modular snap dimensions and consistent pivots. Collision meshes must be simpler than render meshes.

### E3 — Landscape composition
Rebuild the route into deliberate beats:
1. Sanctuary combat courtyard.
2. Broken outer gate with a strong silhouette.
3. Narrow road with a landmark and safe sightline.
4. Ruined watch post and optional loot nook.
5. Small encounter space with cover and flanking route.
6. NPC/quest landmark.
7. Sealed boss approach and arena reveal.

Add foreground rubble, midground structures and distant silhouettes. Use sky/fog depth to hide world bounds. Avoid empty black horizons.

### E4 — Nature and atmosphere
- Dead trees with proper branch silhouettes, roots and varied scale.
- Ash drifts, dead grass, sparse thorn bushes and ground debris.
- Wind-driven cloth, ash motes and embers in controlled volumes.
- Sky/ambient environment, directional sunlight/moonlight and distance fog.
- Warm local lights at lanterns/Sanctuary; avoid many shadow-casting lights.
- Add weather only after baseline lighting is stable.

## 7. Lighting, VFX and audio

Lighting:
- Establish consistent exposure and sky/ambient contribution so shadows retain detail.
- One main directional light with tuned shadow distance/resolution.
- Bake static lighting where supported; keep dynamic lights selective.
- Fog provides depth, not a substitute for missing geometry.
- Check black levels on a real phone; armour and terrain must not merge into one silhouette.

VFX:
- Sword trails follow weapon orientation and disappear quickly.
- Material-specific impacts: sparks for metal, dust for stone/soil, restrained blood.
- Concise parry flash/sound; Shield Guard break cue; distinct boss telegraphs.
- Strict particle counts and overdraw limits.

Audio:
- Footsteps for stone, soil/ash, wood and metal.
- Layered weapon whoosh, impact, block, parry and guard-break.
- Armour movement, enemy vocalisations, Sanctuary ambience and distant wind.
- Original/licensed audio only, with provenance register.

## 8. HUD and camera art pass
- Keep combat information, redesign hierarchy and spacing.
- Touch-safe zones for notches and wide screens; scale by viewport.
- Attack buttons must not cover enemies or boss telegraphs.
- Add concise health/stamina/flask feedback and contextual prompts.
- Camera shoulder offset, collision smoothing, lock-on framing and sensitivity settings.
- Verify landscape rotation, safe areas and UI scaling on actual target phone.
- No ornate decoration until controls/readability are reliable.

## 9. Milestones and deliverables

### 0.3 — Visual foundation
Replace stretched floor material; establish sky/exposure/directional light/shadow/fog; import one CC0 PBR stone/soil/metal set; build small modular ruin kit and test one prop; record provenance; provide before/after screenshots.
**Exit:** route no longer reads as flat grey primitives; surfaces are distinct and scene is legible.

### 0.4 — Hero and locomotion
Integrate one rigged hero; prove skeleton retargeting; add idle/walk/run/sprint/turn/dodge/jump/fall/land; build AnimationTree; align weapon grip; add LODs/mobile materials.
**Exit:** player capsule is gone; locomotion blends smoothly and foot contact is acceptable.

### 0.5 — Combat animation
Add sword combo, heavy, dodge, block, parry, hit, stagger, flask and death; animation-synchronised hit windows; animate Hollow and Shield Guard; add impact/parry/guard-break VFX/audio.
**Exit:** player-vs-two-enemy fight is readable/responsive with no major animation/hitbox mismatch.

### 0.6 — Ashen Kingdom environment
Rebuild courtyard/gate/road/encounter with modular assets; add landmark props, debris, cloth, vegetation and material variation; lighting/fog/sky/ambience; proper Sanctuary model.
**Exit:** continuous short route feels like a designed level, not an empty test map.

### 0.7 — NPC, ranged enemy and boss
Add fully modelled NPC and branching interaction; ranged enemy animation set; first boss model, arena, multi-phase animations and effects.
**Exit:** polished first-region quest and boss loop.

### 0.8 — Mobile polish/performance
LODs, compression, occlusion, instancing, draw-call reduction, graphics settings and frame pacing; sustained-play thermal profile; touch/camera/save/resume/orientation regressions.
**Exit:** stable, repeatable 30 FPS in representative combat on target device; no critical crash or save loss.

### 0.9 — Vertical-slice candidate
Complete route, NPC quest, enemies, Sanctuary, boss and reward loop; visual consistency, animation, VFX/audio and HUD; QA, clean install, upgrade install, save migration, release signing.
**Exit:** only announce after device QA and licence audit.

## 10. Definition of done for every asset

An asset is not done merely because it appears in a scene. It must pass:
- Licence/provenance recorded.
- Correct scale, pivot, forward direction and collision.
- No missing textures/materials or broken normal maps.
- Correct LODs and Android texture compression.
- No visible rig deformation or retargeting defects.
- Performance measured in actual scene.
- Screenshot/capture at gameplay camera distance.
- Tested in exported Android build, not editor alone.

## 11. Immediate implementation order

1. Remove stretched noise from road/floor; author separate ash, soil and stone PBR materials.
2. Establish sky, exposure, directional light, shadow distance and fog.
3. Import one modular ruin set and one real prop; validate scale, collision and texture import.
4. Import one Quaternius humanoid base character; prove GLB skeleton retargeting in Godot.
5. Import Universal Animation Library test clips; prove idle/walk/attack on that skeleton.
6. Build hero locomotion before expanding enemy count.
7. Animate Hollow and Shield Guard; wire animation events to hit windows.
8. Replace graybox props in one small showcase area.
9. Export Android, compare identical camera views and profile before adding more assets.

**No milestone is complete on export success alone.** Require scene validation, visual evidence, device performance checks and provenance.
