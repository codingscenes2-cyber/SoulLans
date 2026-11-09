# Android build and QA checklist

## Development setup
- Godot 4.x matching the project version.
- Godot export templates installed.
- Android SDK and platform tools.
- OpenJDK 17 for the Godot 4.3 export pipeline.
- Android SDK platform-tools, Build-Tools 34.0.0, Platform 34 and Command-line Tools. NDK/CMake are not needed for this prebuilt-template APK export.
- Android export preset is committed in `export_presets.cfg`; local credentials remain outside version control.

## Automated Android debug export

Successful build: [GitHub Actions run #6](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42565383797). It installs matching Godot 4.3 export templates, Java 17 and required Android SDK packages, generates an ephemeral debug keystore, exports `SOUL_LAND_FALLEN_REALM-debug.apk`, verifies the APK signature, calculates SHA-256 and uploads the APK plus checksum as a 14-day artifact. The build is debug-signed, not release-signed, and is not device-verified. Godot 4.3 setup requirements are documented in the [official Android export guide](https://docs.godotengine.org/en/4.3/tutorials/export/exporting_for_android.html), and command-line export uses the preset name with `--export-debug` as described in the [command-line tutorial](https://docs.godotengine.org/en/4.3/tutorials/editor/command_line_tutorial.html).

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
14. [ ] Android install, launch, orientation and safe-area layout are verified on the target device.
15. [ ] Test touch controls, courtyard route, enemy encounters, save/restore, frame pacing and crash-free play.

## Performance checks
Measure frame pacing, CPU/GPU time, memory, thermal behaviour and battery drain on actual target hardware. Test multiple graphics settings. Do not assert a frame-rate target until measured.

## Release gates
The current debug APK has SHA-256 `bf4c9db464c10652f7b6627f45e049573a52abecd707801a24e537c7e7f0221e` and was exported from commit `f70b3da0b6c90f07ead7fd1090a83ffc8205058d`. Install and launch it on the target device, then record device/OS, test results, known issues and performance. Do not label a debug build as release-ready. Never publish a fabricated or unverified download URL.


## Automated save-system regression checks

The GitHub Actions workflow runs `tests/game_state_tests.gd` after the headless scene launch. It checks first/second save writes, backup creation, invalid-primary recovery, version-1 save defaults, Soul Essence death-drop and recovery distance, and attribute levelling. A passing headless suite does not prove Android storage interruption behavior or device gameplay.
