#!/usr/bin/env bash
# Dev environment setup for Linux. Runs from the beforeDevCommand in
# tauri.linux.conf.json, or by hand.
#
# Two steps:
#
#   src-dist   symlinked to src, so frontend edits are live for the rest of
#              the dev session. prepare-dist.sh stages a slim copy instead,
#              which is what a release bundle wants and what a dev session
#              does not: the copy stops matching src at the first edit.
#
#   editors/   staged by prepare-doctrenderer.sh. That script exits 1 when a
#              Closure-compiled sdk bundle is missing, which is the normal
#              state of a fresh clone, so this one fills whatever is still
#              missing with a one-line stub and lets the app start. The
#              editors are broken until the real bundles are built; the rest
#              of the wrapper can be worked on meanwhile.
#
# To build the real bundles:
#   cd src/sdkjs/build && npm ci && npx grunt develop --desktop=true
#   cd ../../.. && bash scripts/prepare-doctrenderer.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EDITORS="$ROOT/src-tauri/editors"
LOG_DIR="${TMPDIR:-/tmp}/euro-office-lite"
LOG_FILE="$LOG_DIR/setup-dev-linux.log"
mkdir -p "$LOG_DIR"

SRC_DIST="$ROOT/src-dist"
if [ -L "$SRC_DIST" ]; then
    rm "$SRC_DIST"
elif [ -d "$SRC_DIST" ]; then
    rm -rf "$SRC_DIST"
fi
ln -s src "$SRC_DIST"
echo "src-dist -> src"

if bash "$SCRIPT_DIR/prepare-doctrenderer.sh" > "$LOG_FILE" 2>&1; then
    echo "editors/ staged from the submodules"
else
    echo "prepare-doctrenderer.sh stopped early, full output in $LOG_FILE"
fi

# prepare-doctrenderer.sh starts with rm -rf on editors/ and its first three
# copies are unguarded, so under set -e a missing AllFonts.js aborts it before
# it reaches xregexp and the sdk bundles. The list below is everything it would
# have produced. Each path is taken from the submodules if it is there and
# stubbed only if it is not, so an early abort costs nothing that was
# available.
#
# Every path under editors/ mirrors its source: editors/sdkjs/x comes from
# src/sdkjs/x, editors/web-apps/x from src/web-apps/x.
ensure() {
    local rel="$1"
    local dest="$EDITORS/$rel"
    local src="$ROOT/src/$rel"
    [ -s "$dest" ] && return 0
    mkdir -p "$(dirname "$dest")"
    if [ -s "$src" ]; then
        cp -f "$src" "$dest"
        echo "  copied: $rel"
    else
        echo "// dev stub, see scripts/setup-dev-linux.sh" > "$dest"
        echo "  stub: $rel"
    fi
}

ensure sdkjs/common/Native/native.js
ensure sdkjs/common/Native/jquery_native.js
ensure sdkjs/common/AllFonts.js
ensure sdkjs/common/libfont/engine/fonts_native.js
ensure web-apps/vendor/xregexp/xregexp-all-min.js
for module in word cell slide; do
    ensure "sdkjs/$module/sdk-all.js"
    ensure "sdkjs/$module/sdk-all-min.js"
done

echo "editors/ ready"
