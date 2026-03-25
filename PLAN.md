# Dotfiles Improvement Plan

Goal: clone repo on any Linux machine, run one command, get a fully working environment.

Legend: `[ ]` todo · `[~]` in progress · `[x]` done

---

## 1. Restructure repo into stow packages

Move configs out of the repo root and into per-tool package directories so each tool
can be stowed independently.

- [ ] Create `zsh/` package — move `.zshrc` and `.p10k.zsh` into `zsh/`
- [ ] Create `tmux/` package — move `.tmux.conf` into `tmux/`
- [ ] Verify stow still works after restructure (`stow zsh`, `stow tmux`)
- [ ] Remove the empty `vim/` directory

---

## 2. Remove oh-my-zsh from the repo

The `.oh-my-zsh/` directory (including the powerlevel10k submodule) is a third-party
framework tracked inside the repo. It should be installed by the bootstrap script instead.

- [ ] Remove `.oh-my-zsh/` from git tracking (`git rm -r --cached .oh-my-zsh`)
- [ ] Add `.oh-my-zsh` to `.gitignore`
- [ ] Add oh-my-zsh install step to bootstrap script (see section 5)
- [ ] Add powerlevel10k clone step to bootstrap script
- [ ] Verify `.zshrc` still sources oh-my-zsh correctly after change

---

## 3. Add missing configs to the repo

Configs that exist on this machine but are not tracked.

### Git
- [ ] Create `git/` package — add `.gitconfig`
- [ ] Verify delta is listed as a brew dependency (see section 4)

### Neovim
- [ ] Create `nvim/` package mirroring `.config/nvim/` structure
  - `nvim/.config/nvim/init.lua`
  - `nvim/.config/nvim/lua/vim-options.lua`
  - `nvim/.config/nvim/lua/plugins/` (all plugin files)
  - `nvim/.config/nvim/lazy-lock.json`
- [ ] Stow the nvim package and verify it links correctly

### Beets
- [ ] Create `beets/` package — add `.config/beets/config.yaml`
- [ ] Replace hardcoded `/mnt/ssd/Music` path with `$MUSIC_DIR` environment variable
- [ ] Document `MUSIC_DIR` in README as a machine-specific variable to set before running bootstrap

---

## 4. Add a Brewfile

Declarative record of all brew-managed dependencies. Lets `brew bundle` install everything
in one shot on a new machine.

- [ ] Run `brew bundle dump --file=Brewfile` on this machine to generate baseline
- [ ] Review and prune any entries that aren't part of the terminal environment
- [ ] Confirm these are present: `stow`, `tmux`, `neovim`, `fzf`, `fd`, `bat`, `thefuck`, `git-delta`, `nvm`
- [ ] Add `brew bundle install` as a step in the bootstrap script

---

## 5. Write install.sh

Single entry point. Run this after cloning the repo on a new machine.

Steps the script must handle, in order:

- [ ] Install Linuxbrew if not already present
- [ ] Run `brew bundle install` from the Brewfile
- [ ] Install oh-my-zsh (unattended, skip chsh)
- [ ] Clone powerlevel10k into `$ZSH/custom/themes/powerlevel10k`
- [ ] Install zsh-autosuggestions and zsh-syntax-highlighting plugins
- [ ] Clone fzf-git.sh into `~/fzf-git.sh`
- [ ] Clone TPM into `~/.tmux/plugins/tpm`
- [ ] Install nvm if not already present
- [ ] Stow all packages (`zsh`, `tmux`, `git`, `nvim`, `beets`)
- [ ] Print post-install notes (set `MUSIC_DIR`, run `p10k configure` if first time, install tmux plugins with `prefix + I`)

Script requirements:
- [ ] Idempotent — safe to re-run on an already configured machine
- [ ] Checks before installing (e.g. `command -v brew` before installing brew)
- [ ] Clear output so it's obvious what step is running or failed

---

