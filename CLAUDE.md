# Boo — Agent Context

This file gives AI agents the design philosophy, conventions, and decisions made in this project so work is consistent across sessions.

---

## What Boo Is

A single-file CLI (`bin/boo`) that manages a Ghostty + Zsh terminal setup. It controls themes, fonts, opacity, prompt backends, splash art, and shell mode. Everything lives in `~/.config/boo/`.

The CLI is a single large bash script — no dependencies, no build step. Keep it that way.

---

## Theme System Philosophy

**The core rule: a theme is a total color universe, not a dark background with accents.**

Every theme owns the entire 16-color ANSI palette. Text, errors, prompts, git status — everything lives inside that theme's color spectrum. There are no "neutral" fallback grays sneaking in.

### Existing themes

| Theme    | Identity                              | Background | Accent    |
|----------|---------------------------------------|------------|-----------|
| obsidian | Dark green-black + purple tint        | `#0b0f0b`  | `#a882ff` |
| lunar    | Cold blue-gray                        | `#0a0f18`  | `#7cc6ff` |
| crimson  | Everything bleeds red                 | `#120606`  | `#ff4f7a` |
| abyss    | Deep indigo void → violet-to-magenta  | `#060412`  | `#cc44ff` |
| fallout  | RobCo phosphor CRT, warm amber-lime   | `#020602`  | `#4af626` |

**abyss** was directly inspired by the Pastel Ghost / Abyss album cover — deep indigo-black background, all 16 ANSI colors live between dark indigo (`#3d0a6b`) and bright magenta-violet (`#f0d0ff`). All body text is purple-tinted (`#9966cc`).

### When adding a new theme, touch all of these:

1. `theme_accent_color()` — hex accent
2. `theme_panel_rgb()` — RGB for shell panel (R;G;B format)
3. `theme_core_colors()` — bg/fg/accent/cursor/selection for preview swatches
4. `apply_theme()` — Ghostty config values (background, foreground, cursor, selection)
5. `theme_palette_lines()` — full 16-color ANSI palette (all in the theme's spectrum)
6. `apply_prompt_theme()` — oh-my-posh color overrides
7. Theme list string in `cmd_theme()`, routing in `case` statements, `cmd_preview()`, `local themes=(...)`, and the subcommand dispatcher at the bottom

---

## CLI Output Design

The CLI output should feel **designed**, not like debug output. Key principles:

- **True color (24-bit)** is always available — use `\033[38;2;R;G;Bm` / `\033[48;2;R;G;Bm`
- **256-color** for muted grays — labels use `\033[38;5;244m`, values `\033[38;5;252m`, dim paths `\033[38;5;237m`
- The current theme's **accent color** should be used as the primary highlight in all styled output
- Box drawing: `╭╮╰╯│─` for panels, never plain `+---+`
- Labels left-aligned and padded (`%-10s`), values in near-white

### `boo status` — current design

```
  ╭────────────────────────────────────────────────────╮
  │  boo                                      abyss   │
  │  [16 palette color blocks from ANSI 0-15]          │
  ╰────────────────────────────────────────────────────╯

  theme       abyss           ████  #cc44ff

  mode        full                opacity    1.00
  splash      apple               prompt     omp
  font        Hack Nerd Font  14

  ghostty     ~/Library/.../config
              ~/.config/ghostty/config
```

- The palette strip inside the header box shows all 16 ANSI theme colors as solid blocks — it's the visual fingerprint of the active theme
- The whole panel adapts to the active theme's accent color
- Two-column layout for mode/opacity and splash/prompt

---

## Code Conventions

- Single bash file: `bin/boo` — no splitting into multiple files
- All theme data is in pure bash `case` statements — no config files, no JSON
- `upsert_key()` handles all Ghostty config writes (idempotent, creates if missing)
- `collect_ghostty_targets()` must be called before touching Ghostty configs — handles both `~/Library/...` (macOS) and `~/.config/ghostty/config`
- `hex_to_rgb()` returns `R;G;B` format, usable directly in ANSI escape codes: `\033[38;2;${rgb}m`
- `emit_standard_palette_16_255()` appends the standard xterm 256-color palette (indices 16-255) after the 16 theme colors
- Never use `echo` for output — always `printf`
- Always use `set -euo pipefail` behavior — the script has it at the top

---

## File Structure

```
bin/boo                          — the entire CLI (single bash file)
shell/boo.zsh                    — shell integration + startup panel (sourced in ~/.zshrc)
art/*.txt                        — built-in ASCII splash art files
configs/ghostty/                 — reference Ghostty config
configs/ohmyposh/                — oh-my-posh theme presets
scripts/install.sh               — installer script
~/.config/boo/                   — user config dir (created on install)
  theme                          — active theme name
  theme.zsh                      — BOO_THEME / BOO_ACCENT_COLOR / BOO_PANEL_COLOR_RGB
  mode.zsh                       — BOO_SHOW_PRIVATE
  prompt                         — native or omp
  splash.zsh                     — BOO_SPLASH
  boo.zsh                        — shell snippet (copied from shell/boo.zsh)
  art/                           — built-in splash art (copied from art/)
  custom-splash.txt              — user's custom splash (if set)
```

---

## Planned / In Progress

- More splash art (braille-based for smooth curves, or Ghostty inline image protocol)
- `boo preview` improvements — richer swatch display
- `boo theme list` — each theme name rendered in its own accent color with inline swatch
- `forge` theme (molten orange-fire) and `venom` theme (toxic UV purple) are candidates
