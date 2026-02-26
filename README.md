<img width="3840" height="1000" alt="Boo - Banner (1)" src="https://github.com/user-attachments/assets/4e8ae86b-c671-4aa5-9f34-9cabb59d1fe1" />

# Boo

Boo helps you make Ghostty + Zsh look good in minutes without hand-editing config files.

## Start Here (2 to 5 minutes)

Copy and run these commands in order:

```bash
curl -fsSL https://boo.ansub.co/install.sh | bash
source ~/.zshrc
boo doctor
boo theme fallout
boo opacity glass
```

Expected result:

- `boo doctor` runs checks and tells you if anything needs fixing.
- `boo theme fallout` changes your color theme.
- `boo opacity glass` updates background transparency.

If theme or opacity does not change right away, jump to [If Something Looks Wrong](#if-something-looks-wrong).

## What You Get

- Ready-to-use themes and easy custom theme creation
- Better Ghostty + Zsh defaults
- Startup panel plus optional splash art
- Simple commands for theme, opacity, prompt, and mode
- Built-in troubleshooting with `boo doctor`
- Safe install/upgrade/uninstall flow with backups

## Prerequisites

- macOS (tested)
- [Ghostty](https://ghostty.org/)
- `zsh`
- [oh-my-posh](https://ohmyposh.dev/) (optional, only needed for `boo prompt set omp`)

## Install

```bash
curl -fsSL https://boo.ansub.co/install.sh | bash
source ~/.zshrc
```

Safety notes:

- Installer creates timestamped backups before replacing files.
- `boo uninstall` can restore your previous Ghostty config when a backup exists.

## Verify It Worked

```bash
boo doctor
boo status
```

Expected result:

- `boo doctor` shows mostly successful checks, or tells you exactly what to run next.
- `boo status` shows your current theme, mode, splash, prompt, and opacity.

## First Customization (3 commands)

```bash
boo theme fallout
boo opacity glass
boo prompt set native
```

Optional preview:

```bash
boo preview all
```

## If Something Looks Wrong

### `boo: command not found`

```bash
source ~/.zshrc
```

Then open a new Ghostty window and run:

```bash
boo doctor
```

### Theme or opacity did not apply

- Press `Cmd+Shift+,` in Ghostty.
- Or run `boo reload --unsafe`.
- If opacity still does not change on macOS, fully restart Ghostty.

### `boo doctor` reports issues

```bash
boo doctor fix
boo doctor
```

## Common Tasks

### Themes

```bash
boo theme list
boo theme abyss
boo crimson
boo preview all
boo preview abyss --plain
```

### Create your own theme

```bash
# One command
boo theme create --name synthwave --accent '#ff3ea5'

# Guided prompts
boo theme create

# Delete a custom theme
boo theme delete synthwave
```

You can also create `~/.config/boo/themes/<name>.theme` manually, then run:

```bash
boo theme <name>
```

### Prompt backend

```bash
boo prompt
boo prompt set native
boo prompt set omp
```

### Startup mode

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

### Health + reload

```bash
boo doctor
boo doctor fix
boo reload
boo reload --unsafe
```

## Uninstall / Restore

```bash
boo uninstall
# non-interactive
boo uninstall --yes
```

Expected result:

- Boo-managed setup is removed.
- Previous Ghostty config is restored when available.

## Theme Intent

- `abyss`: deep indigo with violet-magenta accents (default)
- `clay`: warm cream light mode with earthy terracotta accents
- `glacier`: icy daylight light mode with steel-blue accents
- `crimson`: high-contrast red mode
- `fallout`: RobCo phosphor CRT, warm amber-lime on near-black
- `lunar`: desaturated monochrome noir
- `moss`: damp forest floor, muted earthy green
- `rust`: oxidized metal, brutalist copper

## Advanced Notes

- `boo reload`: safe guidance only (no key injection, no window/session changes)
- `boo reload --unsafe`: tries to trigger Ghostty `reload_config` via comma-based keybind (`Cmd+Shift+,` or `Cmd+,`)
- Theme changes auto-run safe reload
- Opacity changes auto-run unsafe reload
- On macOS, `background-opacity` can still require a full Ghostty restart

## Roadmap

- Font controls (`boo font`) are planned and will return in an upcoming release.
- More quality-of-life improvements for first-time setup.

## License

MIT
