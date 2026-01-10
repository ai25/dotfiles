  #!/usr/bin/env zsh
  set -euo pipefail

  DOTS="$HOME/dotfiles"

case "${1:-}" in
  hypr)
    stow -D -d "$DOTS" profile-caelestia shared 2>/dev/null || true
    stow -D -d "$DOTS" profile-hypr shared 2>/dev/null || true
    stow -d "$DOTS" profile-hypr shared
    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl reload >/dev/null 2>&1 || true
    fi
    ;;
  caelestia)
    stow -D -d "$DOTS" profile-hypr shared 2>/dev/null || true
    stow -D -d "$DOTS" profile-caelestia shared 2>/dev/null || true
    stow -d "$DOTS" profile-caelestia shared
    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl reload >/dev/null 2>&1 || true
    fi
    if command -v caelestia >/dev/null 2>&1; then
      caelestia shell -d >/dev/null 2>&1 || true
    fi
    ;;
    *)
      echo "usage: $0 {hypr|caelestia}"
      exit 1
      ;;
  esac
