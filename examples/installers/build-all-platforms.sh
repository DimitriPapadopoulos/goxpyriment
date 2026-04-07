#!/usr/bin/env bash
# Copyright (2026) Christophe Pallier <christophe@pallier.org>
# Distributed under the GNU General Public License v3.

# Build all goxpyriment examples and tests for Windows, macOS (arm64), Linux
# (x86_64), and Linux (arm64 / Raspberry Pi). Uses Go cross-compilation
# (CGO_ENABLED=0 required).
#
# Run from the repo root OR from examples/installers/:
#   bash examples/installers/build-all-platforms.sh
#
# Prerequisites:
#   - Go 1.25+ in PATH
#   - CGO_ENABLED=0  (set automatically here, override with env if needed)
#
# Outputs (all in examples/installers/):
#   goxpyriment-examples-windows-x86_64.zip
#   goxpyriment-examples-macos-arm64.zip
#   goxpyriment-examples-linux-x86_64.tar.gz
#   goxpyriment-examples-linux-arm64.tar.gz

set -euo pipefail

export CGO_ENABLED=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="${SCRIPT_DIR%/installers}"
REPO_ROOT="$(cd "${EXAMPLES_DIR}/.." && pwd)"
TESTS_DIR="${REPO_ROOT}/tests"
OUT_DIR="${SCRIPT_DIR}"
ASSETS_DIR="${EXAMPLES_DIR}/../assets"

SKIP_DIRS=("assets" "installers" "xpd_results")
SKIP_TEST_DIRS=("psychopy-test")

# --- helpers -----------------------------------------------------------------

is_skipped() {
  local name="$1"
  for s in "${SKIP_DIRS[@]}"; do
    [[ "$name" == "$s" ]] && return 0
  done
  return 1
}

is_skipped_test() {
  local name="$1"
  for s in "${SKIP_TEST_DIRS[@]}"; do
    [[ "$name" == "$s" ]] && return 0
  done
  return 1
}

# Enumerate example directories that have a main.go
example_dirs() {
  for dir in "${EXAMPLES_DIR}"/*/; do
    local name
    name="$(basename "$dir")"
    is_skipped "$name" && continue
    [[ -f "${dir}/main.go" ]] || continue
    echo "$dir"
  done
}

# Enumerate test directories that have a main.go
test_dirs() {
  for dir in "${TESTS_DIR}"/*/; do
    local name
    name="$(basename "$dir")"
    is_skipped_test "$name" && continue
    [[ -f "${dir}/main.go" ]] || continue
    echo "$dir"
  done
}

# =============================================================================
# 1. Windows x86_64 — zip of .exe files
# =============================================================================

echo "=== Building Windows x86_64 binaries ==="
WIN_STAGE="${OUT_DIR}/win-stage"
rm -rf "${WIN_STAGE}"
mkdir -p "${WIN_STAGE}/tests"

while IFS= read -r dir; do
  name="$(basename "$dir")"
  echo "  ${name}.exe"
  GOOS=windows GOARCH=amd64 go build \
    -ldflags="-s -w -H windowsgui" \
    -o "${WIN_STAGE}/${name}.exe" \
    "${dir}"
done < <(example_dirs)

while IFS= read -r dir; do
  name="$(basename "$dir")"
  echo "  tests/${name}.exe"
  GOOS=windows GOARCH=amd64 go build \
    -ldflags="-s -w" \
    -o "${WIN_STAGE}/tests/${name}.exe" \
    "${dir}"
done < <(test_dirs)

WIN_ZIP="${OUT_DIR}/goxpyriment-examples-windows-x86_64.zip"
rm -f "${WIN_ZIP}"
(cd "${WIN_STAGE}" && zip -q -r "${WIN_ZIP}" .)
echo "  -> ${WIN_ZIP}"

# =============================================================================
# 2. macOS arm64 — zip of .app bundles (unsigned; Gatekeeper note applies)
# =============================================================================

echo "=== Building macOS arm64 .app bundles ==="
MAC_STAGE="${OUT_DIR}/mac-stage"
rm -rf "${MAC_STAGE}"
mkdir -p "${MAC_STAGE}/tests"

