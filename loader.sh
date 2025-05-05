#!/bin/bash

# setup_install.sh: Setup and install script for Roblox AFK bot (ZenithAFK) on Linux

# Exit on any error
set -e

# Check if running on Linux
if [ "$(uname -s)" != "Linux" ]; then
    echo "Error: This script is designed for Linux only."
    exit 1
fi

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "Error: This script must be run as root (use sudo)."
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Starting setup and installation for ZenithAFK Roblox AFK bot..."

# Update package lists
echo "Updating package lists..."
apt-get update

# Install system dependencies
echo "Installing system dependencies (git, wmctrl, xdotool, python3, python3-venv, wine, scrot, xorg, tightvncserver)..."
apt-get install -y git wmctrl xdotool python3 python3-venv wine scrot xorg tightvncserver

# Clone or update ZenithAFK repository
if [ ! -d "/home/umbrel/ZenithAFK" ]; then
    echo "Cloning ZenithAFK repository..."
    git clone https://github.com/TwilightOnSol/ZenithAFK.git /home/umbrel/ZenithAFK
    chown -R umbrel:umbrel /home/umbrel/ZenithAFK
    cd /home/umbrel/ZenithAFK
else
    echo "ZenithAFK directory already exists. Updating repository..."
    cd /home/umbrel/ZenithAFK
    su umbrel -c "git pull origin main" || {
        echo "Failed to update repository. Check your internet connection or branch name."
        read -p "Enter the branch name (default: main): " branch_name
        branch_name=${branch_name:-main}
        su umbrel -c "git pull origin $branch_name" || {
            echo "Error: Failed to update repository with branch '$branch_name'."
            exit 1
        }
    }
fi

# Create Python virtual environment
echo "Creating Python virtual environment..."
su umbrel -c "python3 -m venv /home/umbrel/ZenithAFK/venv"

# Install Python dependencies in virtual environment
echo "Installing Python dependencies in virtual environment..."
su umbrel -c "source /home/umbrel/ZenithAFK/venv/bin/activate && pip install pyautogui opencv-python numpy colorama requests"

# Check for required files
echo "Checking for required files..."
required_files=("ZenithAFK.py" "disconnect_button.png" "client_broke.png")
missing_files=0
for file in "${required_files[@]}"; do
    if [ ! -f "/home/umbrel/ZenithAFK/$file" ]; then
        echo "Error: Required file '$file' not found."
        missing_files=$((missing_files + 1))
    fi
done

if [ $missing_files -gt 0 ]; then
    echo ""
    echo "One or more required files are missing."
    echo "To fix missing image files (disconnect_button.png, client_broke.png):"
    echo "1. Start the VNC server: vncserver :1"
    echo "2. Connect to VNC (umbrel:1) using a VNC client (e.g., Remmina, VNC Viewer)."
    echo "3. Launch Roblox: wine ~/.wine/drive_c/Program Files (x86)/Roblox/Versions/RobloxPlayerBeta.exe"
    echo "4. Trigger a disconnect (e.g., disable internet briefly) or client error."
    echo "5. Capture screenshots using scrot:"
    echo "   scrot /home/umbrel/ZenithAFK/disconnect_button.png"
    echo "   scrot /home/umbrel/ZenithAFK/client_broke.png"
    echo "If ZenithAFK.py is missing, ensure it is included in the repository or use afk_bot.py."
    echo ""
    read -p "Continue despite missing files? (y/n): " continue_install
    if [ "$continue_install" != "y" ] && [ "$continue_install" != "Y" ]; then
        echo "Aborting installation."
        exit 1
    fi
fi

# Set up VNC server
echo "Setting up VNC server for graphical environment..."
if ! pgrep -x "Xtightvnc" > /dev/null; then
    echo "Starting VNC server on display :1..."
    su umbrel -c "vncserver :1 -geometry 1280x720 -depth 24" || {
        echo "Failed to start VNC server. Trying to kill existing sessions..."
        su umbrel -c "vncserver -kill :1" || true
        su umbrel -c "vncserver :1 -geometry 1280x720 -depth 24"
    }
else
    echo "VNC server already running."
fi

# Post-installation instructions
echo ""
echo "Setup and installation complete!"
echo "Next steps:"
echo "1. Ensure ZenithAFK.py, disconnect_button.png, and client_broke.png are in /home/umbrel/ZenithAFK."
echo "   - Check with: ls /home/umbrel/ZenithAFK"
echo "2. Update the ROBLOX_EXECUTABLE_LINUX path in ZenithAFK.py to point to your Roblox executable."
echo "   - Default: ~/.wine/drive_c/Program Files (x86)/Roblox/Versions/RobloxPlayerBeta.exe"
echo "   - Edit with: nano /home/umbrel/ZenithAFK/ZenithAFK.py"
echo "   - Verify path: ls -l ~/.wine/drive_c/Program\\ Files\\ \\(x86\\)/Roblox/Versions/RobloxPlayerBeta.exe"
echo "3. Install Roblox if not already installed:"
echo "   - Download RobloxPlayerLauncher.exe from the Roblox website."
echo "   - Run: wine RobloxPlayerLauncher.exe"
echo "4. Connect to the VNC server (umbrel:1) using a VNC client."
echo "5. Activate the virtual environment and run the bot:"
echo "   cd /home/umbrel/ZenithAFK"
echo "   source venv/bin/activate"
echo "   export DISPLAY=:1"
echo "   python3 ZenithAFK.py"
echo "6. Check logs for errors: cat /home/umbrel/ZenithAFK/afk_bot.log"
echo ""
echo "To stop the VNC server: vncserver -kill :1"
echo "If issues persist, provide the error output and contents of afk_bot.log."

exit 0