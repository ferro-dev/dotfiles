# zsh

I use zsh as my terminal of choice within Linux. This directory contains any and all configuration files related to how I like my zsh terminal setup and configured. This readme will document the setup of zsh and how to apply the configuration found within this directory.

## Installation

When I use zsh I also install Starship. This file and this directory contains all of that.

* [docs](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)

First, install using your package manager of choice. I'm currently using Ubuntu via WSL, so I'll use `apt`:

```
sudo apt install zsh
```

Verify installion with `zsh --version`

Make it your default shell:

```
chsh -s $(which zsh)
```

### Starship

I use [Starship](https://starship.rs/) and I don't care what you think. First we install it.

```
curl -sS https://starship.rs/install.sh | sh
```

Then we update our `.zshrc` file by appending this line to the **end** of the file:

```
eval "$(starship init zsh)"
```

We also will want to install some Nerd Fonts, and to make our life easy we also use `fontconfig`:

```
sudo apt install fontconfig
```

I prefer Fira Code, use whatever licks yer nipples.

```
sudo apt install fonts-firacode
```

Then refresh your font cache.

```
fc-cache -fv
```

Feels good.

## Configuration

I keep a copy of my `.zshrc` in this directory, replace yours or steal whatever you want from it. We're done here.
