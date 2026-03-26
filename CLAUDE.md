# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Linux dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). `install.sh` is the entry point for bootstrapping a new machine. Files are symlinked from this repo into `$HOME` via stow.

## Bootstrap

```bash
git clone https://github.com/ferro-dev/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

`install.sh` is idempotent. It installs apt deps (stow, tmux, zsh, flatpak), Linuxbrew, brew bundle, oh-my-zsh + plugins, TPM, nvm, and stows all packages.

## Stow packages

Each top-level directory is a stow package mirroring `$HOME`. Always use `--no-folding`:

```bash
stow --no-folding zsh      # link only zsh
stow --no-folding .        # link everything
stow -D zsh                # remove links
```

Packages: `zsh`, `tmux`, `nvim`, `git`, `beets`, `bin`

## Package structure

- `zsh/` → `.zshrc` (oh-my-zsh, powerlevel10k, fzf+fd, bat, thefuck, nvm, navi, Angular CLI), `.p10k.zsh`
- `tmux/` → `.tmux.conf` (prefix `C-a`, catppuccin theme, TPM plugins), `.config/tmux/plugins/tmux-which-key/config.yaml`
- `nvim/` → `.config/nvim/` (Lazy.nvim, LSP, Telescope, which-key, etc.)
- `git/` → `.gitconfig`
- `beets/` → `.config/beets/config.yaml` (requires `MUSIC_DIR` env var)
- `bin/` → `.local/bin/tmux-sessionizer`

## Key dependencies

`.zshrc` expects: `brew` (Linuxbrew at `/home/linuxbrew/.linuxbrew`), `fzf`, `fd`, `bat`, `thefuck`, `nvm`, `navi`, `ng` (Angular CLI), `~/fzf-git.sh/fzf-git.sh`

Tmux plugins managed via TPM at `~/.tmux/plugins/tpm`. Install with `prefix + I` inside tmux.

Neovim plugins managed via Lazy.nvim. Sync with `:Lazy sync` inside nvim.

## Style

- Do not add AI attribution comments or generation notices to any files (no "Generated with Claude Code", "Co-authored by", etc.)

## Testing install.sh

Use `Dockerfile.test` to validate on a clean Ubuntu 22.04 system:

```bash
docker build -f Dockerfile.test -t dotfiles-test .
docker run --privileged -v $(pwd):/home/evan/dotfiles dotfiles-test
```

Expected: all stow packages link cleanly, exit 0. Flatpak apps will warn (not fail) — D-Bus is unavailable in Docker.
