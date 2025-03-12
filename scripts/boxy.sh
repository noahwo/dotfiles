#!/bin/bash

# Combine all arguments into a single string
message="$*"

# Calculate the width of the content area (message + padding spaces)
content_width=$((${#message} + 4)) # 4 extra chars for the 2 spaces on each side

# Calculate total width of box (including the % borders)
total_width=$((content_width + 2)) # +2 for the left and right border characters

# Create the top and bottom borders
border=$(printf '%%%.0s' $(seq 1 $total_width))

# Create the empty line (% + spaces + %)
empty_spaces=$(printf ' %.0s' $(seq 1 $content_width))
empty_line="%${empty_spaces}%"

# Print the box
echo "$border"
echo "$empty_line"
echo "%  $message  %"
echo "$empty_line"
echo "$border"
