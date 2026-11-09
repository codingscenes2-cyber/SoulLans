#!/usr/bin/env bash
set -euo pipefail

# Run locally in Termux, Linux, macOS, or WSL. Never commit the generated files.
KEYSTORE_PATH="${1:-soulland-upload.jks}"
ALIAS="soulland-upload"

if ! command -v keytool >/dev/null 2>&1; then
  echo "keytool is required. Install a JDK (Termux: pkg install openjdk-17)." >&2
  exit 1
fi

if [ -e "$KEYSTORE_PATH" ]; then
  echo "Refusing to overwrite existing keystore: $KEYSTORE_PATH" >&2
  exit 1
fi

echo "Create the permanent SOUL LAND Android signing key."
echo "Use a strong password and store it in a password manager."
keytool -genkeypair -v \
  -keystore "$KEYSTORE_PATH" \
  -storetype JKS \
  -keyalg RSA \
  -keysize 3072 \
  -validity 10000 \
  -alias "$ALIAS"

BASE64_PATH="${KEYSTORE_PATH}.base64"
base64 < "$KEYSTORE_PATH" | tr -d '\n' > "$BASE64_PATH"
chmod 600 "$KEYSTORE_PATH" "$BASE64_PATH"

echo
echo "Keystore created: $KEYSTORE_PATH"
echo "Base64 secret file: $BASE64_PATH"
echo
echo "Certificate fingerprint (record this outside Git):"
keytool -list -v -keystore "$KEYSTORE_PATH" -alias "$ALIAS" | grep -E "SHA256:"
echo
echo "Add these GitHub Actions repository secrets in Settings > Secrets and variables > Actions:"
echo "  SOULLAND_KEYSTORE_BASE64  <- contents of $BASE64_PATH"
echo "  SOULLAND_KEYSTORE_PASSWORD <- keystore password you entered"
echo "  SOULLAND_KEY_ALIAS         <- $ALIAS"
echo "  SOULLAND_KEY_PASSWORD      <- key password (same as keystore password if you chose that)"
echo
echo "Back up BOTH the .jks file and its passwords in two secure locations."
echo "Do not upload either file to the repository or paste secrets into ChatGPT."
