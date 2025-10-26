#!/bin/bash
set -e

# Get version from Info.plist
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Info.plist)
echo "Creating DMG for version ${VERSION}..."

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
