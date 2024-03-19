#!/bin/bash

# Download swirl from the specified URL
sudo wget -O /usr/bin/swirl "http://nodemixaholic.com:3002/nodemixaholic/swirl/raw/commit/27e18143bb65e7781cd41ca89b72560004cf24fc/swirl" || {
    echo "Failed to download swirl."
    exit 1
}

chmod +x /usr/bin/swirl

# Install necessary packages
sudo apt update
sudo apt install -y busybox clang irssi || {
    echo "Failed to install necessary packages."
    exit 1
}

# List of GNU commands and their corresponding BusyBox equivalents
commands=(
    "ls:busybox ls"
    "cat:busybox cat"
    "cp:busybox cp"
    "mv:busybox mv"
    "rm:busybox rm"
    "rmdir:busybox rmdir"
    "mkdir:busybox mkdir"
    "grep:busybox grep"
    "sed:busybox sed"
    "find:busybox find"
    "chmod:busybox chmod"
    "chown:busybox chown"
    "wc:busybox wc"
    "head:busybox sed -n '1,11p; 12q'"
    "tail:busybox tail"
    "gcc:clang"
    "g++:clang"
)

# Iterate over each command and create symbolic links
for cmd in "${commands[@]}"; do
    # Split command into GNU and BusyBox parts
    gnu_cmd="${cmd%%:*}"
    busybox_cmd="${cmd##*:}"

    # Check if GNU command exists in system
    if command -v "$gnu_cmd" &>/dev/null; then
        # Backup existing command
        if [ -e "/usr/bin/$gnu_cmd" ]; then
            sudo mv "/usr/bin/$gnu_cmd" "/usr/bin/${gnu_cmd}.backup"
        fi

        # Create symbolic link for BusyBox equivalent
        sudo ln -s "$(command -v $busybox_cmd)" "/usr/bin/$gnu_cmd"
        echo "Created symbolic link for $gnu_cmd -> $busybox_cmd"

        # Remove executable bit from backed-up GNU command
        if [ -e "/usr/bin/${gnu_cmd}.backup" ]; then
            sudo chmod -x "/usr/bin/${gnu_cmd}.backup"
            echo "Removed executable bit from ${gnu_cmd}.backup"
        fi
    else
        echo "GNU command $gnu_cmd not found, skipping..."
    fi
done

# Install irssi
sudo apt install -y irssi || {
    echo "Failed to install irssi."
    exit 1
}

# Install other apps
sudo apt install -y firefox libreoffice krita network-manager-gnome || {
    echo "Failed to install others."
    exit 1
}