# ObsiGhost

ObsiGhost is a polished Ghostty + Zsh + Oh My Posh setup inspired by Obsidian-like colors.

It includes:
- Ghostty visual config (glass look, black background, tuned text/cursor)
- ObsiGhost Oh My Posh theme (`obsighost.omp.json`)
- Neofetch-style startup dashboard for Ghostty
- Purple command/builtin syntax highlight accents for zsh

## Prerequisites

- macOS (tested)
- Ghostty
- `zsh`
- [oh-my-posh](https://ohmyposh.dev/)
- Nerd Font in terminal (recommended)

## Quick Install

```bash
git clone https://github.com/Ansub/obsighost.git
cd obsighost
./scripts/install.sh
source ~/.zshrc
```

Then open a new Ghostty window.

## Repo Structure

- `configs/ghostty/config` - Ghostty config
- `configs/ohmyposh/obsighost.omp.json` - prompt theme
- `shell/obsighost.zsh` - shell integration + startup panel
- `scripts/install.sh` - installer

## Notes

- Installer creates timestamped backups of replaced files.
- If you already have a complex `.zshrc`, keep your own plugin setup and only source `~/.config/obsighost/obsighost.zsh`.

## License

MIT