## 6. Expand tmux config

The current `.tmux.conf` is just plugin declarations. Add keybindings and productivity
features to make it useful as a primary workflow tool.

- [ ] Change prefix from `C-b` to `C-a`
- [ ] Add vim-style pane navigation (`prefix + h/j/k/l`)
- [ ] Add pane splitting with intuitive keys (`|` for vertical, `-` for horizontal)
- [ ] Enable mouse support
- [ ] Set window/pane numbering to start at 1
- [ ] Add `tmux-resurrect` plugin — persist sessions across reboots
- [ ] Add `tmux-continuum` plugin — auto-save sessions
- [ ] Configure catppuccin status bar (clock, session name, window list)
- [ ] Write a `tmux-sessionizer` script — fzf over project dirs, open as named sessions
- [ ] Bind sessionizer to a key (e.g. `prefix + f`)

---

## 7. Update CLAUDE.md and README

- [ ] Update `CLAUDE.md` to reflect new package structure and `install.sh`
- [ ] Expand `README.md` with: quick start (clone + run install.sh), prerequisite (`MUSIC_DIR`), what's included

---

## 8. Keybinding hints and cheatsheets

Goal: surface keybinding information at the moment it's needed, without breaking flow
or requiring a separate lookup. Four components working together.

### which-key.nvim

In-neovim popup that appears after a short delay when you start a key sequence
(leader, g, z, etc.), listing every valid continuation and what it does.

- [ ] Add `which-key.nvim` to nvim plugins (Lazy.nvim spec in `nvim/.config/nvim/lua/plugins/`)
- [ ] Configure group labels for leader key sections (e.g. `<leader>f` → "find", `<leader>g` → "git")
- [ ] Set popup delay to taste (default 200ms is reasonable to start)

### tmux-which-key

Same concept for tmux — popup appears after pressing the prefix showing all bindings
grouped by category. Configured in YAML, installed via TPM.

- [ ] Add `tmux-which-key` to TPM plugin list in `.tmux.conf`
- [ ] Create `tmux/.config/tmux/tmux-which-key.yaml` with grouped keybindings
  matching whatever bindings are set in section 6
- [ ] Bind the menu to trigger on prefix + `?`

### navi

Fuzzy-searchable interactive cheatsheet tool. Press `Ctrl+G` anywhere in the shell
to open an fzf panel over all cheatsheets. Can execute selected commands directly
with interactive argument filling. Pulls from community sheets and your own.

- [ ] Add `navi` to Brewfile
- [ ] Add `navi` zsh widget init to `.zshrc` (`eval "$(navi widget zsh)"`)
- [ ] Create `cheatsheets/` directory in dotfiles repo
- [ ] Write `cheatsheets/tmux.cheat` covering your custom bindings from section 6
- [ ] Write `cheatsheets/nvim.cheat` covering your most-used nvim motions and leader bindings
- [ ] Write `cheatsheets/shell.cheat` for fzf, git, and general shell one-liners
- [ ] Configure navi to include the dotfiles `cheatsheets/` dir as a source
- [ ] Add `navi` to Brewfile dependency list

### tmux popup cheatsheet (fallback)

A fast popup bound to a key that displays your cheatsheet files directly in tmux
using `display-popup`. Useful when you're inside nvim and which-key isn't the right
tool, or you just want a quick glance.

- [ ] Add a binding to `.tmux.conf` — `bind ? display-popup -E "cat ~/dotfiles/cheatsheets/tmux.cheat | less -R"`
- [ ] Add a binding for the nvim sheet — `bind M-? display-popup -E "cat ~/dotfiles/cheatsheets/nvim.cheat | less -R"`

---

## 9. Update CLAUDE.md and README

- [ ] Update `CLAUDE.md` to reflect new package structure and `install.sh`
- [ ] Expand `README.md` with: quick start (clone + run install.sh), prerequisite (`MUSIC_DIR`), what's included
