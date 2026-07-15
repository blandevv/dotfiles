#!/usr/bin/env bash
# Dotfiles installation script — macOS only
# Usage: ./install.sh [--skip-packages] [--skip-shell]

set -euo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ─── Helpers ──────────────────────────────────────────────────────────────────

info() { echo -e "${CYAN}  →${RESET} $*"; }
success() { echo -e "${GREEN}  ✓${RESET} $*"; }
warn() { echo -e "${YELLOW}  !${RESET} $*"; }
error() { echo -e "${RED}  ✗${RESET} $*" >&2; }
step() { echo -e "\n${BOLD}${BLUE}══ $* ══${RESET}"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

SKIP_PACKAGES=false
SKIP_SHELL=false

for arg in "$@"; do
  case "$arg" in
  --skip-packages) SKIP_PACKAGES=true ;;
  --skip-shell) SKIP_SHELL=true ;;
  *)
    echo "Unknown argument: $arg" >&2
    exit 1
    ;;
  esac
done

# ─── Banner ───────────────────────────────────────────────────────────────────

print_banner() {
  echo -e "${CYAN}"
  echo '   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗'
  echo '   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝'
  echo '   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗'
  echo '   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║'
  echo '   ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║'
  echo '   ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝'
  echo -e "${RESET}"
  echo -e "   ${BOLD}Jacobo Blandón Castro — dotfiles installer${RESET}"
  echo -e "   Dotfiles path: ${CYAN}${DOTFILES_DIR}${RESET}\n"
}

# ─── OS check ─────────────────────────────────────────────────────────────────

check_macos() {
  step "System check"
  if [[ "$(uname)" != "Darwin" ]]; then
    error "This installer only supports macOS."
    exit 1
  fi
  local macos_version
  macos_version="$(sw_vers -productVersion)"
  success "macOS ${macos_version} detected"
}

# ─── Homebrew ─────────────────────────────────────────────────────────────────

install_homebrew() {
  step "Homebrew"
  if command -v brew &>/dev/null; then
    info "Homebrew already installed — updating..."
    brew update --quiet
    success "Homebrew up to date"
  else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Apple Silicon path fix
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew installed"
  fi
}

# ─── Packages ─────────────────────────────────────────────────────────────────

BREW_PACKAGES=(
  git      # version control
  fish     # shell
  neovim   # editor
  starship # prompt
  fzf      # fuzzy finder
  zoxide   # smart cd
  atuin    # shell history with sync
  carapace # shell completions
  eza      # modern ls (used as ls, ll, tree)
  bat      # modern cat
  zellij   # terminal multiplexer
  btop     # system / process monitor
  ranger   # TUI file manager
  pyenv    # Python version manager
  ripgrep  # fast grep (required by nvim plugins)
  fd       # fast find (required by nvim fzf.lua)
  lazygit  # git TUI (integrated in nvim)
  node     # Node.js runtime (nvim LSP servers, Copilot)
  pipx     # isolated Python CLI tool installer
  herdr    # terminal agent multiplexer
)

BREW_CASKS=(
  ghostty                       # terminal emulator
  font-jetbrains-mono-nerd-font # fallback nerd font for icons & glyphs
)

brew_install() {
  local pkg="$1"
  local is_cask="${2:-false}"

  if [[ "$is_cask" == "true" ]]; then
    if brew list --cask "$pkg" &>/dev/null 2>&1; then
      info "$pkg already installed"
      return
    fi
    brew install --cask "$pkg" && success "$pkg installed" || warn "Failed to install cask: $pkg"
  else
    if brew list "$pkg" &>/dev/null 2>&1; then
      info "$pkg already installed"
      return
    fi
    brew install "$pkg" && success "$pkg installed" || warn "Failed to install: $pkg"
  fi
}

install_packages() {
  if [[ "$SKIP_PACKAGES" == "true" ]]; then
    warn "Skipping package installation (--skip-packages)"
    return
  fi

  step "CLI tools"
  for pkg in "${BREW_PACKAGES[@]}"; do
    brew_install "$pkg"
  done

  step "Cask applications"
  # Add nerd-fonts tap once
  brew tap homebrew/cask-fonts 2>/dev/null || true
  for cask in "${BREW_CASKS[@]}"; do
    brew_install "$cask" true
  done

  step "posting (TUI HTTP client)"
  if command -v posting &>/dev/null; then
    info "posting already installed"
  elif command -v pipx &>/dev/null; then
    pipx install posting && success "posting installed via pipx" || warn "Failed to install posting"
  else
    warn "pipx not found — skipping posting. Install manually: pipx install posting"
  fi
}

# ─── Symlinks ─────────────────────────────────────────────────────────────────

backup_and_link() {
  local src="$1"
  local dest="$2"

  # Back up existing non-symlink file or directory
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    info "Backing up $(basename "$dest") → $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  fi

  # Remove stale/wrong symlink
  [[ -L "$dest" ]] && rm "$dest"

  mkdir -p "$(dirname "$dest")"
  ln -sf "$src" "$dest"
  success "$(basename "$dest") → $src"
}

