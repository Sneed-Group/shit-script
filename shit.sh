#!/bin/bash

# Download swirl from the specified URL
sudo wget -O /usr/bin/swirl "http://nodemixaholic.com:3002/nodemixaholic/swirl/raw/commit/27e18143bb65e7781cd41ca89b72560004cf24fc/swirl" || {
    echo "Failed to download swirl."
    exit 1
}

chmod +x /usr/bin/swirl

# Install necessary packages
sudo apt update
sudo apt install -y busybox clang irssi xfce4 xfce4-screenshooter flatpak libreoffice krita network-manager-gnome || {
    echo "Failed to install necessary packages."
    exit 1
}

# List of GNU commands and their corresponding better equivalents
commands=(
    "gcc:clang"
    "g++:clang"
    "wget:swirl"
    "curl:swirl"
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

sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

## Replace bash with busybox sh
printf "\n\nbusybox sh" >> "/etc/bash.bashrc"

## Add T2 Mac Compatibility

sudo apt install cinnamon sddm
curl -L -url "https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg >/dev/null
sudo curl -L -o /etc/apt/sources.list.d/t2.list -url "https://adityagarg8.github.io/t2-ubuntu-repo/t2.list"
sudo apt update
sudo apt install t2-kernel-script
sudo update_t2_kernel
sudo apt install apple-t2-audio-config tiny-dfr zstd
wget -url http://nodemixaholic.com:3002/nodemixaholic/apple-broadcom-firmware-arch/raw/branch/main/apple-bcm-firmware-14.0-1-any.pkg.tar.zst -o "apple-bcm-firmware-14.0-1-any.pkg.tar.zst"
zstd -d -c apple-bcm-firmware-14.0-1-any.pkg.tar.zst | tar -xvf -
sudo cp -r ./usr/* /usr/
sudo apt install iwd
sudo sed -i 's/^wifi\.backend.*/wifi.backend=iwd/' /etc/NetworkManager/NetworkManager.conf
sudo systemctl enable --now iwd
git clone https://github.com/kekrby/t2-better-audio
cd t2-better-audio
sudo ./install.sh
cd ..