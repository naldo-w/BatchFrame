#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="BatchFrame"
BUILD_DIR="$ROOT_DIR/build/macos"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICNS_FILE="$RESOURCES_DIR/$APP_NAME.icns"
MODULE_CACHE_DIR="$BUILD_DIR/module-cache"

if [[ -d "/Applications/Xcode-beta.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"
fi

rm -rf "$BUILD_DIR" "$APP_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR" "$MACOS_DIR" "$RESOURCES_DIR" "$MODULE_CACHE_DIR"

cp "$ROOT_DIR/index.html" "$RESOURCES_DIR/index.html"
cp "$ROOT_DIR/support.js" "$RESOURCES_DIR/support.js"
cp "$ROOT_DIR/BatchFrame.png" "$RESOURCES_DIR/BatchFrame.png"

python3 - "$ROOT_DIR/BatchFrame.png" "$ICNS_FILE" <<'PY'
import sys
from PIL import Image

source, destination = sys.argv[1], sys.argv[2]
image = Image.open(source).convert("RGBA")
image.save(destination, sizes=[(16, 16), (32, 32), (64, 64), (128, 128), (256, 256), (512, 512), (1024, 1024)])
PY

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIconFile</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>design.naldo.batchframe</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.photography</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

xcrun swiftc "$ROOT_DIR/macos/BatchFrameApp.swift" \
  -o "$MACOS_DIR/$APP_NAME" \
  -module-cache-path "$MODULE_CACHE_DIR" \
  -framework Cocoa \
  -framework WebKit \
  -framework UniformTypeIdentifiers

chmod +x "$MACOS_DIR/$APP_NAME"
xattr -cr "$APP_DIR" 2>/dev/null || true
xattr -d com.apple.FinderInfo "$APP_DIR" 2>/dev/null || true
codesign --force --deep --sign - "$APP_DIR" >/dev/null
xattr -d com.apple.FinderInfo "$APP_DIR" 2>/dev/null || true

echo "$APP_DIR"
