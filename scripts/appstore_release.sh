#!/usr/bin/env bash
# Build the iOS IPA, validate it with App Store Connect, and upload.
#
# Prerequisites (macOS, Xcode command-line tools, FVM with project Flutter):
#   - `.env.deployment` in the project root (see that file for variable descriptions).
#   - App Store Connect API key .p8 named AuthKey_<ASC_API_KEY_ID>.p8
#
# Optional flags:
#   --bump-build         Increment pubspec build number (X.Y.Z+N → X.Y.Z+(N+1)); default leaves version unchanged
#   --version VER        Set pubspec version exactly, e.g. 1.2.0+42 (mutually exclusive with --bump-build)
#   --skip-tests         Do not run flutter test
#   --skip-analyze       Do not run flutter analyze
#   --skip-validate      Build only; skip altool validation
#   --skip-upload        Validate only; do not upload

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DEPLOY_ENV="$ROOT/.env.deployment"
if [[ ! -f "$DEPLOY_ENV" ]]; then
  echo "Missing deployment env file: $DEPLOY_ENV" >&2
  echo "Create it at the repo root with ASC_API_KEY_ID, ASC_API_ISSUER_ID, ASC_API_KEY_PATH," >&2
  echo "M3T_API_URL, and optionally OBJECT_STORE_URL." >&2
  exit 1
fi
set -a
# shellcheck disable=SC1090
source "$DEPLOY_ENV"
set +a

SKIP_TESTS=0
SKIP_ANALYZE=0
SKIP_VALIDATE=0
SKIP_UPLOAD=0
BUMP_BUILD=0
MANUAL_VERSION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-tests) SKIP_TESTS=1; shift ;;
    --skip-analyze) SKIP_ANALYZE=1; shift ;;
    --skip-validate) SKIP_VALIDATE=1; shift ;;
    --skip-upload) SKIP_UPLOAD=1; shift ;;
    --bump-build) BUMP_BUILD=1; shift ;;
    --version)
      if [[ -z "${2:-}" ]]; then
        echo "--version requires a value (e.g. 1.2.0+42)" >&2
        exit 1
      fi
      MANUAL_VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--bump-build | --version VER] [--skip-tests] [--skip-analyze] [--skip-validate] [--skip-upload]" >&2
      exit 1
      ;;
  esac
done

if [[ -n "$MANUAL_VERSION" && "$BUMP_BUILD" -eq 1 ]]; then
  echo "Use only one of --version and --bump-build" >&2
  exit 1
fi

apply_pubspec_version() {
  local pub="$ROOT/pubspec.yaml"
  if [[ ! -f "$pub" ]]; then
    echo "Missing pubspec.yaml at $pub" >&2
    exit 1
  fi

  if [[ -n "$MANUAL_VERSION" ]]; then
    echo "==> set pubspec version to $MANUAL_VERSION"
    sed -i '' "s|^version:.*|version: $MANUAL_VERSION|" "$pub"
    return 0
  fi

  if [[ "$BUMP_BUILD" -ne 1 ]]; then
    return 0
  fi

  local line
  line="$(grep -E '^version:[[:space:]]+' "$pub" | head -n 1)"
  if [[ "$line" =~ ^version:[[:space:]]+([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)[[:space:]]*$ ]]; then
    local major="${BASH_REMATCH[1]}" minor="${BASH_REMATCH[2]}" patch="${BASH_REMATCH[3]}" build="${BASH_REMATCH[4]}"
    local new_build=$((build + 1))
    local ver="${major}.${minor}.${patch}+${new_build}"
    echo "==> bump build number: ${major}.${minor}.${patch}+${build} → $ver"
    sed -i '' "s|^version:.*|version: ${ver}|" "$pub"
  else
    echo "Could not parse pubspec version as X.Y.Z+N for --bump-build (line: ${line:-empty})" >&2
    exit 1
  fi
}

# Prefer `fvm flutter`; otherwise use FVM-managed SDK from .fvmrc / ~/.fvm/versions (non-interactive shells often lack fvm on PATH).
FLUTTER_CMD=()
if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=(fvm flutter)
elif [[ -x "$ROOT/.fvm/flutter_sdk/bin/flutter" ]]; then
  FLUTTER_CMD=("$ROOT/.fvm/flutter_sdk/bin/flutter")
else
  fvm_ver=""
  if [[ -f "$ROOT/.fvm/fvm_config.json" ]]; then
    fvm_ver="$(sed -n 's/.*"flutterSdkVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$ROOT/.fvm/fvm_config.json" | head -n 1)"
  fi
  if [[ -z "$fvm_ver" && -f "$ROOT/.fvmrc" ]]; then
    fvm_ver="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$ROOT/.fvmrc" | head -n 1)"
  fi
  if [[ -z "$fvm_ver" ]]; then
    fvm_ver="3.41.3"
  fi
  fvm_home="${FVM_HOME:-$HOME/fvm}"
  candidate="$fvm_home/versions/$fvm_ver/bin/flutter"
  if [[ -x "$candidate" ]]; then
    FLUTTER_CMD=("$candidate")
  elif command -v flutter >/dev/null 2>&1; then
    FLUTTER_CMD=(flutter)
  else
    echo "Could not find Flutter. Install FVM, run \`fvm use\` in this repo, or add \`fvm\` / \`flutter\` to PATH." >&2
    echo "Expected SDK at: $candidate" >&2
    exit 1
  fi
