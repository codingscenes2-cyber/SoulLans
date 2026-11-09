# Asset credits and licensing register

No third-party art, animation, audio or VFX asset may be committed without recording its provenance and licence here.

| Asset / pack | Creator | Source | Licence | Changes | Attribution |
|---|---|---|---|---|---|
| Prototype primitives | Project code | Generated at runtime | Original code | N/A | None |
| Ashen Kingdom arches, rocks, dead trees, banners and noise stone texture | Project code (`scripts/ashen_world_art.gd`) | Generated at runtime with Godot FastNoiseLite / NoiseTexture2D | Original procedural code | Runtime geometry and seamless noise albedo | None |
| Concrete Floor 01 PBR texture set (1K diffuse, OpenGL normal, roughness) | Rob Tuytel / Poly Haven | https://polyhaven.com/a/concrete_floor_01 | CC0 1.0 | Downloaded during Android CI build; used for ground and road surfaces | Not required; Poly Haven source credit in-game planned |
| Rock Wall 17 PBR texture set (1K diffuse, OpenGL normal, roughness) | Dimitrios Savva / Poly Haven | https://polyhaven.com/a/rock_wall_17 | CC0 1.0 | Downloaded during Android CI build; used for stone architecture and props | Not required; Poly Haven source credit in-game planned |
| Quaternius Universal Base Characters — Superhero Male (rigged humanoid base) | Quaternius | https://quaternius.com/packs/universalbasecharacters.html | CC0 1.0 | Bundled as `assets/characters/ashen_hero.glb`; source skeleton retained and material override applied at runtime | Not required; credited in game and source docs |
| Quaternius Universal Animation Library Standard (43 clips) | Quaternius | https://quaternius.com/packs/universalanimationlibrary.html | CC0 1.0 | Fetched from a pinned mirror commit during CI; 43 clips / 8,385 animation channels merged onto the matching 66-node hero rig by name; generated runtime GLB is build output | Not required; credited in game and source docs |

Rules:
- Prefer original assets or licences that explicitly permit use in a commercial game.
- Keep source links and licence copies with the project documentation.
- Do not rip assets, animations, sounds, maps or UI from commercial games.
- Verify redistribution rights before packaging assets into an APK.
