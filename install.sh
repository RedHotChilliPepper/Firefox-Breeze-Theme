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
      if [[ $# -lt 2 || -z "$2" || "$2" == --* ]]; then
        echo "Error: --profile requires a Firefox profile directory." >&2
        exit 1
      fi
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
  POSSIBLE_DIRS=(
    "$HOME/.config/mozilla/firefox"
    "$HOME/.mozilla/firefox"
    "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
    "$HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox"
    "$HOME/snap/firefox/common/.mozilla/firefox"
  )

  # Firefox records the selected profile under [Install...] in profiles.ini.
  # Read that before looking for legacy *.default-release directories, which
  # can be stale after the user creates or switches to a custom profile.
  for base_dir in "${POSSIBLE_DIRS[@]}"; do
    [[ -f "$base_dir/profiles.ini" ]] || continue
    while IFS= read -r profile_path; do
      [[ -n "$profile_path" ]] || continue
      if [[ "$profile_path" = /* ]]; then
        candidate="$profile_path"
      else
        candidate="$base_dir/$profile_path"
      fi
      if [[ -d "$candidate" ]]; then
        already_added=false
        for existing in "${TARGET_PROFILES[@]}"; do
          if [[ "$existing" == "$candidate" ]]; then
            already_added=true
            break
          fi
        done
        if ! $already_added; then
          TARGET_PROFILES+=("$candidate")
        fi
      fi
    done < <(awk '
      function emit() {
        if (section ~ /^Install/ && default_path != "") print default_path
      }
      /^\[/ {
        emit()
        section = $0
        sub(/^\[/, "", section)
        sub(/\].*$/, "", section)
        default_path = ""
        next
      }
      section ~ /^Install/ && /^Default=/ {
        default_path = substr($0, 9)
        sub(/\r$/, "", default_path)
      }
      END { emit() }
    ' "$base_dir/profiles.ini")
    if [[ ${#TARGET_PROFILES[@]} -gt 0 ]]; then
      break
    fi
  done

  # Older profile registries may only mark a [Profile...] section as default.
  if [[ ${#TARGET_PROFILES[@]} -eq 0 ]]; then
    for base_dir in "${POSSIBLE_DIRS[@]}"; do
      [[ -f "$base_dir/profiles.ini" ]] || continue
      while IFS= read -r profile_path; do
        [[ -n "$profile_path" ]] || continue
        if [[ "$profile_path" = /* ]]; then
          candidate="$profile_path"
        else
          candidate="$base_dir/$profile_path"
        fi
        if [[ -d "$candidate" ]]; then
          TARGET_PROFILES+=("$candidate")
        fi
      done < <(awk '
        function emit() {
          if (section ~ /^Profile/ && is_default == "1" && path != "") print path
        }
        /^\[/ {
          emit()
          section = $0
          sub(/^\[/, "", section)
          sub(/\].*$/, "", section)
          path = ""
          is_default = ""
          next
        }
        section ~ /^Profile/ && /^Path=/ {
          path = substr($0, 6)
          sub(/\r$/, "", path)
        }
        section ~ /^Profile/ && /^Default=/ {
          is_default = substr($0, 9)
          sub(/\r$/, "", is_default)
        }
        END { emit() }
      ' "$base_dir/profiles.ini")
      if [[ ${#TARGET_PROFILES[@]} -gt 0 ]]; then
        break
      fi
    done
  fi

  # Keep legacy discovery for profiles without a usable registry.
  if [[ ${#TARGET_PROFILES[@]} -eq 0 ]]; then
    for base_dir in "${POSSIBLE_DIRS[@]}"; do
      [[ -d "$base_dir" ]] || continue
      for prof in "$base_dir"/*.default-release; do
        if [[ -d "$prof" ]]; then
          TARGET_PROFILES+=("$prof")
        fi
      done
      if [[ ${#TARGET_PROFILES[@]} -gt 0 ]]; then
        break
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
