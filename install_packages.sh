#!/bin/bash

# Script: install_packages.sh
# Purpose: Installs packages listed in packages.txt on a Fedora 42 system
# Author: Grok, created by xAI
# Date: April 23, 2025

# Define variables
PACKAGE_LIST="packages.txt"  # File containing the list of packages
LOG_FILE="install_packages.log"  # Log file for installation output
ERROR_COUNT=0  # Counter for failed installations
SUCCESS_COUNT=0  # Counter for successful installations

# Function to log messages
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to check if the script is run with root privileges
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_message "ERROR: This script must be run as root (use sudo)."
        exit 1
    fi
}

# Function to check if the package list file exists
check_package_list() {
    if [[ ! -f "$PACKAGE_LIST" ]]; then
        log_message "ERROR: Package list file '$PACKAGE_LIST' not found."
        exit 1
    fi
    if [[ ! -s "$PACKAGE_LIST" ]]; then
        log_message "ERROR: Package list file '$PACKAGE_LIST' is empty."
        exit 1
    fi
}

# Function to update the system before installation
update_system() {
    log_message "Updating system packages..."
    if ! dnf update -y; then
        log_message "WARNING: System update failed. Proceeding with package installation."
    else
        log_message "System update completed successfully."
    fi
}

# Function to install packages
install_packages() {
    log_message "Starting package installation from '$PACKAGE_LIST'..."

    # Read each package name from the file, ignoring empty lines and comments
    while IFS= read -r package; do
        # Skip empty lines or lines starting with '#'
        [[ -z "$package" || "$package" =~ ^# ]] && continue

        log_message "Installing package: $package"

        # Attempt to install the package
        if dnf install -y "$package" &>> "$LOG_FILE"; then
            log_message "Successfully installed $package"
            ((SUCCESS_COUNT++))
        else
            log_message "ERROR: Failed to install $package"
            ((ERROR_COUNT++))
        fi
    done < "$PACKAGE_LIST"

    log_message "Installation complete. Successful: $SUCCESS_COUNT, Failed: $ERROR_COUNT"
}

# Main execution
log_message "Starting package installation script..."

# Perform checks
check_root
check_package_list

# Initialize log file
echo "Package Installation Log" > "$LOG_FILE"
log_message "Script initialized."

# Update system
update_system

# Install packages
install_packages

# Check for errors and provide summary
if [[ $ERROR_COUNT -eq 0 ]]; then
    log_message "All packages installed successfully!"
else
    log_message "WARNING: $ERROR_COUNT package(s) failed to install. Check '$LOG_FILE' for details."
    log_message "To retry failed installations, review '$LOG_FILE' and reinstall manually."
fi

# Suggest enabling third-party repositories if needed
log_message "Note: If some packages are missing, consider enabling third-party repositories (e.g., RPM Fusion)."
log_message "Run: sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-\$(rpm -E %fedora).noarch.rpm"
log_message "    sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-\$(rpm -E %fedora).noarch.rpm"

exit $ERROR_COUNT
