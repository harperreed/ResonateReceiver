#!/bin/bash
set -e

# Get version from git tag (e.g., v0.1.2 -> 0.1.2)
# Falls back to Info.plist if no git tag is found
if git describe --tags --exact-match 2>/dev/null; then
    VERSION=$(git describe --tags --exact-match | sed 's/^v//')
    echo "Creating DMG for version ${VERSION} (from git tag)..."
else
    VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Info.plist)
    echo "Creating DMG for version ${VERSION} (from Info.plist)..."
fi

# Create DMG using hdiutil
DMG_NAME="ResonateReceiver-${VERSION}.dmg"
VOLUME_NAME="Resonate Receiver"

# Create temporary directory for DMG contents
TMP_DIR=$(mktemp -d)
cp -R ResonateReceiver.app "$TMP_DIR/"

# Create DMG
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TMP_DIR" -ov -format UDZO "$DMG_NAME"

# Clean up
rm -rf "$TMP_DIR"

echo "DMG created: $DMG_NAME"