while IFS= read -r dir; do
  name="$(basename "$dir")"
  app="${MAC_STAGE}/${name}.app"
  echo "  ${name}.app"

  mkdir -p "${app}/Contents/MacOS" "${app}/Contents/Resources"

  cat > "${app}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>${name}</string>
  <key>CFBundleIdentifier</key>
  <string>org.goxpyriment.${name}</string>
  <key>CFBundleVersion</key>
  <string>0.1.0</string>
  <key>CFBundleExecutable</key>
  <string>${name}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleIconFile</key>
  <string>icon.icns</string>
</dict>
</plist>
EOF

  # Icon (optional — skip gracefully if absent)
  if [[ -f "${ASSETS_DIR}/icon.icns" ]]; then
    cp "${ASSETS_DIR}/icon.icns" "${app}/Contents/Resources/icon.icns"
  fi

  GOOS=darwin GOARCH=arm64 go build \
    -ldflags="-s -w" \
    -o "${app}/Contents/MacOS/${name}" \
    "${dir}"

  # Copy per-example assets if present
  if [[ -d "${dir}/assets" ]]; then
    cp -R "${dir}/assets" "${app}/Contents/Resources/"
  fi
done < <(example_dirs)

while IFS= read -r dir; do
  name="$(basename "$dir")"
  echo "  tests/${name}"
  GOOS=darwin GOARCH=arm64 go build \
    -ldflags="-s -w" \
    -o "${MAC_STAGE}/tests/${name}" \
    "${dir}"
done < <(test_dirs)

# Note: codesign is NOT run here — binaries are unsigned.
# macOS users must right-click → Open, or run:
#   xattr -dr com.apple.quarantine <AppName>.app

MAC_ZIP="${OUT_DIR}/goxpyriment-examples-macos-arm64.zip"
rm -f "${MAC_ZIP}"
(cd "${MAC_STAGE}" && zip -q -r "${MAC_ZIP}" .)
echo "  -> ${MAC_ZIP}"

# --- SDL3 bundling helper ----------------------------------------------------
# Copy libSDL3.so.0* from the system into a lib/ subdirectory of the given
# stage directory. Skips silently if the library is not found (local builds
# without SDL3 installed; users can install SDL3 system-wide instead).
bundle_sdl3() {
  local stage="$1"
  local libdir
  # Try common multilib paths; pick the first glob that matches.
  for candidate in \
      /usr/lib/x86_64-linux-gnu/libSDL3.so.0* \
      /usr/lib/aarch64-linux-gnu/libSDL3.so.0* \
      /usr/lib/libSDL3.so.0* \
      /usr/local/lib/libSDL3.so.0* ; do
    # Use a subshell so the glob failure doesn't abort the script.
    libdir="$(ls ${candidate} 2>/dev/null | head -1)"
    [[ -n "${libdir}" ]] && break
  done

  if [[ -z "${libdir}" ]]; then
    echo "  (SDL3 not found — skipping library bundle; install libsdl3-0 on target)"
    return
  fi

  mkdir -p "${stage}/lib"
  cp ${candidate%\**}* "${stage}/lib/" 2>/dev/null || true
  echo "  bundled SDL3: $(ls "${stage}/lib/")"
}

# Write a run.sh wrapper that prepends the bundled lib/ to LD_LIBRARY_PATH.
write_run_sh() {
  local stage="$1"
  cat > "${stage}/run.sh" <<'RUNSH'
#!/usr/bin/env bash
# Run a goxpyriment binary with the bundled SDL3 library.
# Usage: ./run.sh <binary-name> [flags]
#   e.g. ./run.sh hello_world -w
#        ./run.sh tests/Timing-Tests -test display
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="${SCRIPT_DIR}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
exec "${SCRIPT_DIR}/$@"
RUNSH
  chmod +x "${stage}/run.sh"
}

# =============================================================================
# 3. Linux x86_64 — binaries + bundled SDL3
# =============================================================================

echo "=== Building Linux x86_64 binaries ==="
X86_STAGE="${OUT_DIR}/x86-stage"
rm -rf "${X86_STAGE}"
mkdir -p "${X86_STAGE}/tests"

