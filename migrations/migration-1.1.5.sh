#!/usr/bin/env bash

set -e

PROFILES_DIR=~/.profiles
OLD_PROFILES_DIR=~/.bash_profiles
ROOT_PROFILE=""

error_exit() { echo "Error: $1" >&2; exit 1; }

echo "Running v1.1.5 migration..."

migrate_directory() {
    if [ -d "$PROFILES_DIR" ]; then
        echo "$PROFILES_DIR already exists."
    elif [ -d "$OLD_PROFILES_DIR" ]; then
        echo "Migrating profiles to $PROFILES_DIR..."
        mkdir -p "$PROFILES_DIR" || error_exit "Failed to create $PROFILES_DIR"
        cp -Ra "$OLD_PROFILES_DIR/." "$PROFILES_DIR/" || error_exit "Failed to copy profiles"
        rm -rf "$OLD_PROFILES_DIR" || echo "Warning: Failed to remove $OLD_PROFILES_DIR. You may want to remove it manually."
    else
        error_exit "Neither $OLD_PROFILES_DIR nor $PROFILES_DIR exist. Cannot proceed with migration."
    fi
}

update_root_profile() {
    local profile="$1"
    if grep -q "# Load all profiles in the $PROFILES_DIR directory" "$profile"; then
        echo "Root profile already contains the new loading code."
    else
        echo "Updating root profile..."
        cp "$profile" "${profile}.bak" || error_exit "Failed to backup root profile"
        sed -i -e '/# Load all profiles in the .* directory/,+5d' "$profile" || error_exit "Failed to update root profile"
        cat << EOF >> "$profile" || error_exit "Failed to add new profile loading code"

# Load all profiles in the $PROFILES_DIR directory
for profile in $PROFILES_DIR/*; do
    if [ -f "\$profile" ]; then
        source "\$profile"
    fi
done
EOF
        echo "Root profile updated successfully."
    fi
}

prompt_for_root_profile() {
    while true; do
        read -p "Enter the path to your root profile (e.g., ~/.bash_profile or ~/.zshrc): " ROOT_PROFILE
        ROOT_PROFILE="${ROOT_PROFILE/#\~/$HOME}"
        if [ -f "$ROOT_PROFILE" ]; then
            return 0
        fi
        read -p "File does not exist. Do you want to try another file? (y/n): " retry
        [[ $retry =~ ^[Yy]$ ]] || error_exit "Root profile not found. Exiting."
    done
}

# Main execution
[ -z "$BASH_VERSION" ] && error_exit "This script must be run with bash"

migrate_directory

prompt_for_root_profile

update_root_profile "$ROOT_PROFILE"

echo "Migration completed successfully."
echo "Please restart your shell or run 'source $ROOT_PROFILE' to apply the changes."