create_symlinks() {
  step "Config symlinks"

  local cfg="$HOME/.config"

  backup_and_link "$DOTFILES_DIR/fish" "$cfg/fish"
  backup_and_link "$DOTFILES_DIR/nvim" "$cfg/nvim"
  backup_and_link "$DOTFILES_DIR/ghostty" "$cfg/ghostty"
  backup_and_link "$DOTFILES_DIR/zellij" "$cfg/zellij"
  backup_and_link "$DOTFILES_DIR/atuin" "$cfg/atuin"
  backup_and_link "$DOTFILES_DIR/btop" "$cfg/btop"
  backup_and_link "$DOTFILES_DIR/ranger" "$cfg/ranger"
  backup_and_link "$DOTFILES_DIR/posting" "$cfg/posting"
  backup_and_link "$DOTFILES_DIR/herdr" "$cfg/herdr"
  backup_and_link "$DOTFILES_DIR/git" "$cfg/git"
  backup_and_link "$DOTFILES_DIR/starship.toml" "$cfg/starship.toml"
  backup_and_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
}

# ─── Wallpapers ───────────────────────────────────────────────────────────────

install_wallpapers() {
  step "Wallpapers"
  local dest="$HOME/Pictures/Wallpapers"
  mkdir -p "$dest"
  # Copy only new files (-n), silently skip .DS_Store
  find "$DOTFILES_DIR/wallpapers" -type f ! -name '.DS_Store' | while read -r img; do
    local target="$dest/$(basename "$img")"
    if [[ ! -f "$target" ]]; then
      cp "$img" "$target"
      info "Copied $(basename "$img")"
    fi
  done
  success "Wallpapers available at $dest"
}

# ─── Default shell ────────────────────────────────────────────────────────────

set_fish_shell() {
  if [[ "$SKIP_SHELL" == "true" ]]; then
    warn "Skipping shell change (--skip-shell)"
    return
  fi

  step "Default shell → fish"

  local fish_path
  fish_path="$(command -v fish 2>/dev/null || echo "")"

  if [[ -z "$fish_path" ]]; then
    warn "fish not found in PATH — skipping shell change"
    return
  fi

  if ! grep -qF "$fish_path" /etc/shells 2>/dev/null; then
    info "Adding $fish_path to /etc/shells (requires sudo)..."
    echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi

  if [[ "$SHELL" != "$fish_path" ]]; then
    chsh -s "$fish_path"
    success "Default shell changed to $fish_path"
  else
    info "fish is already the default shell"
  fi
}

# ─── Neovim ───────────────────────────────────────────────────────────────────

bootstrap_neovim() {
  step "Neovim — plugin bootstrap"
  if ! command -v nvim &>/dev/null; then
    warn "nvim not found — skipping plugin bootstrap"
    return
  fi

  info "Installing plugins with lazy.nvim (headless)..."
  # Run headless sync; ignore non-zero exit from plugins that need manual auth
  nvim --headless "+Lazy! sync" +qa 2>/dev/null && success "Plugins installed" ||
    warn "Some plugins may need manual setup inside Neovim (:Lazy sync)"
}

# ─── Final notes ──────────────────────────────────────────────────────────────

print_notes() {
  echo -e "\n${BOLD}${GREEN}  Installation complete!${RESET}\n"

  if [[ -d "$BACKUP_DIR" ]]; then
    echo -e "  ${YELLOW}Backups:${RESET} $BACKUP_DIR\n"
  fi

  echo -e "${BOLD}  Manual steps:${RESET}"
  echo -e ""
  echo -e "  ${YELLOW}1. Dank Mono${RESET}"
  echo -e "     Paid font used in Ghostty. Purchase and install from https://dank.sh"
  echo -e "     Until then, Ghostty will fall back to JetBrainsMono Nerd Font."
  echo -e ""
  echo -e "  ${YELLOW}2. Restart your terminal${RESET}"
  echo -e "     Open a new terminal window to load the fish shell config."
  echo -e ""
  echo -e "  ${YELLOW}3. Neovim — authenticate tools${RESET}"
  echo -e "     ${CYAN}:Copilot auth${RESET}         → GitHub Copilot"
  echo -e "     ${CYAN}:CodeCompanion auth${RESET}   → CodeCompanion (if needed)"
  echo -e ""
  echo -e "  ${YELLOW}4. Atuin — sync history${RESET}"
  echo -e "     ${CYAN}atuin login${RESET}  → log in to sync shell history across machines"
  echo -e "     ${CYAN}atuin sync${RESET}   → pull history"
  echo -e ""
  echo -e "  ${YELLOW}5. pyenv — install a Python version${RESET}"
  echo -e "     ${CYAN}pyenv install 3.12${RESET}"
  echo -e "     ${CYAN}pyenv global 3.12${RESET}"
  echo -e ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
  print_banner
  check_macos
  install_homebrew
  install_packages
  create_symlinks
  install_wallpapers
  set_fish_shell
  bootstrap_neovim
  print_notes
}

main "$@"
