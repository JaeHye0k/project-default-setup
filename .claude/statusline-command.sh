#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values
model=$(echo "$input" | jq -r '.model.display_name')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# If no messages yet, show model name only
if [ -z "$used_pct" ]; then
    printf "%s" "$model"
    exit 0
fi

# Round percentage to integer
used_int=$(printf "%.0f" "$used_pct")

# Progress bar configuration
bar_width=20
filled=$(( (used_int * bar_width) / 100 ))
empty=$(( bar_width - filled ))

# Build progress bar
bar="["
for ((i=0; i<filled; i++)); do
    bar+="="
done
for ((i=0; i<empty; i++)); do
    bar+=" "
done
bar+="]"

# Output: Model Name [====      ] 42%
printf "%s %s %d%%" "$model" "$bar" "$used_int"
