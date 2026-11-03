#!/usr/bin/env bash
# start-waybar.sh — launch one Waybar per connected output.
#
# This dotfiles install lives on a portable SSD that boots on more than one
# laptop, so no connector name (eDP-1, HDMI-A-1, ...) and no DRM card number
# may ever be hardcoded: they all change between machines.
#
# The internal panel is found by connector prefix (eDP* / LVDS*); every other
# output is treated as an external display:
#
#   internal panel   -> ~/.config/waybar/config           (full bar)
#   any other output -> ~/.config/waybar/config-secondary (slim bar)
#
# An explicit "output" key is injected per generated file, which is why neither
# source config carries an "output" field of its own.
#
# Battery modules whose battery does not exist on the current machine are
# dropped, so the bar looks the same on a laptop with BAT0 and one with BAT1.

set -u

CONF="$HOME/.config/waybar"
RUNTIME="${XDG_RUNTIME_DIR:-/tmp}"

# ── Batteries present on this machine, lowercase (bat0, bat1, ...) ──
present_batteries="$(for b in /sys/class/power_supply/BAT*; do
  [ -e "$b" ] && basename "$b" | tr '[:upper:]' '[:lower:]'
done | jq -R -s -c 'split("\n") | map(select(length > 0))')"

# ── Restart cleanly ──────────────────────────────────
killall waybar 2>/dev/null
sleep 0.2

monitors="$(hyprctl monitors -j)"

# ── Identify the internal panel by connector prefix ──
internal="$(printf '%s' "$monitors" \
  | jq -r '.[] | select(.name | test("^(eDP|LVDS)")) | .name' \
  | head -n1)"

# ── One bar per connected output ─────────────────────
printf '%s' "$monitors" | jq -r '.[].name' | while read -r output; do
  [ -n "$output" ] || continue

  # External-only setup (laptop screen broken): full bar on every output.
  # Original script saved as start-waybar.sh.bak
  src="$CONF/config"

  out="$RUNTIME/waybar-${output}.json"

  jq --arg out "$output" --argjson present "$present_batteries" '
      .output = [$out]
    | if .["modules-right"] then
        .["modules-right"] |= map(
          if startswith("battery#") then
            (sub("^battery#"; "") as $b
             | if ($present | index($b)) then . else empty end)
          else . end)
      else . end
  ' "$src" > "$out" || continue

  waybar -c "$out" &
done
