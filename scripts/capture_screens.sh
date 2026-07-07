#!/usr/bin/env bash
set -euo pipefail

# Capture DEBUG_PREVIEW screens from the simulator for design verification.
# Usage: scripts/capture_screens.sh [outPrefix] [screen1 screen2 ...]
# Screens are DebugPreviewMode rawValues, e.g. Login PostOffice MindHome.
# If no screens given, captures a default broad set.

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
SIM_NAME="${SIMULATOR_NAME:-iPhone 17 Pro}"
BUNDLE_ID="com.lifemidpoint.app"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/tmp/shots"
PREFIX="${1:-verify}"
shift || true

mkdir -p "$OUT_DIR"

SIM_UDID="$(xcrun simctl list devices available | awk -v n="$SIM_NAME" '$0 ~ n && /\([A-F0-9-]+\)/ {match($0,/\([A-F0-9-]+\)/); print substr($0,RSTART+1,RLENGTH-2); exit}')"
if [[ -z "$SIM_UDID" ]]; then echo "ERROR: simulator not found: $SIM_NAME"; exit 1; fi
xcrun simctl bootstatus "$SIM_UDID" -b >/dev/null 2>&1 || xcrun simctl boot "$SIM_UDID" || true

if [[ $# -eq 0 ]]; then
  set -- Login Onboarding Diary DiaryReview DiarySummary DiaryLoading EmotionDetail \
        PostOffice WriteLetter WriteLetterDefault LetterShowcase LetterSent MonthlyReport PenPalList \
        StampAlbum StampShowcase StampObtained \
        Mind Breathing MicroBehavior MicroEmotionStart MicroEmotionEnd PsychologyCard KnowledgeBase \
        Settings WeeklySummary
fi

for screen in "$@"; do
  xcrun simctl terminate "$SIM_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  sleep 0.6
  env SIMCTL_CHILD_DEBUG_PREVIEW="$screen" xcrun simctl launch "$SIM_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  sleep 6
  xcrun simctl io "$SIM_UDID" screenshot "$OUT_DIR/${PREFIX}_${screen}.png" >/dev/null 2>&1 || echo "screenshot failed: $screen"
  echo "captured $screen"
done
echo "ALL DONE -> $OUT_DIR"
