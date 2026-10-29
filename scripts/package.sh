#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"
ARCH="$(uname -m)"
DMG_NAME="AGX-Auto-Clicker-1.0.0-${ARCH}.dmg"
mkdir -p dist .build/packaging
STAGING="$(mktemp -d "$PROJECT_ROOT/.build/packaging/run.XXXXXX")"
ICONSET="$STAGING/AppIcon.iconset"
APP="$STAGING/image/AGX Auto Clicker.app"
mkdir -p "$ICONSET" "$APP/Contents/MacOS" "$APP/Contents/Resources"

for SIZE in 16 32 128 256 512; do
    sips -z "$SIZE" "$SIZE" Assets/AGXAutoClicker-icon.png --out "$ICONSET/icon_${SIZE}x${SIZE}.png" >/dev/null
    DOUBLE=$((SIZE * 2))
    sips -z "$DOUBLE" "$DOUBLE" Assets/AGXAutoClicker-icon.png --out "$ICONSET/icon_${SIZE}x${SIZE}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
cp "$BIN_DIR/AGXAutoClicker" "$APP/Contents/MacOS/AGXAutoClicker"
cp LICENSE "$APP/Contents/Resources/LICENSE.txt"
cp LICENSE "$STAGING/image/LICENSE.txt"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>en</string>
    <key>CFBundleExecutable</key><string>AGXAutoClicker</string>
    <key>CFBundleIdentifier</key><string>com.agx.autoclicker</string>
    <key>CFBundleName</key><string>AGX Auto Clicker</string>
    <key>CFBundleDisplayName</key><string>AGX Auto Clicker</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleIconFile</key><string>AppIcon.icns</string>
    <key>CFBundleShortVersionString</key><string>1.0.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSHumanReadableCopyright</key><string>Developed by AGX</string>
</dict>
</plist>
PLIST

plutil -lint "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
codesign --verify --strict "$APP"
ln -s /Applications "$STAGING/image/Applications"
cat > "$STAGING/image/Install.txt" <<'INSTRUCTIONS'
AGX Auto Clicker
Developed by AGX

Drag AGX Auto Clicker into Applications, then open it from Applications.
Enable access in System Settings > Privacy & Security > Accessibility.
Quit and reopen the app after enabling access.

Start begins clicking after a three-second countdown.
Command-Shift-S stops clicking, including while another app is active.

This beta has no Developer ID signature or Apple notarization.
If macOS blocks it and you trust its source, see https://support.apple.com/102445
for Apple's instructions on approving the app in Privacy & Security.
INSTRUCTIONS

ditto "$APP" "dist/AGX Auto Clicker.app"
hdiutil create -ov -volname "AGX Auto Clicker" -srcfolder "$STAGING/image" -format UDZO "dist/$DMG_NAME"
hdiutil verify "dist/$DMG_NAME"
(cd dist && shasum -a 256 "$DMG_NAME" > SHA256SUMS.txt)
echo "Created dist/AGX Auto Clicker.app, dist/$DMG_NAME, and dist/SHA256SUMS.txt"
