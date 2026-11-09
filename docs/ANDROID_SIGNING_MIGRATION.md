# Permanent Android signing-key migration

## Why this exists

The 0.3.0 APK was signed with an ephemeral GitHub runner debug key. That private key was not retained in the repository or build artifact, so a new certificate cannot update that installation in place.

This project will use one owner-controlled JKS key for all future Android builds. Once configured, keep it permanently: replacing it later will again break in-place updates.

## Create the key locally

Run the helper from a private folder on a trusted machine:

```bash
bash tools/create_android_signing_key.sh
```

It works on Linux, macOS, WSL and Termux with a JDK installed. Termux setup:

```bash
pkg update
pkg install openjdk-17
```

The script prompts for the distinguished name and passwords, creates a 3072-bit RSA JKS keystore, creates a base64 copy for GitHub Actions, and prints the certificate SHA-256 fingerprint. It refuses to overwrite an existing key.

## Configure GitHub Actions secrets

In the repository, open **Settings → Secrets and variables → Actions → New repository secret** and create:

| Secret | Value |
|---|---|
| `SOULLAND_KEYSTORE_BASE64` | Entire contents of the generated `.jks.base64` file |
| `SOULLAND_KEYSTORE_PASSWORD` | Keystore password |
| `SOULLAND_KEY_ALIAS` | `soulland-upload` |
| `SOULLAND_KEY_PASSWORD` | Private-key password |

Never paste these values into issues, commits, chat messages or workflow logs. The Android export workflow already refuses to sign if any secret is missing and validates the alias/password before export.

## Migration policy

1. Preserve the existing 0.3.0 installation and its save data until a migration build is ready.
2. The new key is a different certificate from the old ephemeral key. Android will reject an in-place update from 0.3.0.
3. Before the first install signed by the permanent key, back up the in-game save. Then uninstall the old app only when the user explicitly chooses to migrate.
4. Install the first permanent-key build and verify its certificate fingerprint with `apksigner`.
5. Keep the same JKS key for every future update. Back up the JKS and both passwords in separate secure locations.

**No replacement APK is being issued as part of key creation.** Signing setup is infrastructure; game-quality release gates remain separate.
