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

if ! command -v stow &>/dev/null; then
    info "Installing stow and tmux via apt..."
    sudo apt update -qq && sudo apt install -y stow tmux
else
    ok "stow and tmux already installed"
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
brew bundle install --file="$DOTFILES/Brewfile" --no-lock
ok "Brew packages installed"

# =============================================================================
# 4. oh-my-zsh
# =============================================================================

info "Checking oh-my-zsh..."

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing oh-my-zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    ok "oh-my-zsh already installed"
fi

# =============================================================================
# 5. Powerlevel10k theme
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
# 6. zsh plugins
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
# 7. fzf-git.sh
# =============================================================================

info "Checking fzf-git.sh..."

if [[ ! -f "$HOME/fzf-git.sh/fzf-git.sh" ]]; then
    info "Cloning fzf-git.sh..."
    git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/fzf-git.sh"
else
    ok "fzf-git.sh already installed"
fi

# =============================================================================
# 8. TPM (tmux plugin manager)
# =============================================================================

info "Checking TPM..."

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    info "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    ok "TPM already installed"
fi

# =============================================================================
# 9. nvm
# =============================================================================

info "Checking nvm..."

if [[ ! -d "$HOME/.nvm" ]]; then
    info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
    ok "nvm already installed"
fi

# =============================================================================
# 10. Stow all packages
# =============================================================================

info "Stowing packages..."

cd "$DOTFILES"

for pkg in zsh tmux git nvim beets bin; do
    if stow --no-folding "$pkg" 2>/dev/null; then
        ok "stowed $pkg"
    else
        warn "$pkg has conflicts — run 'stow --no-folding $pkg' manually to resolve"
    fi
done

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
echo "  2. Start a new shell to load zsh config:"
echo "       zsh"
echo ""
echo "  3. Configure the prompt (first time only):"
echo "       p10k configure"
echo ""
echo "  4. Open tmux and install plugins:"
echo "       tmux new -s main"
echo "       # then press: prefix + I  (C-a I)"
echo ""
echo "  5. Open nvim and sync plugins:"
echo "       nvim  →  :Lazy sync"
echo ""
