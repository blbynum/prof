#!/usr/bin/env bash

die() {
    echo "$1" >&2
    if [ -n "$2" ]; then
        echo "$2" >&2
    fi
    exit 1
}

if [ $# -ne 3 ]; then
    die "Usage: $0 <script_path> <current_version> <github_repo>"
fi

SCRIPT_PATH="$1"
CURRENT_VERSION="$2"
GITHUB_REPO="$3"

echo "Checking for updates..."
latest_release_info=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest")

if [ $? -ne 0 ]; then
    die "Failed to fetch release information." "Check your internet connection and try again."
fi

latest_version=$(echo "$latest_release_info" | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"//;s/"//')

if [ -z "$latest_version" ]; then
    die "Failed to parse latest version." "The GitHub API response may have changed. Please report this issue."
fi

if [ "$(printf '%s\n' "$CURRENT_VERSION" "$latest_version" | sort -V | tail -n1)" = "$CURRENT_VERSION" ]; then
    echo "No updates available."
    exit 0
fi

echo "Updating to version $latest_version..."

download_url=$(echo "$latest_release_info" | grep -o '"browser_download_url": *"[^"]*"' | grep -v "updater.sh" | sed 's/"browser_download_url": *"//;s/"//')

if [ -z "$download_url" ]; then
    die "Failed to find download URL." "The release may not have an attached script. Check the GitHub repository."
fi

temp_file=$(mktemp)

if ! curl -sL "$download_url" -o "$temp_file"; then
    rm "$temp_file"
    die "Failed to download the update." "Check your internet connection and try again."
fi

if [ ! -s "$temp_file" ]; then
    rm "$temp_file"
    die "Downloaded file is empty." "The download may have been interrupted. Please try again."
fi

if ! chmod +x "$temp_file"; then
    rm "$temp_file"
    die "Failed to set execute permissions on the updated script." "Check file system permissions and try again."
fi

if ! mv "$temp_file" "$SCRIPT_PATH"; then
    rm "$temp_file"
    die "Failed to replace the old script with the new version." "Check file system permissions and try again."
fi

echo "Update successful. New version: $latest_version"

# Self-delete
rm -- "$0"

exit 0
