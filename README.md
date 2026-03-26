# dotfiles

Personal Linux dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Clone the repo, run one script, get a working environment.

## Quick start

```bash
git clone https://github.com/ferro-dev/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

`install.sh` is idempotent — safe to re-run on an already configured machine.

### Prerequisites

- Ubuntu/Pop!_OS (uses `apt` for base deps)
- Internet access (Homebrew, oh-my-zsh, and plugins are fetched at install time)
- For beets: set `MUSIC_DIR` to your music library path before importing:
  ```bash
  export MUSIC_DIR=/path/to/your/music
  ```
  Add this to `~/.zshrc.local` or your environment so it persists.

## What gets installed

| Step | What |
|------|------|
| apt | stow, tmux, zsh, flatpak |
| Linuxbrew | package manager for the rest |
| Brewfile | bat, fd, fzf, gh, git-delta, navi, neovim, thefuck, tldr, pipx |
| Flatpak (Flathub) | EasyEffects, Heroic, Slack, Obsidian, GIMP, qBittorrent, Zen Browser |
| oh-my-zsh | shell framework with powerlevel10k theme |
| zsh plugins | zsh-autosuggestions, zsh-syntax-highlighting |
| fzf-git.sh | fzf-powered git keybindings |
| TPM | tmux plugin manager |
| nvm | Node version manager |

## Packages (stow)

Each top-level directory is a stow package that mirrors `$HOME`:

| Package | Contents |
|---------|----------|
| `zsh` | `.zshrc`, `.p10k.zsh` |
| `tmux` | `.tmux.conf`, tmux-which-key config |
| `nvim` | full Neovim config (`~/.config/nvim/`) |
| `git` | `.gitconfig` |
| `beets` | `~/.config/beets/config.yaml` |
| `bin` | `~/.local/bin/tmux-sessionizer` |

To stow a single package manually:

```bash
stow --no-folding zsh
```

## Post-install steps

1. **Start a new shell** to load the zsh config:
   ```bash
   zsh
   ```

2. **Configure the prompt** (first time only):
   ```bash
   p10k configure
   ```

3. **Install tmux plugins** — open tmux, then press `prefix + I` (that's `C-a I`):
   ```bash
   tmux new -s main
   ```

4. **Sync Neovim plugins**:
   ```bash
   nvim  # then run :Lazy sync
   ```

5. **Add Flathub remote** (if the installer couldn't — requires a running desktop session):
   ```bash
   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   ```

## Testing install.sh on a clean system

A `Dockerfile.test` is included for validating the bootstrap script without touching your live machine:

```bash
docker build -f Dockerfile.test -t dotfiles-test .
docker run --privileged -v $(pwd):/home/evan/dotfiles dotfiles-test
```

`--privileged` is required for flatpak's user namespaces. The bind mount means changes to your local branch are tested immediately without rebuilding the image.

> **Note:** Flatpak app installs will warn (not fail) inside Docker because D-Bus is unavailable. Everything else installs cleanly.
