# migrate-fedora
Helper scripts to transfer KDE system settings, installed apps, user's home directory to a new computer using Fedora.

How to Use the Script
Save the Script:
Save it as transfer-kde-settings.sh.

Make it executable: chmod +x transfer-kde-settings.sh.

Edit Variables:
Update SOURCE_HOST, SOURCE_USER, TARGET_DIR, SSH_KEY to match your setup.

Adjust CONFIG_DIRS, LOCAL_DIRS, or EXCLUDE_FILES if you need specific files or want to include cache.

Run the Script:
Execute: ./transfer-kde-settings.sh.

Ensure SSH is configured (e.g., ~/.ssh/id_rsa exists and is authorized on the source).

Apply Settings:
Follow the script’s final instructions to log out/in or restart Plasma.

Additional Notes
Dependencies: Install rsync and tar on both systems (sudo dnf install rsync tar).

Version Compatibility: Check KDE Plasma versions with plasmashell --version. Mismatches may cause issues.

Manual Transfer: If SSH isn’t available, copy files to a USB drive with:
bash

tar -czf kde-settings.tar.gz ~/.config ~/.local/share

Then extract on the new system:
bash

tar -xzf kde-settings.tar.gz -C ~

Specific Settings: If you only want specific settings (e.g., only Konsole), modify CONFIG_DIRS and LOCAL_DIRS to include only those files (e.g., .config/konsolerc, .local/share/konsole).

Troubleshooting: If settings don’t apply correctly, clear the cache (rm -rf ~/.cache/*) and restart Plasma.

This script should cover most KDE settings, but let me know if you need adjustments for specific applications or a different transfer method!

