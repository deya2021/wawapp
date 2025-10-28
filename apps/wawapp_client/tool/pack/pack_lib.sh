#!/bin/bash
# Pack lib folder for distribution

# Get git info
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
sha=$(git rev-parse --short=7 HEAD 2>/dev/null || echo "unknown")

# Generate timestamp
timestamp=$(date +"%Y%m%d-%H%M")

# Create artifacts directory
mkdir -p artifacts

# Generate ZIP filename (sanitize branch name)
safe_branch=$(echo "$branch" | sed 's/[^a-zA-Z0-9_-]/_/g')
zip_name="lib-${safe_branch}-${sha}-${timestamp}.zip"
zip_path="artifacts/${zip_name}"

# Remove existing ZIP if present
rm -f "$zip_path"

# Create ZIP
zip -r "$zip_path" lib

# Output absolute path
echo "$(pwd)/$zip_path"