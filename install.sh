#!/bin/bash

ALIAS_NAME="luna"
BASHRC="$HOME/.bashrc"
PROJECT_DIR="$(dirname "$(realpath "$0")")"
SRC_DIR="$PROJECT_DIR/src"
MAIN_LUA="$SRC_DIR/main.lua"
WRAPPER="$PROJECT_DIR/luna-run.sh"

if [ ! -f "$MAIN_LUA" ]; then
    echo "Error: src/main.lua not found. Make sure install.sh is in your project root."
    exit 1
fi


# Aliases with nested quotes break in .bashrc;
cat > "$WRAPPER" << EOF
#!/bin/bash
export LUA_PATH="$SRC_DIR/?.lua;$PROJECT_DIR/?.lua;;"
exec lua "$MAIN_LUA" "\$@"
EOF

chmod +x "$WRAPPER"

# --- Register the wrapper as an alias in .bashrc ---
ALIAS_LINE="alias $ALIAS_NAME='$WRAPPER'"

if grep -qF "alias $ALIAS_NAME=" "$BASHRC"; then
    sed -i "/alias $ALIAS_NAME=/d" "$BASHRC"
    sed -i "/# Added by $ALIAS_NAME/d" "$BASHRC"
fi

echo "" >> "$BASHRC"
echo "# Added by $ALIAS_NAME install.sh" >> "$BASHRC"
echo "$ALIAS_LINE" >> "$BASHRC"

echo " Wrapper created:  $WRAPPER"
echo " Alias registered: $ALIAS_NAME -> $WRAPPER"
echo ""
echo "  Activate it now:  source $BASHRC"
echo "  Then run:         $ALIAS_NAME commit"
