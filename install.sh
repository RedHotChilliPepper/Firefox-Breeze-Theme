#!/usr/bin/env bash
# ==============================================================================
# Qt6 Breeze Theme Installer for Mozilla Firefox
# Installs complete UI & UX theme matching KDE Plasma 6 Dolphin (Qt6 Breeze)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_PROFILE=""
UNINSTALL=false
KDE_FRAME=true

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --profile <path>            Specify custom Firefox profile directory
  --kde-frame, --native-frame Disable integrated window frame and use native KDE window decoration (default)
  --integrated-frame, --csd   Keep integrated window frame with tabs in titlebar
  --uninstall                 Remove installed theme from Firefox profile
  --help, -h                  Show this help message

EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      TARGET_PROFILE="$2"
      shift 2
      ;;
    --kde-frame|--native-frame|--disable-integrated-frame|--system-titlebar|--kde-titlebar)
      KDE_FRAME=true
      shift
      ;;
    --integrated-frame|--csd|--enable-integrated-frame|--tabs-in-titlebar)
      KDE_FRAME=false
      shift
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
TARGET_PROFILES=()

if [[ -n "$TARGET_PROFILE" ]]; then
  if [[ ! -d "$TARGET_PROFILE" ]]; then
    echo "Error: Specified profile directory does not exist: $TARGET_PROFILE"
    exit 1
  fi
  TARGET_PROFILES+=("$TARGET_PROFILE")
else
  # Default target profiles for this workstation
  for p in "$HOME/.config/mozilla/firefox/87rk8jsb.default-release" \
           "$HOME/.config/mozilla/firefox/bvaocszu.default-release"; do
    if [[ -d "$p" ]]; then
      TARGET_PROFILES+=("$p")
    fi
  done

  # Fallback to scanning possible directories if none found
  if [[ ${#TARGET_PROFILES[@]} -eq 0 ]]; then
    POSSIBLE_DIRS=(
      "$HOME/.config/mozilla/firefox"
      "$HOME/.mozilla/firefox"
      "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
      "$HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox"
      "$HOME/snap/firefox/common/.mozilla/firefox"
    )

    for base_dir in "${POSSIBLE_DIRS[@]}"; do
      if [[ -d "$base_dir" ]]; then
        for prof in "$base_dir"/*.default-release; do
          if [[ -d "$prof" ]]; then
            TARGET_PROFILES+=("$prof")
          fi
        done
        if [[ ${#TARGET_PROFILES[@]} -gt 0 ]]; then
          break
        fi
      fi
      if [[ -f "$base_dir/profiles.ini" ]]; then
        # Find default release profile
        if grep -q "Default=" "$base_dir/profiles.ini"; then
          # Check for [Install...] default first
          def_path=$(sed -n '/^\[Install/{n;p;}' "$base_dir/profiles.ini" | sed -n 's/^Default=//p' | head -n 1)
          if [[ -z "$def_path" ]]; then
            def_path=$(grep -E '^Path=' "$base_dir/profiles.ini" | head -n 1 | cut -d= -f2)
          fi

          if [[ -n "$def_path" && -d "$base_dir/$def_path" ]]; then
            TARGET_PROFILES+=("$base_dir/$def_path")
            break
          fi
        fi
      fi
    done
  fi
fi

if [[ ${#TARGET_PROFILES[@]} -eq 0 ]]; then
  echo "Error: Could not locate a valid Firefox profile directory."
  echo "Please specify one manually using: $0 --profile /path/to/profile"
  exit 1
fi

for TARGET_PROFILE in "${TARGET_PROFILES[@]}"; do
  echo ""
  echo "=================================================================="
  echo "Target Firefox Profile: $TARGET_PROFILE"
  echo "=================================================================="
  CHROME_DIR="$TARGET_PROFILE/chrome"

  if $UNINSTALL; then
    echo "Uninstalling Qt6 Breeze theme from $TARGET_PROFILE..."
    rm -f "$CHROME_DIR/userChrome.css"
    rm -f "$CHROME_DIR/userContent.css"
    rm -f "$CHROME_DIR/palette.css"
    rm -f "$CHROME_DIR/breeze-theme.css"
    rm -f "$CHROME_DIR/breeze-icons.css"
    rm -f "$CHROME_DIR/breeze-content.css"
    rm -f "$CHROME_DIR/kde-colors.css"
    rm -f "$CHROME_DIR/kde-colors-content.css"
    rm -rf "$CHROME_DIR/components"
    rm -rf "$CHROME_DIR/icons"
    echo "Qt6 Breeze theme uninstalled successfully from $TARGET_PROFILE."
    continue
  fi

  # Ensure chrome directory exists
  mkdir -p "$CHROME_DIR"

  # Copy theme files
  echo "Installing theme files..."
  cp "$SCRIPT_DIR/userChrome.css" "$CHROME_DIR/"
  cp "$SCRIPT_DIR/userContent.css" "$CHROME_DIR/"
  cp "$SCRIPT_DIR/palette.css" "$CHROME_DIR/"
  cp "$SCRIPT_DIR/breeze-theme.css" "$CHROME_DIR/"
  cp "$SCRIPT_DIR/breeze-icons.css" "$CHROME_DIR/"
  cp "$SCRIPT_DIR/breeze-content.css" "$CHROME_DIR/"

  if [[ -f "$SCRIPT_DIR/kde-colors.css" ]]; then
    cp "$SCRIPT_DIR/kde-colors.css" "$CHROME_DIR/"
  fi
  if [[ -f "$SCRIPT_DIR/kde-colors-content.css" ]]; then
    cp "$SCRIPT_DIR/kde-colors-content.css" "$CHROME_DIR/"
  fi

  # Copy modular CSS components (including components/icons)
  echo "Installing theme components & Breeze icons..."
  rm -rf "$CHROME_DIR/components"
  rm -rf "$CHROME_DIR/icons"
  cp -r "$SCRIPT_DIR/components" "$CHROME_DIR/"

  # Configure user.js
  USER_JS="$TARGET_PROFILE/user.js"
  touch "$USER_JS"

  # Helper to set or update a preference in user.js
  set_pref() {
    local pref="$1"
    local val="$2"
    if grep -q "user_pref(\"$pref\"," "$USER_JS" 2>/dev/null; then
      sed -i "s|user_pref(\"$pref\",.*|user_pref(\"$pref\", $val);|" "$USER_JS"
      echo "  Updated pref: $pref = $val"
    else
      echo "user_pref(\"$pref\", $val);" >> "$USER_JS"
      echo "  Added pref: $pref = $val"
    fi
  }

  echo "Configuring Firefox preferences in user.js..."
  set_pref "toolkit.legacyUserProfileCustomizations.stylesheets" "true"
  set_pref "layout.css.prefers-color-scheme.content-override" "2"
  set_pref "widget.use-xdg-desktop-portal.file-picker" "1"
  set_pref "widget.use-xdg-desktop-portal.mime-handler" "1"
  set_pref "widget.use-xdg-desktop-portal.open-uri" "1"

  if $KDE_FRAME; then
    echo "Disabling integrated window frame -> using native KDE window decoration..."
    set_pref "browser.tabs.inTitlebar" "0"
  else
    echo "Enabling integrated window frame (tabs in titlebar)..."
    set_pref "browser.tabs.inTitlebar" "1"
  fi
done

echo ""
echo "=================================================================="
if $UNINSTALL; then
  echo "Qt6 Breeze Firefox Theme uninstalled successfully."
else
  echo "Qt6 Breeze Firefox Theme installed successfully on all target profiles!"
  echo "Please restart Firefox to apply the changes."
fi
echo "=================================================================="
