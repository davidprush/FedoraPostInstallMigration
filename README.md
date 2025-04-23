# migrate-fedora
Helper scripts to transfer KDE system settings, installed apps, user's home directory to a new computer using Fedora.

## Migrate Home Directory

### Network rsync

rsync -aP --exclude-from=ignorelist.txt /home/$USER david@192.168.86.10:/mnt/WD16TB/shared/home-backup/david/

### Physical Transfer Using Media

rsync -aP ---exclude-from=ignorelist.txt /home/$USER/ /media/$USER/linuxbackup/home/$USER/

## transfer-kde-settings.sh

### How to Use the Script

#### Save the Script:

- Save it as transfer-kde-settings.sh.

- Make it executable: `chmod +x transfer-kde-settings.sh`

- Edit Variables:

  1. Update SOURCE_HOST, SOURCE_USER, TARGET_DIR, SSH_KEY to match your setup.

  2. Adjust CONFIG_DIRS, LOCAL_DIRS, or EXCLUDE_FILES if you need specific files or want to include cache.

#### Run the Script:

Execute: `./transfer-kde-settings.sh`

**Ensure SSH is configured (e.g., ~/.ssh/id_rsa exists and is authorized on the source).**

### Apply Settings:

- Follow the script’s final instructions to log out/in or restart Plasma.

### Additional Notes

- Dependencies: Install rsync and tar on both systems (`sudo dnf install rsync tar`).

- Version Compatibility: Check KDE Plasma versions with plasmashell --version. Mismatches may cause issues.

**Manual Transfer: If SSH isn’t available, copy files to a USB drive with:**

```bash
tar -czf kde-settings.tar.gz ~/.config ~/.local/share
```

### Then extract on the new system:

```bash
tar -xzf kde-settings.tar.gz -C ~
```

- Specific Settings: If you only want specific settings (e.g., only Konsole), modify CONFIG_DIRS and LOCAL_DIRS to include only those files (e.g., .config/konsolerc, .local/share/konsole).

### Troubleshooting: If settings don’t apply correctly, clear the cache (`rm -rf ~/.cache/*`) and restart Plasma.

***This script should cover most KDE settings, but let me know if you need adjustments for specific applications or a different transfer method!***

## install-packages.sh

Below, I’ll guide you through the process of listing installed programs on Fedora 42 Linux, exporting them to a file, and creating a robust script to reinstall those programs on a new system. The script will include error handling and detailed explanations to ensure clarity and reliability.

### Step 1: Listing Installed Programs on Fedora 42

Fedora uses the dnf package manager, which tracks installed packages. To list explicitly installed packages (those you manually installed, excluding dependencies), you can use the dnf history userinstalled command. This is ideal for capturing your intentionally installed applications.
Command to List Explicitly Installed Packages

```bash
dnf history userinstalled > packages.txt
```

**Explanation**

- dnf history userinstalled: Lists packages that were explicitly installed by the user, omitting automatically installed dependencies.

`> packages.txt`: Redirects the output to a file named packages.txt in your current directory.

The resulting packages.txt file will contain package names, one per line, such as firefox, vlc, or gnome-tweaks.

#### Notes

The output may include some system packages or dependencies. You should review and edit packages.txt to include only the applications you want to reinstall on the new system.

### To view the file, use:

```bash
cat packages.txt
```

Edit the file with a text editor (e.g., `nano packages.txt`) to remove unwanted packages or add comments for clarity.

### Alternative Approach

If you want a complete list of all installed packages (including dependencies), use:

```bash
rpm -qa --qf "%{NAME}\n" | sort > all_packages.txt
```

__However, this list will be much longer and include system libraries and dependencies, which may not be necessary for reinstallation. The dnf history userinstalled method is generally preferred for user-installed applications.__

### Transferring the List

**Once you have packages.txt, transfer it to the new system (e.g., via USB drive, network share, or cloud storage like Google Drive).**

### Step 2: Creating the Installation Script

Above is a Bash script that uses packages.txt to install the listed packages on a new Fedora 42 system. The script includes error handling, logging, and detailed comments to explain each step.

Script: `install_packages.sh`

#### How to Use the Script

Save the Script:

**Copy the script above into a file named install_packages.sh on the new Fedora 42 system.**

Example:

```bash
nano install_packages.sh
```

- Paste the script, save, and exit.

- Make the Script Executable:

```bash
chmod +x install_packages.sh
```

- Place the Package List:

**Ensure packages.txt (from Step 1) is in the same directory as the script.**

- Run the Script:

**Execute the script with root privileges:**

```bash
sudo ./install_packages.sh
```

#### Script Features and Explanations