while IFS= read -r dir; do
  name="$(basename "$dir")"
  echo "  ${name}"
  GOOS=linux GOARCH=amd64 go build \
    -ldflags="-s -w" \
    -o "${X86_STAGE}/${name}" \
    "${dir}"
done < <(example_dirs)

while IFS= read -r dir; do
  name="$(basename "$dir")"
  echo "  tests/${name}"
  GOOS=linux GOARCH=amd64 go build \
    -ldflags="-s -w" \
    -o "${X86_STAGE}/tests/${name}" \
    "${dir}"
done < <(test_dirs)

# Bundle the x86_64 SDL3 shared library and a wrapper script.
# Binaries load libSDL3.so.0 at runtime via purego (not linked statically).
(
  # Restrict glob search to x86_64 paths for this target.
  candidate=/usr/lib/x86_64-linux-gnu/libSDL3.so.0*
  stage="${X86_STAGE}"
  if ls ${candidate} 2>/dev/null | head -1 | grep -q .; then
    mkdir -p "${stage}/lib"
    cp ${candidate} "${stage}/lib/" 2>/dev/null || true
    echo "  bundled SDL3 (x86_64): $(ls "${stage}/lib/")"
  else
    bundle_sdl3 "${stage}"
  fi
)
write_run_sh "${X86_STAGE}"

LINUX_TARBALL="${OUT_DIR}/goxpyriment-examples-linux-x86_64.tar.gz"
rm -f "${LINUX_TARBALL}"
(cd "${X86_STAGE}" && tar czf "${LINUX_TARBALL}" .)
echo "  -> ${LINUX_TARBALL}"

# =============================================================================
# 4. Linux arm64 (Raspberry Pi) — binaries + bundled SDL3
# =============================================================================

echo "=== Building Linux arm64 (Raspberry Pi) binaries ==="
ARM64_STAGE="${OUT_DIR}/arm64-stage"
rm -rf "${ARM64_STAGE}"
mkdir -p "${ARM64_STAGE}/tests"

while IFS= read -r dir; do
  name="$(basename "$dir")"
  echo "  ${name}"
  GOOS=linux GOARCH=arm64 go build \
    -ldflags="-s -w" \
    -o "${ARM64_STAGE}/${name}" \
    "${dir}"
done < <(example_dirs)

while IFS= read -r dir; do
  name="$(basename "$dir")"
  echo "  tests/${name}"
  GOOS=linux GOARCH=arm64 go build \
    -ldflags="-s -w" \
    -o "${ARM64_STAGE}/tests/${name}" \
    "${dir}"
done < <(test_dirs)

# Bundle the arm64 SDL3 shared library.
(
  candidate=/usr/lib/aarch64-linux-gnu/libSDL3.so.0*
  stage="${ARM64_STAGE}"
  if ls ${candidate} 2>/dev/null | head -1 | grep -q .; then
    mkdir -p "${stage}/lib"
    cp ${candidate} "${stage}/lib/" 2>/dev/null || true
    echo "  bundled SDL3 (arm64): $(ls "${stage}/lib/")"
  else
    bundle_sdl3 "${stage}"
  fi
)
write_run_sh "${ARM64_STAGE}"

ARM64_TARBALL="${OUT_DIR}/goxpyriment-examples-linux-arm64.tar.gz"
rm -f "${ARM64_TARBALL}"
(cd "${ARM64_STAGE}" && tar czf "${ARM64_TARBALL}" .)
echo "  -> ${ARM64_TARBALL}"

# =============================================================================
# Cleanup staging directories
# =============================================================================
rm -rf "${WIN_STAGE}" "${MAC_STAGE}" "${X86_STAGE}" "${ARM64_STAGE}"

echo ""
echo "Done. Artifacts in ${OUT_DIR}:"
ls -lh \
  "${OUT_DIR}/goxpyriment-examples-windows-x86_64.zip" \
  "${OUT_DIR}/goxpyriment-examples-macos-arm64.zip" \
  "${OUT_DIR}/goxpyriment-examples-linux-x86_64.tar.gz" \
  "${OUT_DIR}/goxpyriment-examples-linux-arm64.tar.gz"
