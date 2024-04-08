#!/bin/bash

# Download swirl from the specified URL
sudo wget -O /usr/bin/swirl "http://nodemixaholic.com:3002/nodemixaholic/swirl/raw/commit/27e18143bb65e7781cd41ca89b72560004cf24fc/swirl" || {
    echo "Failed to download swirl."
    exit 1
}

chmod +x /usr/bin/swirl

# Install necessary packages
sudo apt update
sudo apt install --no-install-recommends -y busybox clang irssi flatpak libreoffice kritavlc  || {
    echo "Failed to install necessary packages."
    exit 1
}

sudo apt remove rhythmbox

# List of GNU commands and their corresponding BusyBox equivalents
commands=(
    "ls:busybox ls"
    "cat:busybox cat"
    #"cp:busybox cp" # needed for installing GRUB apt package[!]
    #"mv:busybox mv" # knowing the above is needed for install, disable in case[!]
    "rm:busybox rm"
    "rmdir:busybox rmdir"
    "mkdir:busybox mkdir"
    #"grep:busybox grep" #needed for updating initramfs[?]
    #"sed:busybox sed" #shotgun approach
    #"find:busybox find" #needed for updating initramfs[?]
    #"chmod:busybox chmod"
    "chown:busybox chown"
    "wc:busybox wc"
    #"head:busybox sed -n '1,11p; 12q'"
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

sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

## Replace bash with busybox sh
printf "\n\nbusybox sh" >> "/etc/bash.bashrc"

## Add T2 Mac Compatibility

CODENAME=jammy
sudo curl -L -o /etc/apt/sources.list.d/t2.list -url "https://adityagarg8.github.io/t2-ubuntu-repo/t2.list"
echo "deb [signed-by=/etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg] https://github.com/AdityaGarg8/t2-ubuntu-repo/releases/download/${CODENAME} ./" >> /etc/apt/sources.list.d/t2.list
curl -L -url "https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg >/dev/null
sudo apt update
sudo apt install linux-t2
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