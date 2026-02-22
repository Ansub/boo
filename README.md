# ObsiGhost

<img width="2250" height="1026" alt="CleanShot 2026-02-22 at 21 26 28@2x" src="https://github.com/user-attachments/assets/e23277cd-2b2f-4e7a-94f4-7b925e4b34bb" />

ObsiGhost is a polished Ghostty + Zsh + Oh My Posh setup inspired by Obsidian-like colors.

It includes:
- Ghostty visual config (glass look, black background, tuned text/cursor)
- ObsiGhost Oh My Posh themes (`obsidian`, `graphite`, `lunar`)
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
obsighost reload
obsighost reload --unsafe
obsighost status
```

- `full`: shows `user@host`, kernel, model, and load.
- `public`: hides identifying machine details for screenshots.
- `obsighost theme list`: shows available color presets (`obsidian`, `graphite`, `lunar`).
- `obsighost theme <name>`: applies terminal colors + prompt palette + shell accent colors.
- `obsighost opacity <value>`: sets `background-opacity` (`0.30` to `1.00`).
- `obsighost opacity glass|solid`: quick presets (`0.92` / `1.00`).
- `obsighost reload`: safe apply guidance (does not open windows or touch running sessions).
- `obsighost reload --unsafe`: attempts Ghostty `reload_config` via `Cmd+Shift+,`.
- `obsighost mode` prints current mode.
- `obsighost status` prints mode, theme, opacity, and active config files.

Mode is persisted in `~/.config/obsighost/mode.zsh`, theme in `~/.config/obsighost/theme`.
Theme/opacity commands auto-run `obsighost reload` after writing config.
Theme accent state is stored in `~/.config/obsighost/theme.zsh`.
When sourced via `shell/obsighost.zsh`, mode changes sync into the current shell session immediately.

Theme intent:
- `obsidian`: original ObsiGhost look with purple accents.
- `graphite`: neutral-gray look with lighter violet accents.
- `lunar`: cool blue-gray look with no purple accents.

## Reload Status

Current behavior:
- `obsighost reload` is non-destructive and does not force window/session changes.
- `obsighost reload --unsafe` can work for immediate reload, but depends on macOS permissions/focus.
- On macOS, `background-opacity` still typically needs a full Ghostty restart.

If reload is not working:
1. Focus Ghostty and run `obsighost reload --unsafe`.
2. If it still does not apply, fully quit Ghostty and reopen it.
3. For opacity specifically, prefer a full app restart on macOS.

## Repo Structure

- `configs/ghostty/config` - Ghostty config
- `configs/ohmyposh/obsighost.omp.json` - prompt theme
- `configs/ohmyposh/presets/*.omp.json` - prompt presets by theme
- `bin/obsighost` - CLI for mode/theme/opacity/status
- `shell/obsighost.zsh` - shell integration + startup panel
- `scripts/install.sh` - installer

## Notes

- Installer creates timestamped backups of replaced files.
- If you already have a complex `.zshrc`, keep your own plugin setup and only source `~/.config/obsighost/obsighost.zsh`.
- Legacy alias `obsighost-mode` is still available and forwards to `obsighost mode`.
- To skip auto-reload during scripting, run commands with `OBSIGHOST_NO_AUTO_APPLY=1`.
- On macOS, Ghostty only applies `background-opacity` after a full app restart.
- `reload --unsafe` may reset active terminals/sessions depending on Ghostty state.
- On macOS, the CLI updates the existing non-empty Ghostty config path to avoid split-config conflicts.

## License

MIT
