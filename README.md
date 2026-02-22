# ObsiGhost

<img width="2250" height="1026" alt="CleanShot 2026-02-22 at 21 26 28@2x" src="https://github.com/user-attachments/assets/e23277cd-2b2f-4e7a-94f4-7b925e4b34bb" />

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

## ObsiGhost CLI

Default is full-info mode.

```bash
obsighost mode full
obsighost mode public
obsighost mode
obsighost theme list
obsighost theme graphite
obsighost opacity 0.92
obsighost opacity glass
obsighost status
```

- `full`: shows `user@host`, kernel, model, and load.
- `public`: hides identifying machine details for screenshots.
- `obsighost theme list`: shows available color presets (`obsidian`, `graphite`, `lunar`).
- `obsighost theme <name>`: applies a preset to Ghostty text/palette colors.
- `obsighost opacity <value>`: sets `background-opacity` (`0.30` to `1.00`).
- `obsighost opacity glass|solid`: quick presets (`0.92` / `1.00`).
- `obsighost mode` prints current mode.
- `obsighost status` prints mode, theme, opacity, and active config files.

Mode is persisted in `~/.config/obsighost/mode.zsh`, theme in `~/.config/obsighost/theme`.

## Repo Structure

- `configs/ghostty/config` - Ghostty config
- `configs/ohmyposh/obsighost.omp.json` - prompt theme
- `bin/obsighost` - CLI for mode/theme/opacity/status
- `shell/obsighost.zsh` - shell integration + startup panel
- `scripts/install.sh` - installer

## Notes

- Installer creates timestamped backups of replaced files.
- If you already have a complex `.zshrc`, keep your own plugin setup and only source `~/.config/obsighost/obsighost.zsh`.
- Legacy alias `obsighost-mode` is still available and forwards to `obsighost mode`.

## License

MIT
