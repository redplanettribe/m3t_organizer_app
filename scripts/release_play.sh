#!/usr/bin/env bash
set -euo pipefail

# Builds signed Android App Bundle and uploads it to Google Play.
#
# Required environment variables:
#   PLAY_PACKAGE_NAME         e.g. com.yourcompany.m3torganizer
#   PLAY_SERVICE_ACCOUNT_JSON absolute path to Google Play service account json
#
# Optional:
#   PLAY_TRACK                internal|alpha|beta|production (default: internal)
#   PLAY_RELEASE_STATUS       draft|completed|inProgress|halted (default: draft)

# Load deployment env vars from project root if present.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${PROJECT_ROOT}/.env.deployment"
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

: "${PLAY_PACKAGE_NAME:?Missing PLAY_PACKAGE_NAME}"
: "${PLAY_SERVICE_ACCOUNT_JSON:?Missing PLAY_SERVICE_ACCOUNT_JSON}"

PLAY_TRACK="${PLAY_TRACK:-internal}"
PLAY_RELEASE_STATUS="${PLAY_RELEASE_STATUS:-draft}"
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

if [[ ! -f "android/key.properties" ]]; then
  echo "Missing android/key.properties."
  echo "Create it from android/key.properties.example before building."
  exit 1
fi

if [[ ! -f "${PLAY_SERVICE_ACCOUNT_JSON}" ]]; then
  echo "Service account json not found: ${PLAY_SERVICE_ACCOUNT_JSON}"
  exit 1
fi

if ! command -v fvm >/dev/null 2>&1; then
  echo "fvm is required but not installed."
  exit 1
fi

if ! command -v fastlane >/dev/null 2>&1; then
  echo "fastlane is required but not installed."
  exit 1
fi

echo "Building signed Android App Bundle..."
fvm flutter clean
fvm flutter pub get
fvm flutter build appbundle --release \
  --dart-define=M3T_API_URL=https://api.multiticketing.com

if [[ ! -f "${AAB_PATH}" ]]; then
  echo "Build did not produce ${AAB_PATH}"
  exit 1
fi

echo "Uploading ${AAB_PATH} to Google Play track '${PLAY_TRACK}'..."
fastlane supply \
  --aab "${AAB_PATH}" \
  --package_name "${PLAY_PACKAGE_NAME}" \
  --json_key "${PLAY_SERVICE_ACCOUNT_JSON}" \
  --track "${PLAY_TRACK}" \
  --release_status "${PLAY_RELEASE_STATUS}" \
  --skip_upload_images true \
  --skip_upload_screenshots true \
  --skip_upload_metadata true

echo "Upload completed."
