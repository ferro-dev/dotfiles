#!/usr/bin/env bash
#
# install.sh — bootstrap a new Linux machine from this dotfiles repo.
#
# Usage:
#   git clone https://github.com/ferro-dev/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && bash install.sh
#
# Idempotent — safe to re-run on an already configured machine.

set -e

DOTFILES="$HOME/dotfiles"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[install]${NC} $1"; }
warn()    { echo -e "${YELLOW}[install]${NC} $1"; }
error()   { echo -e "${RED}[install]${NC} $1"; exit 1; }
ok()      { echo -e "${GREEN}[install]${NC} ✓ $1"; }

# =============================================================================
# 1. apt dependencies
# =============================================================================

info "Checking apt dependencies..."

APT_PACKAGES=()
command -v stow    &>/dev/null || APT_PACKAGES+=(stow)
command -v tmux    &>/dev/null || APT_PACKAGES+=(tmux)
command -v zsh     &>/dev/null || APT_PACKAGES+=(zsh)
command -v flatpak &>/dev/null || APT_PACKAGES+=(flatpak)

if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
    info "Installing via apt: ${APT_PACKAGES[*]}..."
    sudo apt update -qq && sudo apt install -y "${APT_PACKAGES[@]}"
else
    ok "apt dependencies already installed"
fi

info "Checking Flathub remote..."
if ! flatpak remotes 2>/dev/null | grep -q flathub; then
    info "Adding Flathub remote..."
    if flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
        ok "Flathub remote added"
    else
        warn "Could not add Flathub remote (D-Bus unavailable? Run manually: flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo)"
    fi
else
    ok "Flathub remote already configured"
fi

# =============================================================================
# 2. Linuxbrew
# =============================================================================

info "Checking Linuxbrew..."

if ! command -v brew &>/dev/null; then
    info "Installing Linuxbrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    ok "Linuxbrew already installed"
fi

# =============================================================================
# 3. Brew packages (Brewfile)
# =============================================================================

info "Installing brew packages from Brewfile..."
if brew bundle install --file="$DOTFILES/Brewfile"; then
    ok "Brew packages installed"
else
    warn "Some packages failed (flatpak apps require Flathub to be configured first)"
fi

# =============================================================================
# 4. tree-sitter CLI
# =============================================================================
#
# The brew 'tree-sitter' formula installs only the C library, not the CLI
# binary. nvim-treesitter (main branch) requires the CLI >= 0.26.1 to build
# parsers. Install the prebuilt binary to ~/.local/bin directly.

info "Checking tree-sitter CLI..."

TREE_SITTER_VERSION="0.26.7"
TREE_SITTER_BIN="$HOME/.local/bin/tree-sitter"

_install_tree_sitter() {
    mkdir -p "$HOME/.local/bin"
    curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/v${TREE_SITTER_VERSION}/tree-sitter-linux-x64.gz" \
        | gunzip > "$TREE_SITTER_BIN"
    chmod +x "$TREE_SITTER_BIN"
    ok "tree-sitter CLI ${TREE_SITTER_VERSION} installed"
}

if command -v tree-sitter &>/dev/null; then
    TS_MINOR="$(tree-sitter --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | cut -d. -f2)"
    if [[ "${TS_MINOR:-0}" -ge 26 ]]; then
        ok "tree-sitter CLI already installed ($(tree-sitter --version 2>/dev/null))"
    else
        info "tree-sitter CLI too old, upgrading to ${TREE_SITTER_VERSION}..."
        _install_tree_sitter
    fi
else
    _install_tree_sitter
fi

# =============================================================================
# 5. oh-my-zsh
# =============================================================================

info "Checking oh-my-zsh..."

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing oh-my-zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Remove the generated .zshrc so stow can link ours
    [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]] && rm "$HOME/.zshrc"
else
    ok "oh-my-zsh already installed"
fi

# =============================================================================
# 6. Powerlevel10k theme
# =============================================================================

info "Checking powerlevel10k..."

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
    info "Cloning powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    ok "powerlevel10k already installed"
fi

# =============================================================================
# 7. zsh plugins
# =============================================================================

