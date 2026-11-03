# Waybar Configuration

Waybar setup for the [Hyprland Lua config](https://github.com/sxnkr/hyprland-lua-config).
One bar per monitor, generated at launch, with no hardcoded connector names, so it works across different laptops (the dotfiles live on a portable SSD).

---

## Files

```
~/.config/waybar/
├── config               # Full bar (laptop panel)
├── config-secondary     # Slim bar (external displays)
├── style.css            # Shared theme (Catppuccin-style colors, JetBrains Mono)
├── start-waybar.sh      # Launcher: one Waybar per output
└── start-waybar.sh.bak  # Original launcher (see "Temporary" below)
```

## Bars

| Bar | Left | Right |
|---|---|---|
| `config` (full) | workspaces, window title | network, volume, battery, clock, tray |
| `config-secondary` (slim) | workspaces, window title | clock |

- Workspaces use Roman numerals (I–X), scroll to switch.
- Volume: click to mute, right-click opens `pavucontrol`.
- Clock: click to toggle the full date/time format.

## How `start-waybar.sh` works

1. Kills any running Waybar.
2. Reads monitors from `hyprctl monitors -j`.
3. Finds the laptop panel by connector prefix (`eDP*` / `LVDS*`).
4. For each output, writes `$XDG_RUNTIME_DIR/waybar-<output>.json` from the right source config and injects `"output"`. The source configs never set `output` themselves.
5. Drops `battery#batN` modules whose battery doesn't exist on this machine.
6. Starts one Waybar per output.

Hyprland runs it at startup (`config/autostart.lua`) and after monitor changes (`scripts/auto-monitor.sh`).

## ⚠️ Temporary: external-display-only mode

The laptop screen is broken, so `start-waybar.sh` currently uses the **full** bar on every output instead of the slim bar on externals. The original launcher is saved as `start-waybar.sh.bak`.

### Restore (after the laptop display is fixed)

```sh
mv ~/.config/waybar/start-waybar.sh.bak ~/.config/waybar/start-waybar.sh
```

Restore the Hyprland side too (see the hypr repo README), then delete this section.

## Dependencies

- `waybar`, `jq`, `hyprctl` (Hyprland)
- `pactl` / `pavucontrol` (volume)
- Fonts: JetBrains Mono, a Nerd Font for icons
