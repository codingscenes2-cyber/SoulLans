# Android signing continuity and migration

## Important: 0.3.0 signing key cannot be recovered

The 0.3.0 Android workflow generated `$HOME/.android/debug.keystore` on a temporary GitHub Actions runner using `keytool -genkeypair`. It did not upload or preserve that keystore as an artifact or repository secret. The APK contains the public signing certificate, not the private key. The original private key therefore cannot be reconstructed from the APK, and a different key cannot sign an in-place update to the installed 0.3.0 app.

Do not uninstall the installed 0.3.0 app until its save has been backed up or the user explicitly accepts losing it.

## Future stable signing key

The export workflow now refuses to generate a fresh random key. It requires these GitHub Actions repository secrets:

- `SOULLAND_KEYSTORE_BASE64`: Base64-encoded persistent JKS/PKCS12 keystore.
- `SOULLAND_KEYSTORE_PASSWORD`: keystore password.
- `SOULLAND_KEY_ALIAS`: signing key alias.
- `SOULLAND_KEY_PASSWORD`: private-key password.

Create a new permanent key on a trusted machine, keep a separate offline backup, and add the values under GitHub repository Settings → Secrets and variables → Actions. Never commit the keystore or passwords. This new key will stabilize future updates but will NOT match the old 0.3.0 certificate.

## Safe one-time migration

To move to the new persistent key, preserve the game save separately first. Then uninstall the old app only when the user has accepted the one-time reinstall and save restoration procedure. Install the first APK signed with the new persistent key. Every subsequent update can then install over it without changing signing identity.

## Verification

Every export must run `apksigner verify --verbose --print-certs`. Record the certificate SHA-256 digest in the release notes and compare it with the previous release before distributing an update.
