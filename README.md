# Boo

<img width="2250" height="1026" alt="CleanShot 2026-02-22 at 21 26 28@2x" src="https://github.com/user-attachments/assets/e23277cd-2b2f-4e7a-94f4-7b925e4b34bb" />

Boo is a polished Ghostty + Zsh setup inspired by Obsidian-like colors.

It includes:
- Ghostty visual config (glass look, black background, tuned text/cursor)
- Dual prompt backends: native zsh (default) and optional `oh-my-posh`
- Boo prompt presets (`obsidian`, `graphite`, `lunar`, `crimson`, `matrix`)
- Neofetch-style startup dashboard for Ghostty
- Theme-aware command/builtin syntax highlight accents for zsh

## Prerequisites

- macOS (tested)
- Ghostty
- `zsh`
- [oh-my-posh](https://ohmyposh.dev/) (optional)
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
boo prompt
boo prompt set native
boo prompt set omp
boo theme list
boo theme graphite
boo theme crimson
boo theme matrix
boo opacity 0.92
boo opacity glass
boo preview obsidian
boo preview all
boo preview all --plain
boo splash list
boo splash boo
boo splash saturn
boo splash custom ~/my-art.txt
boo splash none
boo splash reset
boo doctor
boo doctor fix
boo reload
boo reload --unsafe
boo status
```

- `full`: shows `user@host`, kernel, model, and load.
- `public`: hides identifying machine details for screenshots.
- `boo prompt`: shows configured and active prompt backend.
- `boo prompt set <native|omp>`: switches prompt engine (`native` is default).
- `boo theme list`: shows available color presets (`obsidian`, `graphite`, `lunar`, `crimson`, `matrix`).
- `boo theme <name>`: applies terminal colors + prompt palette + shell accent colors.
- `boo opacity <value>`: sets `background-opacity` (`0.30` to `1.00`).
- `boo opacity glass|solid`: quick presets (`0.92` / `1.00`).
- `boo preview <theme>`: previews core theme colors with ANSI true-color swatches.
- `boo preview all`: prints swatches for all themes for quick comparison.
- `boo preview [<theme>|all] --plain`: prints plain hex values (no ANSI swatches).
- `boo splash list`: lists available startup art with tiny previews.
- `boo splash <name>`: picks built-in art (`apple`, `boo`, `saturn`, `minimal`).
- `boo splash custom <file>`: copies your file to `~/.config/boo/custom-splash.txt` and uses it.
- `boo splash none`: disables the startup panel completely.
- `boo splash reset`: restores default splash (`apple`).
- `boo doctor`: checks for common setup issues (PATH, zsh block, legacy refs, config conflicts).
- `boo doctor fix`: applies safe auto-fixes and re-runs checks.
- `boo reload`: safe apply guidance (does not open windows or touch running sessions).
- `boo reload --unsafe`: attempts Ghostty `reload_config` via `Cmd+Shift+,`.
- `boo mode` prints current mode.
- `boo status` prints mode, theme, prompt backend, opacity, and active config files.

Mode is persisted in `~/.config/boo/mode.zsh`, theme in `~/.config/boo/theme`, prompt backend in `~/.config/boo/prompt`, and splash in `~/.config/boo/splash.zsh`.
Theme commands auto-run safe `boo reload`.
Opacity commands auto-run `boo reload --unsafe` for immediate apply attempts.
Theme accent state is stored in `~/.config/boo/theme.zsh`.
Built-in splash art files are installed to `~/.config/boo/art/`; custom splash files are copied to `~/.config/boo/custom-splash.txt`.
When sourced via `shell/boo.zsh`, mode/theme/prompt changes sync into the current shell session immediately.

Prompt backend behavior:
- `native`: zero dependency zsh prompt.
- `omp`: uses `oh-my-posh` when installed.
- If `omp` is configured but `oh-my-posh` is missing, Boo falls back to `native`.
- If run through Boo shell integration, `boo prompt set ...` applies instantly.
- If run as plain binary, use `exec zsh` to refresh the current shell.

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
- `bin/boo` - CLI for mode/theme/splash/opacity/status
- `shell/boo.zsh` - shell integration + startup panel
- `art/*.txt` - built-in startup ASCII art
- `scripts/install.sh` - installer

## Notes

- Installer creates timestamped backups of replaced files.
- If you already have a complex `.zshrc`, keep your own plugin setup and only source `~/.config/boo/boo.zsh`.
- Helper command `boo-mode` forwards to `boo mode`.
- Helper command `boo-prompt` forwards to `boo prompt`.
- To skip auto-reload during scripting, run commands with `BOO_NO_AUTO_APPLY=1`.
- On macOS, Ghostty only applies `background-opacity` after a full app restart.
- `reload --unsafe` may reset active terminals/sessions depending on Ghostty state.
- On macOS, the CLI updates the existing non-empty Ghostty config path to avoid split-config conflicts.

## License

MIT
