#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG="${REPO_ROOT}/pkgs/seamly2d.nix"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

for cmd in curl jq nix-prefetch-url; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: required command not found: $cmd" >&2
    exit 1
  fi
done

if [[ ! -f "$PKG" ]]; then
  echo "error: package not found: $PKG" >&2
  exit 1
fi

echo "→ Fetching latest release from FashionFreedom/Seamly2D ..."
TAG=$(curl -sL https://api.github.com/repos/FashionFreedom/Seamly2D/releases/latest | jq -r .tag_name)

if [[ -z "$TAG" || "$TAG" == "null" ]]; then
  echo "error: failed to obtain latest tag" >&2
  exit 1
fi

VERSION="${TAG#v}"
CURRENT_VERSION=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$PKG" | head -1)

echo "Current: ${CURRENT_VERSION:-?} → Latest: $TAG"

if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
  echo "Already up to date."
  exit 0
fi

echo "→ Prefetching hash for $TAG ..."
# --unpack produces the NAR hash that fetchFromGitHub expects
HASH=$(nix-prefetch-url --unpack "https://github.com/FashionFreedom/Seamly2D/archive/refs/tags/${TAG}.tar.gz")
if [[ -z "$HASH" ]]; then
  echo "error: failed to obtain hash" >&2
  exit 1
fi

# Convert to SRI form if the tool returned base32
if [[ "$HASH" != sha256-* ]]; then
  HASH="sha256-$(nix hash to-sri --type sha256 "$HASH" 2>/dev/null || echo "$HASH")"
fi

echo "  version = \"$VERSION\""
echo "  rev     = \"$TAG\""
echo "  hash    = \"$HASH\""

if [[ $DRY_RUN -eq 1 ]]; then
  echo
  echo "(dry-run) no changes written"
  exit 0
fi

sed -i \
  -e "s/version = \"[^\"]*\";/version = \"${VERSION}\";/" \
  -e "s/rev = \"[^\"]*\";/rev = \"${TAG}\";/" \
  -e "s|hash = \"[^\"]*\";|hash = \"${HASH}\";|" \
  "$PKG"

echo "Done. Package written to $PKG"

