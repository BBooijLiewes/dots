#!/usr/bin/env sh

# Terminate already running bar instances
killall -q /home/bob/tools/Waybar/build/waybar

# Wait until the processes have been shut down
while pgrep -x /home/bob/tools/Waybar/build/waybar >/dev/null; do sleep 1; done

# Launch main
/home/bob/tools/Waybar/build/waybar
