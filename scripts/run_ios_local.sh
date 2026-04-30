#!/usr/bin/env bash
set -euo pipefail

# One-command local runner:
# 1. start local agent backend (idempotent)
# 2. regenerate Xcode project
# 3. build the iOS app for simulator
# 4. boot/open simulator
# 5. install and launch the app

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 17 Pro}"
SCHEME="${SCHEME:-LifeMidpoint}"
BUNDLE_ID="${BUNDLE_ID:-com.lifemidpoint.app}"
DERIVED_DATA="$PROJECT_ROOT/build/LocalRunDerivedData"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/LifeMidpoint.app"

cd "$PROJECT_ROOT"

echo "==> Starting local agent server"
"$PROJECT_ROOT/scripts/start_agent_server.sh"

echo "==> Generating Xcode project"
xcodegen generate

echo "==> Building $SCHEME for $SIMULATOR_NAME"
xcodebuild \
  -project LifeMidpoint.xcodeproj \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
  -derivedDataPath "$DERIVED_DATA" \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "ERROR: built app not found: $APP_PATH"
  exit 1
fi

echo "==> Finding simulator: $SIMULATOR_NAME"
SIM_UDID="$(
  xcrun simctl list devices available |
    awk -v name="$SIMULATOR_NAME" '
      $0 ~ name && $0 ~ /\([A-F0-9-]+\)/ {
        match($0, /\([A-F0-9-]+\)/)
        print substr($0, RSTART + 1, RLENGTH - 2)
        exit
      }
    '
)"

if [[ -z "$SIM_UDID" ]]; then
  echo "ERROR: simulator not found: $SIMULATOR_NAME"
  xcrun simctl list devices available
  exit 1
fi

echo "==> Booting simulator ($SIM_UDID)"
xcrun simctl boot "$SIM_UDID" >/dev/null 2>&1 || true
open -a Simulator

echo "==> Installing app"
xcrun simctl install "$SIM_UDID" "$APP_PATH"

echo "==> Launching app"
xcrun simctl launch --terminate-running-process "$SIM_UDID" "$BUNDLE_ID"

echo "==> Done"
echo "Agent: http://127.0.0.1:8787/health"
echo "App:   $BUNDLE_ID on $SIMULATOR_NAME"
