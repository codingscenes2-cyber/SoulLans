# Android build and QA checklist

## Development setup
- Godot 4.x matching the project version.
- Godot export templates installed.
- Android SDK and platform tools.
- OpenJDK 17 for the Godot 4.3 export pipeline.
- Android SDK platform-tools, Build-Tools 34.0.0, Platform 34 and Command-line Tools. NDK/CMake are not needed for this prebuilt-template APK export.
- Android export preset is committed in `export_presets.cfg`; local credentials remain outside version control.

## Automated Android debug export

Latest PBR build: [GitHub Actions run #14 (0.3.0)](https://github.com/codingscenes2-cyber/SoulLans/actions/runs/42567309495). It downloads six 1K CC0 PBR maps (diffuse, OpenGL normal, roughness for Concrete Floor 01 and Rock Wall 17), imports them with Godot, exports an ARM64 APK and runs explicit `apksigner verify --verbose --print-certs`. The build is debug-signed using an ephemeral runner key and cannot update installs signed by a different key. It is not device-verified. Godot 4.3 setup requirements are documented in the [official Android export guide](https://docs.godotengine.org/en/4.3/tutorials/export/exporting_for_android.html), and command-line export uses the preset name with `--export-debug` as described in the [command-line tutorial](https://docs.godotengine.org/en/4.3/tutorials/editor/command_line_tutorial.html).

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
The 0.3.0 APK from run #14 has SHA-256 `f11a09afd29e40c3be7ec429116a257862c13bd7af23c81b06d5d7af803b15cc`, size 32,062,133 bytes, and passed explicit apksigner verification. It contains the six downloaded 1K CC0 PBR maps. The APK uses a newly generated debug key; do not uninstall the existing app or expect an in-place update until a persistent signing key/save migration plan is configured. Record device/OS, visual test results, known issues and performance after install. Do not label a debug build as release-ready. Never publish a fabricated or unverified download URL.


## Automated save-system regression checks

The GitHub Actions workflow runs `tests/game_state_tests.gd` after the headless scene launch. It checks first/second save writes, backup creation, invalid-primary recovery, version-1 save defaults, Soul Essence death-drop and recovery distance, and attribute levelling. A passing headless suite does not prove Android storage interruption behavior or device gameplay.
\n\n## Signing key continuity\n\nThe 0.3.0 build used an ephemeral runner-generated debug keystore that was not retained. Its private key cannot be reconstructed from the APK. The export workflow now requires a persistent keystore supplied through repository Actions secrets and refuses to generate random signing keys. See [SIGNING_KEY_MIGRATION.md](SIGNING_KEY_MIGRATION.md). The first build using a newly provisioned persistent key will still require a one-time reinstall if its certificate differs from 0.3.0; back up saves first.\n