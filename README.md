# Boo

<img width="2250" height="1026" alt="CleanShot 2026-02-22 at 21 26 28@2x" src="https://github.com/user-attachments/assets/e23277cd-2b2f-4e7a-94f4-7b925e4b34bb" />

Boo is a polished Ghostty + Zsh + Oh My Posh setup inspired by Obsidian-like colors.

It includes:
- Ghostty visual config (glass look, black background, tuned text/cursor)
- Boo Oh My Posh themes (`obsidian`, `graphite`, `lunar`)
- Neofetch-style startup dashboard for Ghostty
- Theme-aware command/builtin syntax highlight accents for zsh

## Prerequisites

- macOS (tested)
- Ghostty
- `zsh`
- [oh-my-posh](https://ohmyposh.dev/)
- Nerd Font in terminal (recommended)

## Quick Install

```bash
git clone https://github.com/Ansub/boo.git
cd boo
./scripts/install.sh
source ~/.zshrc
```

Then open a new Ghostty window.

## Boo CLI

Default is full-info mode.

```bash
boo crimson        # shorthand
boo matrix         # shorthand
boo mode full
boo mode public
boo mode
boo theme list
boo theme graphite
boo theme crimson
boo theme matrix
boo opacity 0.92
boo opacity glass
boo preview obsidian
boo preview all
boo reload
boo reload --unsafe
boo status
```

- `full`: shows `user@host`, kernel, model, and load.
- `public`: hides identifying machine details for screenshots.
- `boo theme list`: shows available color presets (`obsidian`, `graphite`, `lunar`, `crimson`, `matrix`).
- `boo theme <name>`: applies terminal colors + prompt palette + shell accent colors.
- `boo opacity <value>`: sets `background-opacity` (`0.30` to `1.00`).
- `boo opacity glass|solid`: quick presets (`0.92` / `1.00`).
- `boo preview <theme>`: previews core theme colors with ANSI true-color swatches.
- `boo preview all`: prints swatches for all themes for quick comparison.
- `boo reload`: safe apply guidance (does not open windows or touch running sessions).
- `boo reload --unsafe`: attempts Ghostty `reload_config` via `Cmd+Shift+,`.
- `boo mode` prints current mode.
- `boo status` prints mode, theme, opacity, and active config files.

Mode is persisted in `~/.config/boo/mode.zsh`, theme in `~/.config/boo/theme`.
Theme/opacity commands auto-run `boo reload` after writing config.
Theme accent state is stored in `~/.config/boo/theme.zsh`.
When sourced via `shell/boo.zsh`, mode changes sync into the current shell session immediately.

Theme intent:
- `obsidian`: original Boo look with purple accents.
- `graphite`: neutral-gray look with lighter violet accents.
- `lunar`: cool blue-gray look with no purple accents.
- `crimson`: high-contrast red assault mode.
- `matrix`: aggressive hacker-green mode.

## Reload Status

Current behavior:
- `boo reload` is non-destructive and does not force window/session changes.
- `boo reload --unsafe` can work for immediate reload, but depends on macOS permissions/focus.
- On macOS, `background-opacity` still typically needs a full Ghostty restart.

If reload is not working:
1. Focus Ghostty and run `boo reload --unsafe`.
2. If it still does not apply, fully quit Ghostty and reopen it.
3. For opacity specifically, prefer a full app restart on macOS.

## Repo Structure

- `configs/ghostty/config` - Ghostty config
- `configs/ohmyposh/boo.omp.json` - prompt theme
- `configs/ohmyposh/presets/*.omp.json` - prompt presets by theme
- `bin/boo` - CLI for mode/theme/opacity/status
- `shell/boo.zsh` - shell integration + startup panel
- `scripts/install.sh` - installer

## Notes

- Installer creates timestamped backups of replaced files.
- If you already have a complex `.zshrc`, keep your own plugin setup and only source `~/.config/boo/boo.zsh`.
- Helper command `boo-mode` forwards to `boo mode`.
- To skip auto-reload during scripting, run commands with `BOO_NO_AUTO_APPLY=1`.
- On macOS, Ghostty only applies `background-opacity` after a full app restart.
- `reload --unsafe` may reset active terminals/sessions depending on Ghostty state.
- On macOS, the CLI updates the existing non-empty Ghostty config path to avoid split-config conflicts.

## License

MIT
