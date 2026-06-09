#!/usr/bin/env bash
set -e

#  Luna installer
#  Installs Luna and its Lua dependencies so


INSTALL_DIR="$HOME/.local/share/luna"
BIN_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info()    { echo -e "${GREEN}[luna]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[luna]${RESET} $*"; }
error()   { echo -e "${RED}[luna]${RESET} $*" >&2; exit 1; }

# ── Dependency checks ──────────────────────────────────────────────────────────

check_cmd() {
    command -v "$1" &>/dev/null || error "'$1' is required but not found. Please install it first."
}

check_cmd lua
check_cmd luarocks
check_cmd git
check_cmd ollama

# ── Lua dependency installation via LuaRocks ──────────────────────────────────

info "Installing Lua dependencies via LuaRocks..."

# luarocks install with --local puts rocks in ~/.luarocks
# Pass --local so we don't need sudo
luarocks install --local luafilesystem  || warn "luafilesystem may already be installed"
luarocks install --local luasocket      || warn "luasocket may already be installed"
luarocks install --local dkjson         || warn "dkjson may already be installed"
luarocks install --local luv            || warn "luv may already be installed"

# ── Copy source files ──────────────────────────────────────────────────────────

info "Installing Luna source to $INSTALL_DIR ..."
mkdir -p "$INSTALL_DIR"

# If running from the repo root, src/ is right here.
# Support both `bash install.sh` from repo root and from inside src/.
if [ -d "$SCRIPT_DIR/src" ]; then
    cp -r "$SCRIPT_DIR/src/." "$INSTALL_DIR/"
elif [ -f "$SCRIPT_DIR/main.lua" ]; then
    cp -r "$SCRIPT_DIR/." "$INSTALL_DIR/"
else
    error "Cannot find Luna source. Run install.sh from the repo root or src/ directory."
fi

# ── Write the launcher wrapper ─────────────────────────────────────────────────

mkdir -p "$BIN_DIR"
LAUNCHER="$BIN_DIR/luna"


cat > "$LAUNCHER" <<EOF
#!/usr/bin/env bash
eval "\$(luarocks path --local)"
export LUNA_CWD="\$(pwd)"
cd "$INSTALL_DIR" || exit 1
exec lua "$INSTALL_DIR/main.lua" "\$@"
EOF
chmod +x "$LAUNCHER"

# ── PATH reminder ──────────────────────────────────────────────────────────────

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    warn "$BIN_DIR is not in your PATH."
    echo ""
    echo "  Add one of the following lines to your shell config (~/.bashrc, ~/.zshrc, etc.):"
    echo ""
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "  Then reload your shell:  source ~/.bashrc  (or open a new terminal)"
fi

# ── Done ───────────────────────────────────────────────────────────────────────

info "Luna installed successfully!"
info "Run: luna help"