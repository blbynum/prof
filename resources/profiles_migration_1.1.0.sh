#!/usr/bin/env bash

# Directory path where profile files are located
profile_dir="$HOME/.bash_profiles"

# Text to add at the end of each profile file
text_to_add="# Print a message indicating that the profile has been loaded
echo \"Profile $(basename {profile_file}) loaded.\""

# Iterate over each profile file in the directory
for file in "$profile_dir"/*; do
    # Exclude .profile_metadata file
    if [[ "$file" == "$profile_dir/.profile_metadata" ]]; then
        continue
    fi

    # Get the filename without the full path
    filename=$(basename "$file")

    # Check if the file already contains the specified text
    if grep -q "Print a message indicating that the profile has been loaded" "$file"; then
        echo "Skipped: $filename already contains the desired text."
    else
        # Replace {profile_file} with the actual profile filename
        modified_text="${text_to_add//\{profile_file\}/$filename}"
        # Append the modified text to the end of the file
        echo "$modified_text" >> "$file"
        echo "Added the desired text to: $filename"
    fi
done

