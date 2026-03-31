# dotfiles

Personal Linux dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Clone the repo, run one script, get a working environment.

## Quick start

```bash
git clone https://github.com/ferro-dev/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

`install.sh` is idempotent — safe to re-run on an already configured machine.

### Prerequisites

- Ubuntu / Pop!_OS (uses `apt` for base deps)
- Internet access (Homebrew, oh-my-zsh, and plugins are fetched at install time)
- For beets: set `MUSIC_DIR` to your music library path before importing. Add it to `~/.zshrc.local` so it persists across sessions:
  ```bash
  export MUSIC_DIR=/path/to/your/music
  ```

## What gets installed

| Step | What |
|------|------|
| apt | stow, tmux, zsh, flatpak |
| Linuxbrew | package manager for everything below |
| Brewfile | bat, fd, fzf, gh, git-delta, navi, neovim, thefuck, tldr, pipx, tree-sitter |
| tree-sitter CLI | prebuilt binary to `~/.local/bin` — brew ships only the C library, but nvim-treesitter requires the CLI (>= 0.26.1) to build parsers |
| Flatpak (Flathub) | EasyEffects, Heroic, Slack, Obsidian, GIMP, qBittorrent, Zen Browser |
| oh-my-zsh | shell framework with powerlevel10k theme |
| zsh plugins | zsh-autosuggestions, zsh-syntax-highlighting |
| fzf-git.sh | fzf-powered git keybindings (`~/fzf-git.sh/`) |
| TPM | tmux plugin manager (`~/.tmux/plugins/tpm`) |
| nvm | Node version manager |
| stow | symlinks all packages into `$HOME` |
| chsh | sets zsh as the default login shell |

## Packages

Each top-level directory is a stow package that mirrors `$HOME`. Always stow with `--no-folding` so individual files are symlinked rather than entire directories — this prevents stow from taking ownership of directories like `~/.config` that belong to other apps.

```bash
stow --no-folding zsh        # link a single package
stow --no-folding .          # link all packages
stow -D zsh                  # remove links for a package
```

| Package | Stow target | Contents |
|---------|-------------|----------|
| `zsh` | `~/.zshrc`, `~/.p10k.zsh` | oh-my-zsh config, powerlevel10k theme, fzf+fd integration, bat, thefuck, nvm, navi, Angular CLI |
| `tmux` | `~/.tmux.conf`, `~/.config/tmux/` | prefix `C-b`, Catppuccin Macchiato theme, TPM plugins, tmux-which-key config |
| `nvim` | `~/.config/nvim/` | Lazy.nvim, LSP (mason + mason-lspconfig), Telescope, Treesitter, which-key, lualine, neo-tree, Catppuccin theme, render-markdown, Roslyn (C#) |
| `git` | `~/.gitconfig` | delta pager, aliases |
| `beets` | `~/.config/beets/config.yaml` | music library manager config; requires `MUSIC_DIR` env var |
| `bin` | `~/.local/bin/tmux-sessionizer` | fzf-powered tmux session switcher |

### Key dependencies

`.zshrc` expects these to be present at startup — all are installed by `install.sh`:

- `brew` at `/home/linuxbrew/.linuxbrew`
- `fzf`, `fd`, `bat`, `thefuck`, `navi` (via Brewfile)
- `nvm` at `~/.nvm`
- `ng` (Angular CLI — install separately via nvm: `npm i -g @angular/cli`)
- `~/fzf-git.sh/fzf-git.sh` (cloned by install.sh)

Machine-local overrides (not committed to the repo) go in `~/.zshrc.local` — sourced automatically at the end of `.zshrc`.

### Neovim

Plugins are managed by [Lazy.nvim](https://github.com/folke/lazy.nvim). The lockfile (`lazy-lock.json`) is committed and pins all plugin versions. To update:

```
:Lazy sync      # install/update to lockfile versions
:Lazy update    # update plugins and write new lockfile
:TSUpdate       # update treesitter parsers
```

Treesitter uses the `main` branch of nvim-treesitter (requires Neovim 0.12.0+). The `master` branch is archived and incompatible with 0.12.0's updated `TSNode` API.

### tmux

Plugins managed by [TPM](https://github.com/tmux-plugins/tpm) at `~/.tmux/plugins/tpm`. After stowing for the first time:

```
tmux new -s main
# press: C-b I   (prefix + I to install plugins)
```

## Post-install steps

These are noted at the end of `install.sh` output:

1. **Log out and back in** (or open a new terminal) — `install.sh` sets zsh as your default login shell via `chsh`, which takes effect on next login.

2. **Install tmux plugins** — open tmux, press `C-b I`.

3. **Sync Neovim plugins** — open nvim and run `:Lazy sync`.

4. **Import COSMIC theme** (if on the COSMIC desktop):
   - Desktop: `COSMIC Settings > Desktop > Appearance > Import` → `~/dotfiles/cosmic/catppuccin-macchiato-mauve+round.ron`
   - Terminal: `COSMIC Terminal > View > Color schemes > Import` → `~/dotfiles/cosmic/catppuccin-macchiato.ron`

## Testing install.sh on a clean system

A `Dockerfile.test` is included for validating the bootstrap script without touching your live machine:

```bash
docker build -f Dockerfile.test -t dotfiles-test .
docker run --privileged -v $(pwd):/home/evan/dotfiles dotfiles-test
```

`--privileged` is required for flatpak's user namespaces. The bind mount means changes to your local branch are tested immediately without rebuilding the image.

> Flatpak app installs will warn (not fail) inside Docker because D-Bus is unavailable. Everything else installs cleanly.
