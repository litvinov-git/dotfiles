#!/bin/bash
# ~/bin/spf-open.sh
# Safe wrapper for gio open

# Exit if no argument
[ -z "$1" ] && exit 1

# Call gio open safely with the path as-is
gio open "$1"

