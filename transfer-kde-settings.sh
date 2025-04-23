#!/bin/bash

# Script to transfer KDE settings from one Fedora system to another

# Configuration
SOURCE_HOST="old-computer"  # Replace with the source computer's hostname or IP
SOURCE_USER="your-username"  # Replace with your username on the source system
TARGET_DIR="/home/your-username/kde-settings-backup"  # Local backup directory on target
REMOTE_DIR="/home/$SOURCE_USER"  # Home directory on source
SSH_KEY="~/.ssh/id_rsa"  # Path to SSH key (if needed)

# Directories to transfer
CONFIG_DIRS=".config"
LOCAL_DIRS=".local/share"
EXCLUDE_FILES="*.cache*"  # Exclude cache files by default

# Ensure SSH access
echo "Checking SSH access to $SOURCE_HOST..."
if ! ssh -q -i "$SSH_KEY" "${SOURCE_USER}@${SOURCE_HOST}" exit; then
    echo "Error: Cannot connect to $SOURCE_HOST via SSH. Please check credentials or network."
    exit 1
fi

# Create backup directory on target
echo "Creating backup directory on target system: $TARGET_DIR"
mkdir -p "$TARGET_DIR/backup"

# Backup existing settings on target
echo "Backing up existing KDE settings on target..."
[ -d ~/.config ] && tar -czf "$TARGET_DIR/backup/config-backup-$(date +%F).tar.gz" -C ~ .config
[ -d ~/.local/share ] && tar -czf "$TARGET_DIR/backup/local-share-backup-$(date +%F).tar.gz" -C ~ .local/share

# Transfer settings from source
echo "Transferring KDE settings from $SOURCE_HOST..."
rsync -avz --progress -e "ssh -i $SSH_KEY" \
    --exclude="$EXCLUDE_FILES" \
    "${SOURCE_USER}@${SOURCE_HOST}:${REMOTE_DIR}/{${CONFIG_DIRS},${LOCAL_DIRS}}" \
    "$TARGET_DIR"

# Copy to home directory
echo "Copying settings to home directory..."
cp -r "$TARGET_DIR/.config" ~/
cp -r "$TARGET_DIR/.local/share" ~/

# Fix permissions
echo "Fixing permissions..."
chown -R "$USER:$USER" ~/.config ~/.local/share

# Instructions for applying settings
echo "Transfer complete!"
echo "To apply settings:"
echo "1. Ensure the same KDE Plasma version is installed on this system."
echo "   Run: sudo dnf groupinstall 'KDE Plasma Workspaces'"
echo "2. Log out and log back in, or restart Plasma with:"
echo "   kquitapp5 plasmashell && kstart5 plasmashell"
echo "3. If issues arise, restore backup from $TARGET_DIR/backup"

exit 0
