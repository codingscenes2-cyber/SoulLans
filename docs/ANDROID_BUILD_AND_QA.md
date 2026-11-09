# Android build and QA checklist

## Development setup
- Godot 4.x matching the project version.
- Godot export templates installed.
- Android SDK and platform tools.
- OpenJDK 17 for the Godot 4.3 export pipeline.
- Android SDK platform-tools, Build-Tools 34.0.0, Platform 34 and Command-line Tools. NDK/CMake are not needed for this prebuilt-template APK export.
- Android export preset is committed in `export_presets.cfg`; local credentials remain outside version control.

## Automated Android debug export

Latest PBR build: [GitHub Actions run #12 (0.3.0 source candidate)](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42567132362). It downloads six 1K CC0 PBR maps (diffuse, OpenGL normal, roughness for Concrete Floor 01 and Rock Wall 17), imports them with Godot, and exports an ARM64 APK. Explicit apksigner verification is added to the next workflow run. The build is debug-signed using an ephemeral runner key and cannot update installs signed by a different key. It is not device-verified. Godot 4.3 setup requirements are documented in the [official Android export guide](https://docs.godotengine.org/en/4.3/tutorials/export/exporting_for_android.html), and command-line export uses the preset name with `--export-debug` as described in the [command-line tutorial](https://docs.godotengine.org/en/4.3/tutorials/editor/command_line_tutorial.html).

## Smoke tests
1. Project imports without parse errors.
2. Main scene launches.
3. Player can move, turn and collide with the arena.
4. Sprint drains stamina and stamina regenerates.
5. Dodge spends stamina and has expected recovery.
6. Attack damages the training enemy only in range.
7. Enemy detects, approaches and attacks the player.
8. Touch controls respond and do not block unrelated UI.
9. Shield Guard blocks frontal damage, opens after two pressured hits, and takes full damage during the guard-break window.
10. Heavy attack consumes more stamina and causes greater poise damage than light attack.
11. Parry during the enemy telegraph staggers the attacker; a mistimed parry does not.
12. Touch buttons remain reachable at the target device resolution.
13. Pause/resume and app background/foreground do not corrupt state.
14. [ ] Android install, sensor-landscape auto-rotation and safe-area layout are verified on the target device.
15. [ ] Test touch controls, courtyard route, enemy encounters, save/restore, frame pacing and crash-free play.

## Performance checks
Measure frame pacing, CPU/GPU time, memory, thermal behaviour and battery drain on actual target hardware. Test multiple graphics settings. Do not assert a frame-rate target until measured.

## Release gates
The 0.3.0 PBR source candidate artifact from run #12 has SHA-256 `6a9dca978db374546413b001d4bf18be40b98a6d870d8ca1ebeb13a10751e06c` and size 32,062,133 bytes. It was built before the version-name bump to 0.3.0; run #13 is the versioned rebuild with explicit signature verification. The APK uses a newly generated debug key; do not uninstall the existing app or expect an in-place update until a persistent signing key is configured. Record device/OS, visual test results, known issues and performance after install. Do not label a debug build as release-ready. Never publish a fabricated or unverified download URL.


## Automated save-system regression checks

The GitHub Actions workflow runs `tests/game_state_tests.gd` after the headless scene launch. It checks first/second save writes, backup creation, invalid-primary recovery, version-1 save defaults, Soul Essence death-drop and recovery distance, and attribute levelling. A passing headless suite does not prove Android storage interruption behavior or device gameplay.
