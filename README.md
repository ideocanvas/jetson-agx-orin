# Setup JETSON AGX ORIN 64GB GUIDE (NVMe SSD)

## Setup JETSON DEVICE FOR JETPACK 6.2.1

Prepare a host PC (AMD64) with Ubuntu 22.04 installed
Install Nvidia SDK Manager
Go to URL https://developer.nvidia.com/sdk-manager
Download the Linux package for 22.04
Install with command: sudo apt install ./sdkmanager_[version]-[build#]_amd64.deb

Go to URL: https://developer.nvidia.com/embedded/learn/getting-started-jetson
Select "Jetson AGX Orin Developer Kit" > "User Guide"
Read the "How-To" and "Hardware Layout" to figure out how to put the device into "Force Recovery Mode"
- Developer Kit already powered on
- Press and hold down the Force Recovery button ( 2 ).
- Press and hold down the Reset button ( 3 ).
- Release both buttons.

Start SDK Manager
Connect the JETSON device to the host PC

Make sure the JETSON is detected, then follow the instruction to setup the JETSON device.
High-level flow:
- Download packages and build OS image
- Flashing (it may prompt to select the correct JETSON device again, if not detected, reboot the device into recovery mode and connect the USB cable again)
  - You need to provide a new username and password for the JETSON device (please remember the password)
  - You need to select the correct instal location options "NVMe"

- Install Jetpack components (it use USB cable as JETSON device's ethernet)

After completed, connect keyboard, mouse and monitor to the JETSON device and start up the device.

## Install JETPACK 6.2.1

Go to URL: https://developer.nvidia.com/embedded/learn/get-started-jetson-agx-orin-devkit
Follow the secction "Issue the following commands to install JetPack components." to install the nvidia-jetpack

sudo apt update
sudo apt dist-upgrade
sudo reboot
sudo apt install nvidia-jetpack

## Futher setup steps

Go to URL: https://www.jetson-ai-lab.com/tutorial-intro.html
Select "Jetson Setup Guide"

### Docker

Select "🔖 SSD + Docker"

Skip the installation, follow the instruction to update user group and setup the default runtime.

sudo usermod -aG docker $USER

sudo apt install -y jq
sudo jq '. + {"default-runtime": "nvidia"}' /etc/docker/daemon.json | \
  sudo tee /etc/docker/daemon.json.tmp && \
  sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json

sudo systemctl daemon-reload && sudo systemctl restart docker

### Memory

Select "🔖 Memory optimization"

Follow the instruction to setup swap

sudo systemctl disable nvzramconfig
sudo fallocate -l 64G /mnt/64GB.swap
sudo chmod 0600 /mnt/64GB.swap
sudo mkswap /mnt/64GB.swap
sudo swapon /mnt/64GB.swap

Then add the following line to the end of /etc/fstab to make the change persistent:

/mnt/64GB.swap  none  swap  sw 0  0

## Install JTOP

sudo apt install python3-pip

sudo -H pip3 install -U jetson-stats

sudo systemctl restart jetson_stats.service

Then test the jtop command. If found it show Jetpack not detected, please follow the following steps

### Fix JTOP failed to detect Jectpack

Go to URL: https://my.cytron.io/tutorial/fixing-jtop-for-jetson-jetpack-6-2#:~:text=This%20tutorial%20walks%20you%20through%20diagnosing%20and%20fixing,cd%20jetson-jtop-patch%20chmod%20%2Bx%20apply_jtop_fix.sh%20.%2Fapply_jtop_fix.sh%20sudo%20reboot

Follow the instruction apply the fixing:

    git clone https://github.com/jetsonhacks/jetson-jtop-patch.git
    cd jetson-jtop-patch
    chmod +x apply_jtop_fix.sh
    ./apply_jtop_fix.sh


## Install conda

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
chmod +x Miniconda3-latest-Linux-aarch64.sh
./Miniconda3-latest-Linux-aarch64.sh

conda update conda

## Set the PIP_INDEX_URL

Check the jetpack version:
cat /etc/*release*

Go to https://pypi.jetson-ai-lab.io/
Find the correct index URL

Add the URL to ~/.bashrc

For example: Jetpack 6 CUDA 12.6
export PIP_INDEX_URL=https://pypi.jetson-ai-lab.io/jp6/cu126