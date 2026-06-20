#!/usr/bin/env bash
killall waybar 2>/dev/null
sleep 0.2

waybar -c ~/.config/waybar/config &

for output in $(hyprctl monitors -j | jq -r '.[].name'); do
    if [ "$output" != "eDP-1" ]; then
        jq --arg out "$output" '.output = [$out]' \
            ~/.config/waybar/config-secondary \
            > "/tmp/waybar-secondary-${output}.json"
        waybar -c "/tmp/waybar-secondary-${output}.json" &
    fi
done