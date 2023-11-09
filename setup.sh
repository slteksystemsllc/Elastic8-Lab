#!/bin/bash

# Define the log file
LOGFILE="/tmp/setup.log"

# Function to check the exit status of the last command
check_status() {
    description=$1
    status=$?
    if [ $status -eq 0 ]; then
        echo -e "\e[92mSuccess: $description\e[0m" | tee -a $LOGFILE
    else
        echo -e "\e[91mError: $description failed with status $status. Exiting.\e[0m" | tee -a $LOGFILE
        exit $status
    fi
}

# Function to echo remarks in blue color
echo_remark() {
    echo -e "\e[94m$1\e[0m" | tee -a $LOGFILE
}

# Check if Python3 is installed
if ! command -v python3 &> /dev/null
then
    echo_remark "Python3 could not be found, installing now..."
    sudo apt update && sudo apt install -y python3.9 |& tee -a $LOGFILE
    check_status "Python3 Installation"
fi

# Install open-vm-tools
echo_remark "Installing open-vm-tools..."
sudo apt-get install open-vm-tools-desktop -y |& tee -a $LOGFILE
check_status "Install open-vm-tools"

# Create labs directory in root and set ownership
echo_remark "Creating labs directory..."
sudo mkdir -p /labs |& tee -a $LOGFILE
check_status "Make Directory called Labs"
sudo chown $USER:$USER /labs |& tee -a $LOGFILE
check_status "Change ownership of Labs directory"

# Update sysctl.conf for vm.max_map_count
echo_remark "Updating sysctl.conf..."
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf |& tee -a $LOGFILE
sudo sysctl -p |& tee -a $LOGFILE
check_status "Update sysctl.conf"

# Update and upgrade system
echo_remark "Updating system..."
sudo apt update -y |& tee -a $LOGFILE
check_status "Update system"
sudo apt dist-upgrade -y |& tee -a $LOGFILE
check_status "Upgrade system"

# Install required packages
echo_remark "Installing required packages..."
sudo apt install gh openssh-server plocate net-tools git python3-pip jq bc curl gnupg nfs-common apt-transport-https ca-certificates software-properties-common lsb-release htop tree -y |& tee -a $LOGFILE
check_status "Install required packages"

# Allow SSH through UFW
echo_remark "Allowing SSH through UFW..."
sudo ufw allow ssh |& tee -a $LOGFILE
check_status "Allow SSH through UFW"

# Remove old repos and apps
echo_remark "Removing old repos and apps..."
sudo apt autoremove -y |& tee -a $LOGFILE
check_status "Remove old repos and apps"

# Configure Docker repository and Install Docker
echo_remark "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh |& tee -a $LOGFILE
sudo sh get-docker.sh |& tee -a $LOGFILE
check_status "Install Docker"

# Install Docker Compose
echo_remark "Installing Docker Compose..."
sudo apt-get install docker-compose-plugin -y |& tee -a $LOGFILE
check_status "Install Docker Compose"

# Enable and start Docker service
echo_remark "Enabling and starting Docker service..."
sudo systemctl enable docker |& tee -a $LOGFILE
check_status "Enable Docker service"
sudo systemctl start docker |& tee -a $LOGFILE
check_status "Start Docker service"

# Install VSCode
echo_remark "Installing VSCode..."
sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
check_status "Import Microsoft's GPG key"
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" -y
check_status "Add VSCode repository"
sudo apt update -y
check_status "Update system"
sudo apt install code -y
check_status "Install VSCode"

# Print VSCode version
vscode_version=$(code --version | head -n 1) |& tee -a $LOGFILE
echo_remark "VSCode version: $vscode_version"

# Uninstall SNAP Firefox
echo_remark "Uninstalling SNAP Firefox..."
sudo snap remove firefox |& tee -a $LOGFILE
check_status "Uninstall SNAP Firefox"

# Install Firefox (traditional deb package)
echo_remark "Installing Firefox..."
sudo add-apt-repository ppa:mozillateam/ppa -y
sudo apt update -y
sudo apt install firefox-esr -y |& tee -a $LOGFILE
check_status "Install Firefox"

# Log out and log back in to apply group changes
echo_remark "Please log out and log back in to apply group changes."

# Install Apache2
echo_remark "Installing Apache2..."
sudo apt install apache2 -y |& tee -a $LOGFILE
check_status "Install Apache2"

# Disable automatic updates
echo_remark "Disabling automatic updates..."
sudo systemctl disable --now unattended-upgrades.service |& tee -a $LOGFILE
check_status "Disable automatic updates"

# Disable IPv6
echo_remark "Disabling IPv6..."
echo "net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/99-sysctl.conf > /dev/null |& tee -a $LOGFILE
sudo sysctl -p /etc/sysctl.d/99-sysctl.conf |& tee -a $LOGFILE
check_status "Disable IPv6"

# Restart Network Manager after disabling IPV6 
echo_remark "Restarting NetworkManager..."
sudo systemctl restart NetworkManager |& tee -a $LOGFILE || check_status "Restarting NetworkManager.."

# Resart DNS resolver for good measure 
echo_remark "Restarting Resolved Service..."
sudo systemctl restart systemd-resolved.service |& tee -a $LOGFILE || check_status "Restarting NetworkManager.."

# Add user to the docker group
echo_remark "Adding user to the docker group..."
USER=$(whoami)
sudo usermod -aG docker $USER |& tee -a $LOGFILE
sudo systemctl restart docker
newgrp docker
check_status "Add user to docker group"

# Log out and log back in to apply group changes
echo_remark "Please log out and log back in to apply group changes."

# Script complete
echo_remark "Updates and install complete, check logfile located in /tmp directory called setup.log for details."
