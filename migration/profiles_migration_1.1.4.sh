#!/bin/bash

# Define the old and new versions
old_version='
# Load all profiles in the ~/.bash_profiles directory
for profile in ~/.bash_profiles/*; do
    if [ -f "\$profile" ]; then
        source "\$profile"
    fi
done
'

new_version='
# Load profiles from ~/.bash_profiles directory based on load order in .profile_metadata
while IFS= read -r line; do
    profile_name=$(echo "$line" | cut -d'\'' '\'' -f2)
    profile_path=~/.bash_profiles/"$profile_name"
    if [ -f "$profile_path" ]; then
        source "$profile_path"
    fi
done < <(sort ~/.bash_profiles/.profile_metadata)
'

# Define the file to search and replace in
file=~/.bash_profile

# Determine which version of sed to use
if command -v gsed &> /dev/null; then
    sed_command="gsed"
elif command -v sed &> /dev/null; then
    sed_command="sed"
else
    echo "Neither sed nor gsed was found on this system. Please install one of them and try again."
    exit 1
fi

# Use sed to find and replace the old version with the new one
$sed_command -i.bak "s|$old_version|$new_version|g" "$file"
