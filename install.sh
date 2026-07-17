#!/usr/bin/env bash
# Dotfiles installation script — macOS only
# Usage: ./install.sh [--skip-packages] [--skip-shell]

set -Eeuo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  IS_TTY=true
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[1;33m'
  BLUE=$'\033[0;34m'
  CYAN=$'\033[0;36m'
  DIM=$'\033[2m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  IS_TTY=false
  RED='' GREEN='' YELLOW='' BLUE='' CYAN='' DIM='' BOLD='' RESET=''
fi

# ─── Helpers ──────────────────────────────────────────────────────────────────

info() { printf '  %s→%s %s\n' "$CYAN" "$RESET" "$*"; }
success() { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
error() { printf '  %s✗%s %s\n' "$RED" "$RESET" "$*" >&2; }

TOTAL_STEPS=10
CURRENT_STEP=0

step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  local title=" ${CURRENT_STEP}/${TOTAL_STEPS} · $* "
  local fill=$((58 - ${#title}))
  ((fill < 3)) && fill=3
  printf '\n%s▐%s%s%s%s' "$BLUE" "$BOLD" "$title" "$RESET" "$DIM"
  printf '─%.0s' $(seq 1 "$fill")
  printf '%s\n' "$RESET"
}

cleanup() { [[ "$IS_TTY" == true ]] && printf '\033[?25h' || true; }
on_error() {
  cleanup
  error "Installation aborted while running: $BASH_COMMAND"
}
trap cleanup EXIT
trap on_error ERR

# Run a command behind a spinner; output goes to a log shown only on failure.
SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

run() {
  local msg="$1"
  shift
  local log rc=0
  log="$(mktemp "${TMPDIR:-/tmp}/dotfiles-install.XXXXXX")"

  if [[ "$IS_TTY" == true ]]; then
    "$@" >"$log" 2>&1 &
    local pid=$! i=0
    printf '\033[?25l'
    while kill -0 "$pid" 2>/dev/null; do
      printf '\r  %s%s%s %s' "$CYAN" "${SPINNER_FRAMES[$((i % 10))]}" "$RESET" "$msg"
      i=$((i + 1))
      sleep 0.08
    done
    wait "$pid" || rc=$?
    printf '\r\033[K\033[?25h'
  else
    info "$msg"
    "$@" >"$log" 2>&1 || rc=$?
  fi

  if ((rc != 0)); then
    tail -n 5 "$log" | sed "s/^/      ${DIM}│${RESET} /"
  fi
  rm -f "$log"
  return "$rc"
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Stats for the final summary
COUNT_INSTALLED=0
COUNT_PRESENT=0
FAILED_ITEMS=()

SKIP_PACKAGES=false
SKIP_SHELL=false

usage() {
  cat <<EOF
Usage: ./install.sh [options]

Options:
  --skip-packages   Skip Homebrew taps and package installation
  --skip-shell      Skip changing the default shell to fish
  -h, --help        Show this help
EOF
}

for arg in "$@"; do
  case "$arg" in
  --skip-packages) SKIP_PACKAGES=true ;;
  --skip-shell) SKIP_SHELL=true ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown argument: $arg" >&2
    usage >&2
    exit 1
    ;;
  esac
done

# ─── Banner ───────────────────────────────────────────────────────────────────

print_banner() {
  local lines=(
    '   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗'
    '   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝'
    '   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗'
    '   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║'
    '   ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║'
    '   ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝'
  )
  local colors=(51 45 39 33 63 93)
  local i
  echo
  for i in "${!lines[@]}"; do
    if [[ "$IS_TTY" == true ]]; then
      printf '\033[38;5;%sm%s\033[0m\n' "${colors[$i]}" "${lines[$i]}"
    else
      printf '%s\n' "${lines[$i]}"
    fi
  done
  printf '\n   %sJacobo Blandón Castro — dotfiles installer%s\n' "$BOLD" "$RESET"
  printf '   Dotfiles path: %s%s%s\n' "$CYAN" "$DOTFILES_DIR" "$RESET"
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
    run "Updating Homebrew..." brew update --quiet &&
      success "Homebrew up to date" || warn "brew update failed — continuing"
  else
    info "Installing Homebrew (may prompt for your password)..."
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
  git        # version control
  fish       # shell
  neovim     # editor
  starship   # prompt
  fzf        # fuzzy finder
  zoxide     # smart cd
  atuin      # shell history with sync
  carapace   # shell completions
  eza        # modern ls (used as ls, ll, tree)
  bat        # modern cat
  zellij     # terminal multiplexer
  tmux       # terminal multiplexer (alt config)
  btop       # system / process monitor
  ranger     # TUI file manager
  television # TUI fuzzy launcher
  fastfetch  # system info banner
  pyenv      # Python version manager
  ripgrep    # fast grep (required by nvim plugins)
  fd         # fast find (required by nvim fzf.lua)
  lazygit    # git TUI (integrated in nvim)
  node       # Node.js runtime (nvim LSP servers, Copilot)
  pipx       # isolated Python CLI tool installer
  herdr      # terminal agent multiplexer
)

BREW_CASKS=(
  ghostty                       # terminal emulator
  font-jetbrains-mono-nerd-font # fallback nerd font for icons & glyphs
)

INSTALLED_FORMULAE=""
INSTALLED_CASKS=""

brew_install() {
  local pkg="$1"
  local is_cask="${2:-false}"
  local installed_list="$INSTALLED_FORMULAE"
  local -a cmd=(brew install "$pkg")

  if [[ "$is_cask" == "true" ]]; then
    installed_list="$INSTALLED_CASKS"
    cmd=(brew install --cask "$pkg")
  fi

  if grep -qx "$pkg" <<<"$installed_list"; then
    info "$pkg ${DIM}already installed${RESET}"
    COUNT_PRESENT=$((COUNT_PRESENT + 1))
    return
  fi

  if run "Installing $pkg..." "${cmd[@]}"; then
    success "$pkg installed"
    COUNT_INSTALLED=$((COUNT_INSTALLED + 1))
  else
    warn "Failed to install: $pkg"
    FAILED_ITEMS+=("$pkg")
  fi
}

install_packages() {
  step "CLI tools"
  if [[ "$SKIP_PACKAGES" == "true" ]]; then
    warn "Skipping package installation (--skip-packages)"
  else
    # Query installed packages once instead of per-package (much faster)
    INSTALLED_FORMULAE="$(brew list --formula -1 2>/dev/null || true)"
    INSTALLED_CASKS="$(brew list --cask -1 2>/dev/null || true)"

    local pkg
    for pkg in "${BREW_PACKAGES[@]}"; do
      brew_install "$pkg"
    done
  fi

  step "Cask applications"
  if [[ "$SKIP_PACKAGES" == "true" ]]; then
    warn "Skipping cask installation (--skip-packages)"
  else
    local cask
    for cask in "${BREW_CASKS[@]}"; do
      brew_install "$cask" true
    done
  fi

  step "posting (TUI HTTP client)"
  if [[ "$SKIP_PACKAGES" == "true" ]]; then
    warn "Skipping posting installation (--skip-packages)"
  elif command -v posting &>/dev/null; then
    info "posting ${DIM}already installed${RESET}"
    COUNT_PRESENT=$((COUNT_PRESENT + 1))
  elif command -v pipx &>/dev/null; then
    if run "Installing posting via pipx..." pipx install posting; then
      success "posting installed"
      COUNT_INSTALLED=$((COUNT_INSTALLED + 1))
    else
      warn "Failed to install posting"
      FAILED_ITEMS+=(posting)
    fi
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
  success "$(basename "$dest") ${DIM}→ $src${RESET}"
}

# Directories in this repo symlinked as-is into ~/.config/<name>
CONFIG_DIRS=(
  fish nvim ghostty zellij tmux atuin btop ranger posting herdr git
  fastfetch television
)

create_symlinks() {
  step "Config symlinks"

  local cfg="$HOME/.config"
  local dir

  for dir in "${CONFIG_DIRS[@]}"; do
    backup_and_link "$DOTFILES_DIR/$dir" "$cfg/$dir"
  done

  backup_and_link "$DOTFILES_DIR/starship.toml" "$cfg/starship.toml"
  backup_and_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
}

# ─── tmux & ranger plugins ────────────────────────────────────────────────────

clone_if_missing() {
  local name="$1" url="$2" dest="$3"
  if [[ -d "$dest" ]]; then
    info "$name ${DIM}already installed${RESET}"
    return
  fi
  run "Cloning $name..." git clone --depth 1 "$url" "$dest" &&
    success "$name installed" || warn "Failed to clone: $name"
}

bootstrap_plugins() {
  step "tmux & ranger plugins"

  local tpm_dir="$DOTFILES_DIR/tmux/plugins/tpm"
  clone_if_missing tpm https://github.com/tmux-plugins/tpm "$tpm_dir"

  # tpm installs the plugins declared in tmux.conf next to itself
  if command -v tmux &>/dev/null && [[ -x "$tpm_dir/bin/install_plugins" ]]; then
    run "Installing tmux plugins (tpm)..." "$tpm_dir/bin/install_plugins" &&
      success "tmux plugins installed" ||
      warn "Some tmux plugins failed — run prefix + I inside tmux"
  else
    warn "tmux or tpm not available — install plugins later with prefix + I"
  fi

  clone_if_missing ranger_devicons https://github.com/alexanderjeurissen/ranger_devicons \
    "$DOTFILES_DIR/ranger/plugins/ranger_devicons"
}

# ─── Wallpapers ───────────────────────────────────────────────────────────────

install_wallpapers() {
  step "Wallpapers"
  local dest="$HOME/Pictures/Wallpapers"
  local copied=0
  mkdir -p "$dest"
  local img target
  while IFS= read -r img; do
    target="$dest/$(basename "$img")"
    if [[ ! -f "$target" ]]; then
      cp "$img" "$target"
      copied=$((copied + 1))
    fi
  done < <(find "$DOTFILES_DIR/wallpapers" -type f ! -name '.DS_Store')
  success "Wallpapers at $dest ${DIM}(${copied} new)${RESET}"
}

# ─── Default shell ────────────────────────────────────────────────────────────

set_fish_shell() {
  step "Default shell → fish"

  if [[ "$SKIP_SHELL" == "true" ]]; then
    warn "Skipping shell change (--skip-shell)"
    return
  fi

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

  # Run headless sync; ignore non-zero exit from plugins that need manual auth
  run "Installing plugins with lazy.nvim (headless)..." nvim --headless "+Lazy! sync" +qa &&
    success "Plugins installed" ||
    warn "Some plugins may need manual setup inside Neovim (:Lazy sync)"
}

# ─── Final notes ──────────────────────────────────────────────────────────────

print_summary() {
  local mins=$((SECONDS / 60)) secs=$((SECONDS % 60))

  printf '\n%s' "$DIM"
  printf '─%.0s' $(seq 1 60)
  printf '%s\n' "$RESET"
  printf '  %s%s✓ Installation complete%s — %dm %ds\n' "$BOLD" "$GREEN" "$RESET" "$mins" "$secs"
  printf '    %s%d installed · %d already present · %d failed%s\n' \
    "$DIM" "$COUNT_INSTALLED" "$COUNT_PRESENT" "${#FAILED_ITEMS[@]}" "$RESET"
  if ((${#FAILED_ITEMS[@]} > 0)); then
    warn "Failed: ${FAILED_ITEMS[*]} — re-run the script or install manually"
  fi
  if [[ -d "$BACKUP_DIR" ]]; then
    printf '    %sBackups:%s %s\n' "$YELLOW" "$RESET" "$BACKUP_DIR"
  fi
  printf '%s' "$DIM"
  printf '─%.0s' $(seq 1 60)
  printf '%s\n' "$RESET"

  printf '\n%s  Manual steps:%s\n\n' "$BOLD" "$RESET"
  printf '  %s1. Dank Mono%s\n' "$YELLOW" "$RESET"
  printf '     Paid font used in Ghostty. Purchase and install from https://dank.sh\n'
  printf '     Until then, Ghostty will fall back to JetBrainsMono Nerd Font.\n\n'
  printf '  %s2. Restart your terminal%s\n' "$YELLOW" "$RESET"
  printf '     Open a new terminal window to load the fish shell config.\n\n'
  printf '  %s3. Neovim — authenticate tools%s\n' "$YELLOW" "$RESET"
  printf '     %s:Copilot auth%s         → GitHub Copilot\n' "$CYAN" "$RESET"
  printf '     %s:CodeCompanion auth%s   → CodeCompanion (if needed)\n\n' "$CYAN" "$RESET"
  printf '  %s4. Atuin — sync history%s\n' "$YELLOW" "$RESET"
  printf '     %satuin login%s  → log in to sync shell history across machines\n' "$CYAN" "$RESET"
  printf '     %satuin sync%s   → pull history\n\n' "$CYAN" "$RESET"
  printf '  %s5. pyenv — install a Python version%s\n' "$YELLOW" "$RESET"
  printf '     %spyenv install 3.12%s\n' "$CYAN" "$RESET"
  printf '     %spyenv global 3.12%s\n\n' "$CYAN" "$RESET"
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
  print_banner
  check_macos
  install_homebrew
  install_packages
  create_symlinks
  bootstrap_plugins
  install_wallpapers
  set_fish_shell
  bootstrap_neovim
  print_summary
}

main "$@"
