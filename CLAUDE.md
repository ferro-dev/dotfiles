# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repo managed with [GNU Stow](https://www.gnu.org/software/stow/). Files are symlinked from this directory into `$HOME` by running `stow` from within the repo.

## Deploying configs

To symlink a package (e.g., a top-level directory or file group) into `$HOME`:

```sh
stow .          # symlink everything
stow vim        # symlink only the vim package
```

To remove symlinks:

```sh
stow -D vim
```

## What's here

- `.zshrc` — zsh config: oh-my-zsh + powerlevel10k theme, fzf (with fd), bat (Catppuccin Macchiato), thefuck, nvm, Angular CLI completion
- `.p10k.zsh` — powerlevel10k prompt configuration
- `.tmux.conf` — tmux config with catppuccin/macchiato theme via TPM
- `.oh-my-zsh/` — oh-my-zsh installation with powerlevel10k as a nested git submodule under `custom/themes/`
- `vim/` — vim package (currently empty)

## Key dependencies

The `.zshrc` expects these to be installed: `brew` (Linuxbrew at `/home/linuxbrew/.linuxbrew`), `fzf`, `fd`, `bat`, `thefuck`, `nvm`, `ng` (Angular CLI), and `~/fzf-git.sh/fzf-git.sh`.

Tmux plugins are managed via [TPM](https://github.com/tmux-plugins/tpm) at `~/.tmux/plugins/tpm`.