info "Checking zsh plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    info "Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    ok "zsh-autosuggestions already installed"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    info "Cloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    ok "zsh-syntax-highlighting already installed"
fi

# =============================================================================
# 8. fzf-git.sh
# =============================================================================

info "Checking fzf-git.sh..."

if [[ ! -f "$HOME/fzf-git.sh/fzf-git.sh" ]]; then
    info "Cloning fzf-git.sh..."
    git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/fzf-git.sh"
else
    ok "fzf-git.sh already installed"
fi

# =============================================================================
# 9. TPM (tmux plugin manager)
# =============================================================================

info "Checking TPM..."

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    info "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    ok "TPM already installed"
fi

# =============================================================================
# 10. nvm
# =============================================================================

info "Checking nvm..."

if [[ ! -d "$HOME/.nvm" ]]; then
    info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
    ok "nvm already installed"
fi

# =============================================================================
# 11. COSMIC theme (Catppuccin Macchiato)
# =============================================================================

info "Checking COSMIC theme..."

if command -v cosmic-settings &>/dev/null; then
    COSMIC_THEME_DIR="$HOME/.config/cosmic"
    mkdir -p "$COSMIC_THEME_DIR"

    info "Copying COSMIC Catppuccin theme files..."
    info "Import the desktop theme via: COSMIC Settings > Desktop > Appearance > Import"
    info "  File: $DOTFILES/cosmic/catppuccin-macchiato-mauve+round.ron"
    info "Import the terminal theme via: COSMIC Terminal > View > Color schemes > Import"
    info "  File: $DOTFILES/cosmic/catppuccin-macchiato.ron"
    ok "COSMIC theme files available"
else
    warn "COSMIC not found — skipping theme setup"
fi

# =============================================================================
# 12. Stow all packages
# =============================================================================

info "Stowing packages..."

cd "$DOTFILES"

for pkg in zsh tmux git nvim beets bin; do
    # First attempt: clean stow
    if stow --no-folding "$pkg" 2>/dev/null; then
        ok "stowed $pkg"
        continue
    fi

    # Second attempt: adopt pre-existing files then restore dotfiles versions.
    # This handles machines where real (non-symlinked) config files already exist
    # at the target paths (e.g. a previously hand-configured machine).
    if stow --adopt --no-folding "$pkg" 2>/dev/null; then
        git -C "$DOTFILES" restore "$pkg"
        ok "stowed $pkg (overwrote pre-existing config)"
    else
        warn "$pkg has conflicts — run 'stow --no-folding $pkg' manually to resolve"
    fi
done

# =============================================================================
# 13. Set default shell to zsh
# =============================================================================

info "Checking default shell..."

ZSH_PATH="$(command -v zsh)"
CURRENT_LOGIN_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$CURRENT_LOGIN_SHELL" == "$ZSH_PATH" ]]; then
    ok "Default shell is already zsh"
elif grep -qF "$ZSH_PATH" /etc/shells; then
    chsh -s "$ZSH_PATH"
    ok "Default shell changed to zsh (takes effect on next login)"
else
    warn "zsh not found in /etc/shells — run manually: chsh -s $ZSH_PATH"
fi

# =============================================================================
# Post-install notes
# =============================================================================

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Install complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo ""
echo "  1. Set your music directory (required for beets):"
echo "       export MUSIC_DIR=/path/to/your/music"
echo "     Add this to ~/.zshrc.local or your environment."
echo ""
echo "  2. Log out and back in (or open a new terminal) to get zsh as your shell."
echo ""
echo "  3. Open tmux and install plugins:"
echo "       tmux new -s main"
echo "       # then press: prefix + I  (C-a I)"
echo ""
echo "  4. Open nvim and sync plugins:"
echo "       nvim  →  :Lazy sync"
echo ""
echo "  5. Import COSMIC Catppuccin theme (if on COSMIC desktop):"
echo "       COSMIC Settings > Desktop > Appearance > Import"
echo "         → ~/dotfiles/cosmic/catppuccin-macchiato-mauve+round.ron"
echo "       COSMIC Terminal > View > Color schemes > Import"
echo "         → ~/dotfiles/cosmic/catppuccin-macchiato.ron"
echo ""
