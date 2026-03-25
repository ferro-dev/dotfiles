# Brewfile
# Install everything with: brew bundle install
#
# Note: stow and tmux are managed by apt on this system, not brew.
# Ensure they are installed before running install.sh:
#   sudo apt install stow tmux

# ---- Terminal environment ----
brew "bat"           # better cat, theme set to Catppuccin Macchiato in .zshrc
brew "fd"            # fast find, used as fzf backend
brew "fzf"           # fuzzy finder
brew "gh"            # GitHub CLI
brew "git-delta"     # better git diffs, configured in .gitconfig
brew "navi"          # interactive cheatsheet tool, zsh widget in .zshrc
brew "neovim"        # editor
brew "thefuck"       # command correction, aliased in .zshrc
brew "tldr"          # concise man pages

# ---- Build tooling ----
brew "pipx"          # isolated python CLI tool installs

# ---- Flatpaks ----
# GUI apps tracked here for full machine reproducibility.
# Install with: brew bundle install (flatpak support requires homebrew-bundle >= 1.4)
# Or manually: flatpak install <id>
flatpak "com.github.wwmm.easyeffects"
flatpak "com.heroicgameslauncher.hgl"
flatpak "com.slack.Slack"
flatpak "md.obsidian.Obsidian"
flatpak "org.gimp.GIMP"
flatpak "org.qbittorrent.qBittorrent"
flatpak "app.zen_browser.zen"
