#!/usr/bin/env bash
# ==============================================================================
# Qt6 Breeze Theme Installer for Mozilla Firefox
# Installs complete UI & UX theme matching KDE Plasma 6 Dolphin (Qt6 Breeze)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_PROFILE=""
UNINSTALL=false

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --profile <path>    Specify custom Firefox profile directory
  --uninstall         Remove installed theme from Firefox profile
  --help, -h          Show this help message

EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      TARGET_PROFILE="$2"
      shift 2
      ;;
    --uninstall)
      UNINSTALL=true
      shift
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      show_help
      exit 1
      ;;
  esac
done

# Detect Firefox profile if not provided
if [[ -z "$TARGET_PROFILE" ]]; then
  POSSIBLE_DIRS=(
    "$HOME/.config/mozilla/firefox"
    "$HOME/.mozilla/firefox"
    "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
    "$HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox"
    "$HOME/snap/firefox/common/.mozilla/firefox"
  )

  for base_dir in "${POSSIBLE_DIRS[@]}"; do
    if [[ -f "$base_dir/profiles.ini" ]]; then
      # Find default release profile
      if grep -q "Default=" "$base_dir/profiles.ini"; then
        # Check for [Install...] default first
        def_path=$(sed -n '/^\[Install/{n;p;}' "$base_dir/profiles.ini" | sed -n 's/^Default=//p' | head -n 1)
        if [[ -z "$def_path" ]]; then
          def_path=$(grep -E '^Path=' "$base_dir/profiles.ini" | head -n 1 | cut -d= -f2)
        fi

        if [[ -n "$def_path" ]]; then
          if [[ -d "$base_dir/$def_path" ]]; then
            TARGET_PROFILE="$base_dir/$def_path"
            break
          fi
        fi
      fi
    fi
  done
fi

if [[ -z "$TARGET_PROFILE" || ! -d "$TARGET_PROFILE" ]]; then
  echo "Error: Could not locate a valid Firefox profile directory."
  echo "Please specify one manually using: $0 --profile /path/to/profile"
  exit 1
fi

echo "Target Firefox Profile: $TARGET_PROFILE"
CHROME_DIR="$TARGET_PROFILE/chrome"

if $UNINSTALL; then
  echo "Uninstalling Qt6 Breeze theme..."
  rm -f "$CHROME_DIR/userChrome.css"
  rm -f "$CHROME_DIR/userContent.css"
  rm -f "$CHROME_DIR/breeze-theme.css"
  rm -f "$CHROME_DIR/breeze-icons.css"
  rm -f "$CHROME_DIR/breeze-content.css"
  rm -f "$CHROME_DIR/kde-colors.css"
  rm -f "$CHROME_DIR/kde-colors-content.css"
  rm -rf "$CHROME_DIR/icons"
  echo "Qt6 Breeze theme uninstalled successfully."
  exit 0
fi

# Ensure chrome directory exists
mkdir -p "$CHROME_DIR"

# Copy theme files
echo "Installing theme files..."
cp "$SCRIPT_DIR/userChrome.css" "$CHROME_DIR/"
cp "$SCRIPT_DIR/userContent.css" "$CHROME_DIR/"
cp "$SCRIPT_DIR/breeze-theme.css" "$CHROME_DIR/"
cp "$SCRIPT_DIR/breeze-icons.css" "$CHROME_DIR/"
cp "$SCRIPT_DIR/breeze-content.css" "$CHROME_DIR/"

if [[ -f "$SCRIPT_DIR/kde-colors.css" ]]; then
  cp "$SCRIPT_DIR/kde-colors.css" "$CHROME_DIR/"
fi
if [[ -f "$SCRIPT_DIR/kde-colors-content.css" ]]; then
  cp "$SCRIPT_DIR/kde-colors-content.css" "$CHROME_DIR/"
fi

# Copy Breeze SVG icons
echo "Installing Breeze icons..."
rm -rf "$CHROME_DIR/icons"
cp -r "$SCRIPT_DIR/icons" "$CHROME_DIR/"

# Configure user.js
USER_JS="$TARGET_PROFILE/user.js"
touch "$USER_JS"

add_pref_if_missing() {
  local pref="$1"
  local val="$2"
  if ! grep -q "$pref" "$USER_JS" 2>/dev/null; then
    echo "user_pref(\"$pref\", $val);" >> "$USER_JS"
    echo "  Added pref: $pref = $val"
  fi
}

echo "Configuring Firefox preferences in user.js..."
add_pref_if_missing "toolkit.legacyUserProfileCustomizations.stylesheets" "true"
add_pref_if_missing "layout.css.prefers-color-scheme.content-override" "2"
add_pref_if_missing "widget.use-xdg-desktop-portal.file-picker" "1"
add_pref_if_missing "browser.tabs.inTitlebar" "0"
add_pref_if_missing "widget.use-xdg-desktop-portal.mime-handler" "1"
add_pref_if_missing "widget.use-xdg-desktop-portal.open-uri" "1"

echo ""
echo "=================================================================="
echo "Qt6 Breeze Firefox Theme installed successfully!"
echo "Please restart Firefox to apply the changes."
echo "=================================================================="
