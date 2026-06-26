#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

case "$(uname -s)" in
  Darwin) OS="darwin" ;;
  Linux)  OS="linux"  ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU stow is not installed." >&2
  case "$OS" in
    darwin) echo "Install with: brew install stow" >&2 ;;
    linux)  echo "Install with your package manager, e.g. pacman -S stow / apt install stow" >&2 ;;
  esac
  exit 1
fi

COMMON=(git lazygit tmux zsh ruby nvim)
DARWIN_ONLY=(hammerspoon)
LINUX_ONLY=(fontconfig hypr quickshell niri chrome)

ACTION="${1:-install}"
case "$ACTION" in
  install)   STOW_FLAGS=(-v) ;;
  uninstall) STOW_FLAGS=(-v -D) ;;
  restow)    STOW_FLAGS=(-v -R) ;;
  *)
    echo "Usage: $0 [install|uninstall|restow]" >&2
    exit 1
    ;;
esac

packages=("${COMMON[@]}")
case "$OS" in
  darwin) packages+=("${DARWIN_ONLY[@]}"); STOW_FLAGS+=(--ignore='\.linux$')  ;;
  linux)  packages+=("${LINUX_ONLY[@]}");  STOW_FLAGS+=(--ignore='\.darwin$') ;;
esac

failed=0
for pkg in "${packages[@]}"; do
  echo "==> $ACTION $pkg → $HOME"
  if ! stow "${STOW_FLAGS[@]}" -t "$HOME" "$pkg"; then
    failed=1
    echo "    failed: $pkg" >&2
  fi
done

if (( failed )); then
  cat >&2 <<'EOF'

One or more packages failed. Common causes:
  - A real file already exists at the target (e.g. ~/.zshrc).
    Back it up first:  mv ~/.zshrc ~/.zshrc.bak
  - A target directory is owned by another package.
    Inspect with: ls -la ~/.<file> and remove the conflicting file/dir.
EOF
  exit 1
fi

echo "Done ($OS, action=$ACTION)."
