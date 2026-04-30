#!/usr/bin/env bash
# Start N independent Flutter web dev sessions in Chrome using `flutter run --machine`.
#
# Usage:
#   ./scripts/run_n_web_instances.sh <N>
#
# Optional: repo-root `.env` is loaded first (without overriding env already set).
# Prefer setting full URLs:
#   M3T_API_URL, OBJECT_STORE_URL
# Or set ports:
#   M3T_API_PORT (default 8080), M3T_OBJECT_STORE_PORT (default 9000)
#
# Web ports:
#   BASE_WEB_PORT         If set, require ports BASE..BASE+N-1 to be free.
#   WEB_PORT_SCAN_START   Auto allocation start (default 39100)
#   WEB_PORT_MAX_OFFSETS  Auto allocation tries (default 5000)
#   START_STAGGER_SECONDS Delay between spawning each flutter run (default 6)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 required (orchestrator + .env loading)." >&2
  exit 1
fi

if ! command -v fvm >/dev/null 2>&1; then
  echo "error: fvm not found. Install FVM and ensure on PATH." >&2
  exit 1
fi

# shellcheck disable=SC1090
eval "$(python3 "${SCRIPT_DIR}/load_repo_dotenv.py" "${ROOT}")"

usage() {
  cat <<'EOF' >&2
Usage: run_n_web_instances.sh <N>

  N                    Number of Chrome web instances (positive integer).
  BASE_WEB_PORT        If set, require ports BASE..BASE+N-1 to be free.
  WEB_PORT_SCAN_START  First base to try for auto ports (default: 39100).
  WEB_PORT_MAX_OFFSETS Max base offsets to try when auto-allocating (default: 5000).
  START_STAGGER_SECONDS Pause between spawning each flutter run (default: 6).

Backend configuration:
  Prefer full URLs:
    M3T_API_URL, OBJECT_STORE_URL
  Or ports (used if URLs absent):
    M3T_API_PORT (default 8080), M3T_OBJECT_STORE_PORT (default 9000)

Example:
  ./scripts/run_n_web_instances.sh 2
EOF
}

if [[ "${#}" -lt 1 ]]; then
  usage
  exit 1
fi

N="$1"
if ! [[ "${N}" =~ ^[1-9][0-9]*$ ]]; then
  echo "error: N must be a positive integer, got: ${N}" >&2
  usage
  exit 1
fi

flutter_devices_out="$(fvm flutter devices 2>/dev/null || true)"
if ! grep -qiE "•[[:space:]]*chrome[[:space:]]*•" <<<"${flutter_devices_out}"; then
  echo "error: Chrome not in 'fvm flutter devices'. Install Chrome or enable web target." >&2
  echo "Current device list:" >&2
  fvm flutter devices >&2 || true
  exit 1
fi

export START_STAGGER_SECONDS="${START_STAGGER_SECONDS:-6}"
export WEB_PORT_SCAN_START="${WEB_PORT_SCAN_START:-39100}"
export WEB_PORT_MAX_OFFSETS="${WEB_PORT_MAX_OFFSETS:-5000}"
if [[ -n "${BASE_WEB_PORT:-}" ]]; then
  export BASE_WEB_PORT
fi
export REPO_ROOT="${ROOT}"

exec python3 "${SCRIPT_DIR}/web_n_machine_orchestrator.py" "${N}"
