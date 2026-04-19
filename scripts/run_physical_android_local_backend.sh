#!/usr/bin/env bash
# Run the Flutter app on a physical Android phone with the API and object
# store on the host machine (same ports as local dev defaults in AppConfig).
#
# Requires: USB debugging, adb, fvm; backend listening on the host at the
# configured ports; backend bound to 0.0.0.0 (not only 127.0.0.1) so reverse
# traffic can reach it.
#
# Optional environment:
#   M3T_DEVICE            adb / flutter device id (e.g. 080203328A003529).
#                         Required when more than one device is connected.
#   M3T_API_PORT          default 8080
#   M3T_OBJECT_STORE_PORT default 9000
#
# iOS physical devices: adb reverse does not apply; use your Mac's LAN IP in
# --dart-define instead (same M3T_API_URL / OBJECT_STORE_URL keys).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

M3T_API_PORT="${M3T_API_PORT:-8080}"
M3T_OBJECT_STORE_PORT="${M3T_OBJECT_STORE_PORT:-9000}"

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found. Install Android SDK platform-tools and ensure adb is on PATH." >&2
  exit 1
fi

if ! command -v fvm >/dev/null 2>&1; then
  echo "fvm not found. Install FVM and run from a shell where fvm is on PATH." >&2
  exit 1
fi

_ADB_DEVICE_LINES=()
while IFS= read -r _line; do
  [[ -n "${_line}" ]] && _ADB_DEVICE_LINES+=("${_line}")
done < <(adb devices | awk '/\tdevice$/ {print $1}')
if [[ ${#_ADB_DEVICE_LINES[@]} -eq 0 ]]; then
  echo "No Android device in \"device\" state. Connect the phone with USB debugging enabled." >&2
  exit 1
fi

if [[ ${#_ADB_DEVICE_LINES[@]} -gt 1 && -z "${M3T_DEVICE:-}" ]]; then
  echo "Multiple Android devices are connected; set M3T_DEVICE to one of:" >&2
  printf '  %s\n' "${_ADB_DEVICE_LINES[@]}" >&2
  exit 1
fi

if [[ -n "${M3T_DEVICE:-}" ]]; then
  _m3t_device_ok=0
  for _d in "${_ADB_DEVICE_LINES[@]}"; do
    if [[ "${_d}" == "${M3T_DEVICE}" ]]; then
      _m3t_device_ok=1
      break
    fi
  done
  if [[ "${_m3t_device_ok}" -ne 1 ]]; then
    echo "M3T_DEVICE=${M3T_DEVICE} is not connected (USB debugging / device state)." >&2
    exit 1
  fi
fi

ADB_BASE=(adb)
if [[ -n "${M3T_DEVICE:-}" ]]; then
  ADB_BASE=(adb -s "${M3T_DEVICE}")
fi

if ! "${ADB_BASE[@]}" reverse "tcp:${M3T_API_PORT}" "tcp:${M3T_API_PORT}"; then
  echo "adb reverse for API port ${M3T_API_PORT} failed. Is the phone connected with USB debugging?" >&2
  exit 1
fi

if ! "${ADB_BASE[@]}" reverse "tcp:${M3T_OBJECT_STORE_PORT}" "tcp:${M3T_OBJECT_STORE_PORT}"; then
  echo "adb reverse for object store port ${M3T_OBJECT_STORE_PORT} failed." >&2
  exit 1
fi

# Use 127.0.0.1 (not localhost): MediaUrlResolver rewrites "localhost" to
# 10.0.2.2 on Android, which is emulator-only and breaks physical devices.
API_URL="http://127.0.0.1:${M3T_API_PORT}"
OBJECT_URL="http://127.0.0.1:${M3T_OBJECT_STORE_PORT}"

FLUTTER_DEVICE_ARGS=()
if [[ -n "${M3T_DEVICE:-}" ]]; then
  FLUTTER_DEVICE_ARGS=(-d "${M3T_DEVICE}")
elif [[ ${#_ADB_DEVICE_LINES[@]} -eq 1 ]]; then
  FLUTTER_DEVICE_ARGS=(-d "${_ADB_DEVICE_LINES[0]}")
fi

exec fvm flutter run "${FLUTTER_DEVICE_ARGS[@]}" \
  --dart-define="M3T_API_URL=${API_URL}" \
  --dart-define="OBJECT_STORE_URL=${OBJECT_URL}"
