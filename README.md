# Boo -  Adding taste to your terminal
<img width="3840" height="1000" alt="Boo - Banner (1)" src="https://github.com/user-attachments/assets/4e8ae86b-c671-4aa5-9f34-9cabb59d1fe1" />

Boo helps you make your terminal look and feel better in minutes — without manually editing config files.

## What You Get

- Beautiful ready-to-use themes (plus easy custom theme creation)
- Better defaults for Ghostty + Zsh setup
- A clean startup panel and optional splash art
- Simple commands to change opacity, theme, prompt, and mode
- Create your own theme in seconds with `boo theme create`
- Quick troubleshooting with `boo doctor`
- Safe install/upgrade/uninstall flow with backups

## Great for beginners

If you're new to terminal setup, Boo gives you a polished setup fast with one command and easy controls:

```bash
boo theme fallout
boo opacity glass
```

## Install

```bash
curl -fsSL https://boo.ansub.co/install.sh | bash
source ~/.zshrc
```

Open a new Ghostty window, then run:

```bash
boo doctor
boo theme fallout
```

## If changes don't apply immediately

- Press `Cmd+Shift+,` in Ghostty, or
- Run `boo reload --unsafe`

## Requirements

- macOS (tested)
- [Ghostty](https://ghostty.org/)
- `zsh`
- [oh-my-posh](https://ohmyposh.dev/) (optional)

## First 5 Minutes

```bash
boo doctor
boo status
boo theme fallout
boo opacity glass
boo reload --unsafe
```

## Common Commands

### Themes (change your terminal colors)
Switch themes, preview them, and manage your custom themes.

```bash
boo theme list
boo theme abyss
boo crimson     # shorthand
boo preview all
boo preview abyss --plain
```

### Create themes (make your own look)
Generate a new theme from an accent color, or create one manually.

```bash
# Direct mode (one command)
boo theme create --name synthwave --accent '#ff3ea5'

# Iterative mode (guided prompts)
boo theme create

boo theme delete synthwave
```

You can also create a theme file directly in `~/.config/boo/themes/<name>.theme`:

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

### Prompt (how your shell prompt looks)
Choose between Boo's built-in prompt and oh-my-posh.

```bash
boo prompt
boo prompt set native
boo prompt set omp
```

### Mode (what info is shown on startup)
Control how much detail Boo shows when terminal opens.

```bash
boo mode full
boo mode public
```

### Splash art (startup visual)
Pick the startup art, use your own, or disable it.

```bash
boo splash list
boo splash saturn
boo splash custom ~/my-art.txt
boo splash none
boo splash reset
```

### Reload + doctor (apply and troubleshoot)
Reload terminal config and run health checks when something feels off.

```bash
boo reload
boo reload --unsafe
boo doctor
boo doctor fix
```

### Uninstall (remove Boo cleanly)

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

## Roadmap

- Font controls (`boo font`) are planned and will return in an upcoming release.
- More quality-of-life improvements for first-time setup.
## Reload Behavior

- `boo reload`: safe guidance only (no key injection, no window/session changes)
- `boo reload --unsafe`: tries to trigger Ghostty `reload_config` via detected comma-based keybind (`Cmd+Shift+,` or `Cmd+,`)
- Theme changes auto-run safe reload
- Opacity changes auto-run unsafe reload
- On macOS, `background-opacity` can still require a full Ghostty restart

## Notes

- Installer creates timestamped backups when replacing files.
- `boo uninstall` restores your original Ghostty config when available, otherwise removes Boo-managed config.

## License

MIT
