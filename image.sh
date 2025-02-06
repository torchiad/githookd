#!/bin/sh
# Pre-commit hook: Check that image dimensions (width and height) are even

# Get list of staged files (Added, Copied, or Modified)
staged_files=$(git diff --cached --name-only --diff-filter=ACM)

# Loop through the staged files
for file in $staged_files; do
    # Check if the file is a PNG or JPEG (adjust regex if needed)
    if echo "$file" | grep -Ei "\.(png|jpe?g)$" > /dev/null; then
        # Use ImageMagick's "identify" to get dimensions.
        # Make sure ImageMagick is installed on your system.
        dims=$(identify -format "%w %h" "$file" 2>/dev/null)
        if [ -z "$dims" ]; then
            echo "Warning: Could not determine dimensions for '$file'. Skipping check."
            continue
        fi

        width=$(echo $dims | cut -d' ' -f1)
        height=$(echo $dims | cut -d' ' -f2)

        # Check if width or height is not divisible by 2 (i.e. is odd)
        if [ $((width % 2)) -ne 0 ] || [ $((height % 2)) -ne 0 ]; then
            echo "Error: '$file' has dimensions ${width}x${height} which are not even."
            echo "Please fix the image dimensions before committing."
            exit 1  # Abort commit
        fi
    fi
done

# If we get here, all image checks passed
exit 0