**Shebang (#!/bin/bash): Specifies that the script runs in Bash.**

- Variables:

1. PACKAGE_LIST: Name of the input file (packages.txt).
2. LOG_FILE: Log file to record installation progress and errors.
3. ERROR_COUNT and SUCCESS_COUNT: Track the number of failed and successful installations.

- Logging Function (log_message):

1. Appends timestamped messages to both the terminal and install_packages.log.
2. Ensures all actions are recorded for troubleshooting.

- Root Check (check_root):

Verifies the script is run with sudo, as dnf requires root privileges.

- Package List Check (check_package_list):

Ensures packages.txt exists and is not empty.

- System Update (update_system):

Runs `dnf update -y` to refresh package metadata and apply system updates.
Continues even if the update fails (non-critical).

- Package Installation (install_packages):

Reads packages.txt line by line, skipping empty lines and comments (lines starting with #).
Installs each package using dnf install -y.
Logs success or failure and updates counters.

- Error Handling:

1. Checks for missing files, root privileges, and installation failures.
2. Logs all errors to install_packages.log for review.
3. Exits with a non-zero status if any installations fail.

- Summary and Suggestions:

1. Reports the number of successful and failed installations.
2. Suggests enabling RPM Fusion repositories for third-party software (e.g., multimedia codecs, Steam) if packages are unavailable.

- Example packages.txt

```
firefox
vlc
gnome-tweaks
# libreoffice  # Commented out, will be skipped
gimp
```

- Log File Example (install_packages.log)

```bash
Package Installation Log
[2025-04-23 12:54:01] Script initialized.
[2025-04-23 12:54:02] Updating system packages...
[2025-04-23 12:54:10] System update completed successfully.
[2025-04-23 12:54:10] Starting package installation from 'packages.txt'...
[2025-04-23 12:54:11] Installing package: firefox
[2025-04-23 12:54:15] Successfully installed firefox
[2025-04-23 12:54:15] Installing package: vlc
[2025-04-23 12:54:20] Successfully installed vlc
[2025-04-23 12:54:20] Installing package: gnome-tweaks
[2025-04-23 12:54:25] Successfully installed gnome-tweaks
[2025-04-23 12:54:25] Installing package: gimp
[2025-04-23 12:54:30] ERROR: Failed to install gimp
[2025-04-23 12:54:30] Installation complete. Successful: 3, Failed: 1
[2025-04-23 12:54:30] WARNING: 1 package(s) failed to install. Check 'install_packages.log' for details.
[2025-04-23 12:54:30] To retry failed installations, review 'install_packages.log' and reinstall manually.
[2025-04-23 12:54:30] Note: If some packages are missing, consider enabling third-party repositories (e.g., RPM Fusion).
[2025-04-23 12:54:30] Run: sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
[2025-04-23 12:54:30]     sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

#### Step 3: Additional Considerations

- Enabling Third-Party Repositories

**Some applications (e.g., VLC, Steam, or multimedia codecs) may require third-party repositories like RPM Fusion. The script suggests enabling these at the end. To do so manually:**

```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

**Run these commands before executing the script if you know your packages depend on RPM Fusion.**

- Handling Flatpaks or Snaps

If you use Flatpak or Snap packages (e.g., from Flathub or Snap Store), these are not managed by dnf. To list installed Flatpaks:
bash

```bash
flatpak list --app > flatpaks.txt
```

#### To reinstall Flatpaks on the new system:

```bash
xargs -a flatpaks.txt flatpak install -y
```

#### Ensure Flathub is enabled:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

__The script above focuses on dnf packages, but you can extend it to handle Flatpaks by adding a similar loop for flatpak install.__

### Troubleshooting

- Package Not Found: If a package fails to install, check if it’s available in the default repositories or requires RPM Fusion. Search for it:

```bash
dnf search package_name
```

- Version Mismatches: Fedora 42 may have newer package versions. The script uses package names (not versions), so it should install the latest available version.

- **Log Review:** Check install_packages.log for detailed error messages if any installations fail.

- **Network Issues:** Ensure the new system has an internet connection, as dnf downloads packages from online repositories.

#### Testing the Script

__Before running the script on the new system, test it on a virtual machine or a non-critical system to ensure it works as expected. You can create a Fedora 42 virtual machine using tools like VirtualBox or GNOME Boxes.__

## Summary

- List Installed Packages: Use dnf history userinstalled > packages.txt to capture explicitly installed packages. Edit packages.txt to include only desired applications.

- Installation Script: The provided install_packages.sh script automates package installation with error handling, logging, and user-friendly output. It checks for root privileges, validates the package list, updates the system, and installs packages while tracking successes and failures.

- Additional Steps: Enable RPM Fusion for third-party packages and handle Flatpaks separately if needed.

- Troubleshooting: Review install_packages.log for errors and ensure repositories are correctly configured.

- This approach ensures you can efficiently replicate your Fedora 42 setup on a new system while minimizing manual effort and handling potential errors gracefully.

### Sources:

- Fedora package management documentation

- Community discussions on automating package installation

- RPM Fusion setup guide
