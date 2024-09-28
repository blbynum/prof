#!/usr/bin/env bash

set -o pipefail

DEBUG=${DEBUG:-false}

die() {
    echo "Error: $1" >&2
    if [ -n "$2" ]; then
        echo "$2" >&2
    fi
    exit 1
}

debug() {
    if [ "$DEBUG" = true ]; then
        echo "DEBUG: $1" >&2
    fi
}

if [ $# -ne 5 ]; then
    die "Usage: $0 <script_path> <current_version> <github_repo> <allow_prereleases> <latest_version>"
fi

SCRIPT_PATH="$1"
CURRENT_VERSION="$2"
GITHUB_REPO="$3"
ALLOW_PRERELEASES="$4"
LATEST_VERSION="$5"

version_compare() {
    if [[ $1 == $2 ]]; then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

run_migrations() {
    local from_version="$1"
    local to_version="$2"
    local temp_dir=$(mktemp -d)

    echo "Checking for migration scripts..."
    local all_releases=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases")
    
    debug "All releases: $all_releases"
    
    local versions=$(echo "$all_releases" | jq -r '.[] | select(.tag_name | test("^v?[0-9]+\\.[0-9]+\\.[0-9]+$")) | .tag_name' | sort -V)
    debug "Extracted versions: $versions"

    echo "$versions" | while read -r version_tag; do
        debug "Processing version tag: $version_tag"
        local version=${version_tag#v}  # Remove 'v' prefix if present
        debug "Cleaned version: $version"

        if [ "$(printf '%s\n' "$from_version" "$version" | sort -V | head -n1)" = "$from_version" ] && \
           [ "$from_version" != "$version" ] && \
           [ "$(printf '%s\n' "$version" "$to_version" | sort -V | tail -n1)" = "$to_version" ]; then
            local migration_script="migration-${version}.sh"
            debug "Looking for migration script: $migration_script"
            local download_url=$(echo "$all_releases" | jq -r ".[] | select(.tag_name == \"$version_tag\") | .assets[] | select(.name == \"$migration_script\") | .browser_download_url")
            
            debug "Migration script download URL: $download_url"
            
            if [ -n "$download_url" ] && [ "$download_url" != "null" ]; then
                echo "Running migration script for version $version..."
                local script_path="$temp_dir/$migration_script"
                if curl -sL "$download_url" -o "$script_path"; then
                    chmod +x "$script_path"
                    if ! "$script_path"; then
                        rm -rf "$temp_dir"
                        die "Migration script $migration_script failed."
                    fi
                    rm "$script_path"
                else
                    echo "Failed to download migration script $migration_script. Skipping..."
                fi
            else
                echo "No migration script found for version $version. Skipping..."
            fi
        else
            debug "Version $version not in range $from_version to $to_version (exclusive from_version, inclusive to_version)"
        fi
    done

    rm -rf "$temp_dir"
}

echo "Updating from version $CURRENT_VERSION to $LATEST_VERSION..."

release_info=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/tags/$LATEST_VERSION")

if [ $? -ne 0 ]; then
    die "Failed to fetch release information." "Check your internet connection."
fi

debug "Release info: $release_info"

download_url=$(echo "$release_info" | jq -r '.assets[] | select(.name == "prof") | .browser_download_url')

if [ -z "$download_url" ] || [ "$download_url" == "null" ]; then
    echo "Raw JSON response:" >&2
    echo "$release_info" | jq '.' >&2
    die "Failed to find download URL for 'prof'. Check the GitHub repository."
fi

debug "Download URL: $download_url"

temp_file=$(mktemp)

if ! curl -sL "$download_url" -o "$temp_file"; then
    rm "$temp_file"
    die "Failed to download the update." "Check your internet connection."
fi

if [ ! -s "$temp_file" ]; then
    rm "$temp_file"
    die "Downloaded file is empty." "The download may have been interrupted. Please try again."
fi

run_migrations "$CURRENT_VERSION" "$LATEST_VERSION"

if ! chmod +x "$temp_file"; then
    rm "$temp_file"
    die "Failed to set execute permissions on the updated script." "Check your file system permissions."
fi

if ! mv "$temp_file" "$SCRIPT_PATH"; then
    rm "$temp_file"
    die "Failed to replace the old script with the new version." "Check your file system permissions."
fi

echo "Update successful. New version: $LATEST_VERSION"

[ -f "$0" ] && rm "$0" 2>/dev/null

exit 0
