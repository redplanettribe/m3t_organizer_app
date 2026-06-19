#!/usr/bin/env bash
# Prepare the Linux host toolchain for Flutter native assets builds.
#
# Flutter 3.41+ resolves clang++ on PATH, then expects ld.lld (or ld) in the
# same directory. Ubuntu's clang-18 package does not install lld by default.
#
# Preferred fix (system package):
#   sudo apt-get install -y lld-18
#
# This script is a no-sudo workaround: wrapper scripts in ~/.local/llvm-bin
# with a symlink to /usr/bin/ld. Add that directory to PATH before flutter run.
#
# Usage:
#   ./scripts/setup_linux_toolchain.sh
#   export PATH="$HOME/.local/llvm-bin:$PATH"
#   fvm flutter run -d linux

set -euo pipefail

LLVM_BIN="${LLVM_BIN:-/usr/lib/llvm-18/bin}"
TOOLCHAIN_DIR="${HOME}/.local/llvm-bin"

if [[ -x "${LLVM_BIN}/ld.lld" || -x "${LLVM_BIN}/ld" ]]; then
  echo "Linux toolchain OK: linker found in ${LLVM_BIN}."
  exit 0
fi

if [[ ! -x "${LLVM_BIN}/clang++" ]]; then
  echo "clang++ not found at ${LLVM_BIN}/clang++." >&2
  echo "Install clang first, e.g.: sudo apt-get install -y clang" >&2
  exit 1
fi

if [[ ! -x /usr/bin/ld ]]; then
  echo "/usr/bin/ld not found. Install binutils, e.g.: sudo apt-get install -y binutils" >&2
  exit 1
fi

mkdir -p "${TOOLCHAIN_DIR}"

cat >"${TOOLCHAIN_DIR}/clang" <<EOF
#!/bin/sh
exec ${LLVM_BIN}/clang "\$@"
EOF

cat >"${TOOLCHAIN_DIR}/clang++" <<EOF
#!/bin/sh
exec ${LLVM_BIN}/clang++ "\$@"
EOF

chmod +x "${TOOLCHAIN_DIR}/clang" "${TOOLCHAIN_DIR}/clang++"
ln -sf "${LLVM_BIN}/llvm-ar" "${TOOLCHAIN_DIR}/llvm-ar"
ln -sf /usr/bin/ld "${TOOLCHAIN_DIR}/ld"

echo "Created Flutter Linux toolchain wrappers in ${TOOLCHAIN_DIR}."
echo
echo "Add to your shell profile, or prefix flutter commands:"
echo "  export PATH=\"${TOOLCHAIN_DIR}:\$PATH\""
echo
echo "Or install the system linker instead:"
echo "  sudo apt-get install -y lld-18"