fi

if [[ "$SKIP_VALIDATE" -eq 0 ]] || [[ "$SKIP_UPLOAD" -eq 0 ]]; then
  for var in ASC_API_KEY_ID ASC_API_ISSUER_ID ASC_API_KEY_PATH; do
    if [[ -z "${!var:-}" ]]; then
      echo "Missing required env var: $var (needed for validate/upload)" >&2
      exit 1
    fi
  done
  if [[ ! -f "$ASC_API_KEY_PATH" ]]; then
    echo "ASC_API_KEY_PATH is not a file: $ASC_API_KEY_PATH" >&2
    exit 1
  fi
  expected_name="AuthKey_${ASC_API_KEY_ID}.p8"
  actual_name="$(basename "$ASC_API_KEY_PATH")"
  if [[ "$actual_name" != "$expected_name" ]]; then
    echo "API key file must be named $expected_name (Apple altool requirement); got: $actual_name" >&2
    exit 1
  fi
  export API_PRIVATE_KEYS_DIR
  API_PRIVATE_KEYS_DIR="$(dirname "$ASC_API_KEY_PATH")"
fi

apply_pubspec_version

DEFINE_ARGS=()
if [[ -n "${M3T_API_URL:-}" ]]; then
  DEFINE_ARGS+=(--dart-define="M3T_API_URL=$M3T_API_URL")
else
  echo "Warning: M3T_API_URL is unset; build will use AppConfig default (emulator loopback)." >&2
fi
if [[ -n "${OBJECT_STORE_URL:-}" ]]; then
  DEFINE_ARGS+=(--dart-define="OBJECT_STORE_URL=$OBJECT_STORE_URL")
fi

echo "==> flutter pub get (${FLUTTER_CMD[*]})"
"${FLUTTER_CMD[@]}" pub get

if [[ "$SKIP_ANALYZE" -eq 0 ]]; then
  echo "==> flutter analyze"
  "${FLUTTER_CMD[@]}" analyze
fi

if [[ "$SKIP_TESTS" -eq 0 ]]; then
  echo "==> flutter test"
  "${FLUTTER_CMD[@]}" test
fi

echo "==> flutter build ipa"
"${FLUTTER_CMD[@]}" build ipa "${DEFINE_ARGS[@]}"

IPA=""
while IFS= read -r -d '' f; do
  if [[ -z "$IPA" ]] || [[ "$f" -nt "$IPA" ]]; then
    IPA=$f
  fi
done < <(find "$ROOT/build/ios/ipa" -name '*.ipa' -type f -print0 2>/dev/null || true)
if [[ -z "$IPA" || ! -f "$IPA" ]]; then
  echo "Could not find IPA under build/ios/ipa" >&2
  exit 1
fi
echo "Built: $IPA"

if [[ "$SKIP_VALIDATE" -eq 0 ]]; then
  echo "==> altool validate-app"
  xcrun altool --validate-app \
    --type ios \
    --file "$IPA" \
    --apiKey "$ASC_API_KEY_ID" \
    --apiIssuer "$ASC_API_ISSUER_ID"
fi

if [[ "$SKIP_UPLOAD" -eq 0 ]]; then
  echo "==> altool upload-app"
  xcrun altool --upload-app \
    --type ios \
    --file "$IPA" \
    --apiKey "$ASC_API_KEY_ID" \
    --apiIssuer "$ASC_API_ISSUER_ID"
fi

echo "Done."
