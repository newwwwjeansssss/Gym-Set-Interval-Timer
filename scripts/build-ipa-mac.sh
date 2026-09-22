#!/bin/bash
# Build a Release IPA for recipients to re-sign. No Apple account needed here.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ "$(uname -s)" != Darwin ]]; then
  echo "This build requires macOS + Xcode. Windows users: read docs/windows-iphone.md." >&2
  exit 1
fi
xcodebuild -version >/dev/null
DERIVED="${REST_DERIVED_DATA:-$ROOT/.build/release}"
xcodebuild -project "$ROOT/ios/RestTimer.xcodeproj" -scheme RestTimer \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED" CODE_SIGNING_ALLOWED=NO build
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/resttimer-ipa.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/Payload" "$ROOT/downloads"
cp -R "$DERIVED/Build/Products/Release-iphoneos/RestTimer.app" "$STAGE/Payload/"
# Never distribute provisioning profiles or signatures tied to a developer account.
find "$STAGE" -name embedded.mobileprovision -type f -delete
find "$STAGE" -name _CodeSignature -type d -prune -exec rm -rf '{}' +
TMP_IPA="$STAGE/RestTimer-resign-required.ipa"
(cd "$STAGE" && /usr/bin/zip -qry "$TMP_IPA" Payload)
cp "$TMP_IPA" "$ROOT/downloads/RestTimer-resign-required.ipa"
(cd "$ROOT/downloads" && shasum -a 256 RestTimer-resign-required.ipa > SHA256SUMS.txt)
echo "Created downloads/RestTimer-resign-required.ipa (requires recipient signing)."
