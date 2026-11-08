# Android build and QA checklist

## Development setup
- Godot 4.x matching the project version.
- Godot export templates installed.
- Android SDK and platform tools.
- JDK version supported by the selected Godot release.
- Android export preset configured locally; never commit signing keys or passwords.

## Smoke tests
1. Project imports without parse errors.
2. Main scene launches.
3. Player can move, turn and collide with the arena.
4. Sprint drains stamina and stamina regenerates.
5. Dodge spends stamina and has expected recovery.
6. Attack damages the training enemy only in range.
7. Enemy detects, approaches and attacks the player.
8. Touch controls respond and do not block unrelated UI.
9. Pause/resume and app background/foreground do not corrupt state.
10. Android install, launch, orientation and safe-area layout are verified.

## Performance checks
Measure frame pacing, CPU/GPU time, memory, thermal behaviour and battery drain on actual target hardware. Test multiple graphics settings. Do not assert a frame-rate target until measured.

## Release gates
A release APK must be a real signed export, installed and launched on a device. Record version, build commit, device/OS, test results, known issues, file size and SHA-256. Do not label a debug build as release-ready. Never publish a fabricated or unverified download URL.
