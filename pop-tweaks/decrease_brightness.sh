#!/bin/bash
current_brightness=$(sudo asdbctl get | awk -F ':' '{ print $2}' | tr -d ' ')
min_brightness=400
max_brightness=60000
step=5960  # This is 10% of the total range (59600).

new_brightness=$((current_brightness - step))

if [ $new_brightness -lt $min_brightness ]; then
    new_brightness=$min_brightness
fi

# Convert new_brightness to a percentage scale (0-100)
brightness_percent=$(( (new_brightness - min_brightness) * 100 / (max_brightness - min_brightness) ))

echo "New brightness percentage: $brightness_percent%"

sudo asdbctl set $brightness_percent
