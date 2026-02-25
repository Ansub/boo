# Boo

<img width="2250" height="1026" alt="CleanShot 2026-02-22 at 21 26 28@2x" src="https://github.com/user-attachments/assets/e23277cd-2b2f-4e7a-94f4-7b925e4b34bb" />

**Boo — Adding taste to your terminal.**

Boo is a design-first Ghostty + Zsh CLI for a fast, themeable terminal workflow.

## What You Get

- A single-file CLI (`bin/boo`) with no build step
- Full Ghostty color control, including ANSI `palette 0..255`
- File-based theme engine (`~/.config/boo/themes/*.theme`) with built-in + custom themes
- Built-in themes: `abyss` (default), `clay`, `crimson`, `fallout`, `lunar`, `moss`, `rust`
- Prompt backends: native zsh (default) + optional `oh-my-posh`
- Splash art system (`boo splash`) and startup dashboard
- Operations built in: `doctor`, `reload`, `upgrade`, `uninstall`

## Requirements

- macOS (tested)
- [Ghostty](https://ghostty.org/)
- `zsh`
- Nerd Font installed in your system (recommended)
- [oh-my-posh](https://ohmyposh.dev/) (optional)

## Install

### One-line install

```bash
curl -fsSL https://boo.ansub.co/install.sh | bash && source ~/.zshrc
```

Then apply config now with either:
- press `Cmd+Shift+,` in Ghostty, or
- run `boo reload --unsafe`

If needed, open a new Ghostty window.

### Install from source

```bash
git clone https://github.com/Ansub/boo.git
cd boo
./scripts/install.sh && source ~/.zshrc
```

Then apply config now with either:
- press `Cmd+Shift+,` in Ghostty, or
- run `boo reload --unsafe`

If needed, open a new Ghostty window.

## First 5 Minutes

```bash
boo doctor
boo status
boo theme fallout
boo font jetbrains
boo opacity glass
boo reload --unsafe
```

## Common Commands

### Themes

```bash
boo theme list
boo theme abyss
boo crimson     # shorthand
boo theme create --name synthwave --accent '#ff3ea5'
boo theme delete synthwave
boo preview all
boo preview abyss --plain
```

Create a custom theme by adding a file in `~/.config/boo/themes/<name>.theme`:

```ini
description=my custom theme
accent=#ff6a00
bg=#0a0400
fg=#ffb870
cursor=#ff6a00
cursor_text=#000000
selection_bg=#2a1800
selection_fg=#ffd4a0
pal_0=#0a0400
...
pal_15=#ffe8cc
```

Then run `boo theme <name>`.

### Fonts

```bash
boo font
boo font list
boo font hack
boo font family "JetBrainsMono Nerd Font"
boo font size 15
```

### Prompt

```bash
boo prompt
boo prompt set native
boo prompt set omp
```

### Privacy mode

```bash
boo mode full
boo mode public
```

### Splash art

```bash
boo splash list
boo splash saturn
boo splash custom ~/my-art.txt
boo splash none
boo splash reset
```

### Reload + diagnostics

```bash
boo reload
boo reload --unsafe
boo doctor
boo doctor fix
```

### Uninstall

```bash
boo uninstall
# or non-interactive
boo uninstall --yes
```

## Theme Intent

- `abyss`: deep indigo with violet-magenta accents (default)
- `clay`: warm cream light mode with earthy terracotta accents
- `crimson`: high-contrast red mode
- `fallout`: RobCo phosphor CRT — warm amber-lime on near-black
- `lunar`: desaturated monochrome noir
- `moss`: damp forest floor — muted earthy green
- `rust`: oxidized metal — brutalist copper

## Font Notes (Important)

If a font family is set but not installed, Ghostty falls back to another font.

Check what is configured:

```bash
boo font
ghostty +show-config | rg '^font-family =|^font-size ='
```

Check what Ghostty is actually rendering:

```bash
ghostty +show-face --cp=0x41
```

Install missing Nerd Fonts with Homebrew casks, for example:

```bash
brew install --cask font-hack-nerd-font
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-fira-code-nerd-font
```

## Reload Behavior

- `boo reload`: safe guidance only (no key injection, no window/session changes)
- `boo reload --unsafe`: tries to trigger Ghostty `reload_config` via detected comma-based keybind (`Cmd+Shift+,` or `Cmd+,`)
- Theme changes auto-run safe reload
- Font and opacity changes auto-run unsafe reload
- On macOS, `background-opacity` can still require a full Ghostty restart

## State and Paths

Boo persists state in:

- `~/.config/boo/mode.zsh`
- `~/.config/boo/theme`
- `~/.config/boo/theme.zsh`
- `~/.config/boo/themes/*.theme`
- `~/.config/boo/prompt`
- `~/.config/boo/splash.zsh`
- `~/.config/boo/custom-splash.txt` (when using custom splash)

Ghostty config targets used by Boo:

- `~/.config/ghostty/config`
- `~/Library/Application Support/com.mitchellh.ghostty/config`

## Repo Layout

- `bin/boo` - Boo CLI
- `shell/boo.zsh` - shell integration + startup panel
- `configs/ghostty/config` - base Ghostty config
- `configs/ohmyposh/boo.omp.json` - active prompt template
- `configs/ohmyposh/presets/*.omp.json` - prompt presets
- `art/*.txt` - built-in splash art
- `themes/*.theme` - built-in theme definitions
- `scripts/install.sh` - local installer
- `install.sh` - bootstrap installer entrypoint

## Notes

- Installer creates timestamped backups when replacing files.
- `boo uninstall` restores your original Ghostty config when available, otherwise removes Boo-managed config.
- If your `.zshrc` is complex, keep your existing setup and only source `~/.config/boo/boo.zsh`.
- Helper commands: `boo-mode` -> `boo mode`, `boo-prompt` -> `boo prompt`.
- To skip auto-apply in scripts, set `BOO_NO_AUTO_APPLY=1`.

## License

MIT
