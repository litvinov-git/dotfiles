#!/bin/sh

# Create a list of sinks with pretty names
options=$(pactl -f json list sinks | jq -r '.[] | .description')

# Let the user select a description
selection=$(echo "$options" | fuzzel -d -i -l 5 -p "Output:")

# Extract the corresponding sink name
sink_name=$(pactl -f json list sinks | jq -r --arg sink_pretty_name "$selection" '.[] | select(.description == $sink_pretty_name) | .name')

# Set the selected sink as default
if [ -n "$sink_name" ]; then
    pactl set-default-sink "$sink_name"
elif [[  -z "$selection"  ]]; then
    exit o
else
    notify-send "Audio switch failed" -t 800
fi
