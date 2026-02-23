# Boo

<img width="2250" height="1026" alt="CleanShot 2026-02-22 at 21 26 28@2x" src="https://github.com/user-attachments/assets/e23277cd-2b2f-4e7a-94f4-7b925e4b34bb" />

Boo is a polished Ghostty + Zsh setup for a fast, themeable terminal workflow.

## What You Get

- Ghostty visual config with theme-tinted dark backgrounds
- Full ANSI `palette 0..255` written on theme apply
- Theme presets: `obsidian`, `graphite`, `lunar`, `crimson`, `matrix`, `abyss`
- Dual prompts: native zsh (default) and optional `oh-my-posh`
- Startup dashboard + splash art controls
- Zsh autocomplete for `boo`, `boo-mode`, and `boo-prompt`
- Single CLI (`boo`) for theme/font/opacity/prompt/mode/reload/doctor

## Requirements

- macOS (tested)
- [Ghostty](https://ghostty.org/)
- `zsh`
- Nerd Font installed in your system (recommended)
- [oh-my-posh](https://ohmyposh.dev/) (optional)

## Install

### One-line install

```bash
curl -fsSL https://boo.ansub.co/install.sh | bash
source ~/.zshrc
```

Then open a new Ghostty window.

### Install from source

```bash
git clone https://github.com/Ansub/boo.git
cd boo
./scripts/install.sh
source ~/.zshrc
```

## First 5 Minutes

```bash
boo doctor
boo status
boo theme matrix
boo font jetbrains
boo opacity glass
boo reload --unsafe
```

## Common Commands

### Themes

```bash
boo theme list
boo theme abyss
boo matrix      # shorthand
boo crimson     # shorthand
boo preview all
boo preview abyss --plain
```

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

## Autocomplete (zsh)

Boo installs a completion script at `~/.config/boo/completions/_boo`.

Quick checks:

```bash
which _boo
```

Then test with tab completion:

```bash
boo <TAB>
boo theme <TAB>
boo font set <TAB>
```

If completions do not show:

```bash
source ~/.zshrc
exec zsh
```

## Theme Intent

- `obsidian`: original Boo look with purple accents
- `graphite`: neutral gray with subtle violet accents
- `lunar`: cool blue-gray (no purple accents)
- `crimson`: high-contrast red mode
- `matrix`: aggressive hacker-green mode
- `abyss`: deep indigo with violet-magenta accents

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
- `~/.config/boo/prompt`
- `~/.config/boo/splash.zsh`
- `~/.config/boo/custom-splash.txt` (when using custom splash)
- `~/.config/boo/completions/_boo`

Ghostty config targets used by Boo:

- `~/.config/ghostty/config`
- `~/Library/Application Support/com.mitchellh.ghostty/config`

## Repo Layout

- `bin/boo` - Boo CLI
- `shell/boo.zsh` - shell integration + startup panel
- `shell/completions/_boo` - zsh completion for Boo commands
- `configs/ghostty/config` - base Ghostty config
- `configs/ohmyposh/boo.omp.json` - active prompt template
- `configs/ohmyposh/presets/*.omp.json` - prompt presets
- `art/*.txt` - built-in splash art
- `scripts/install.sh` - local installer
- `install.sh` - bootstrap installer entrypoint

## Notes

- Installer creates timestamped backups when replacing files.
- If your `.zshrc` is complex, keep your existing setup and only source `~/.config/boo/boo.zsh`.
- Helper commands: `boo-mode` -> `boo mode`, `boo-prompt` -> `boo prompt`.
- To skip auto-apply in scripts, set `BOO_NO_AUTO_APPLY=1`.

## License

MIT
