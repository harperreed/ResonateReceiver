#!/bin/bash
# ABOUTME: Builds ResonateReceiver.app bundle from Swift Package
# ABOUTME: Run this script to create a proper macOS app bundle

set -e

echo "🔨 Building ResonateReceiver..."
swift build

echo "📦 Creating app bundle..."
rm -rf ResonateReceiver.app
mkdir -p ResonateReceiver.app/Contents/MacOS
mkdir -p ResonateReceiver.app/Contents/Resources
mkdir -p ResonateReceiver.app/Contents/Frameworks

echo "📋 Copying Info.plist..."
cp Info.plist ResonateReceiver.app/Contents/

echo "🎯 Copying executable..."
cp .build/arm64-apple-macosx/debug/ResonateReceiver ResonateReceiver.app/Contents/MacOS/

echo "📚 Copying frameworks..."
if [ -d .build/arm64-apple-macosx/debug/FLAC.framework ]; then
    cp -R .build/arm64-apple-macosx/debug/FLAC.framework ResonateReceiver.app/Contents/Frameworks/
fi
if [ -d .build/arm64-apple-macosx/debug/ogg.framework ]; then
    cp -R .build/arm64-apple-macosx/debug/ogg.framework ResonateReceiver.app/Contents/Frameworks/
fi

echo "📝 Creating PkgInfo..."
echo "APPL????" > ResonateReceiver.app/Contents/PkgInfo

echo "✅ Build complete! ResonateReceiver.app is ready."
echo "🚀 To run: open ResonateReceiver.app"
