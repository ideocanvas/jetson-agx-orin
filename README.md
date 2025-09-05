# Setting Up Your Jetson AGX Orin 64GB with JetPack 6.2.1 and NVMe SSD

This guide provides a comprehensive walkthrough for setting up a Jetson AGX Orin 64GB Developer Kit. It covers the initial flashing of the device with JetPack 6.2.1 using an NVMe SSD for storage, as well as subsequent software installation and configuration.

## 1. Initial Device Setup with JetPack 6.2.1

This section details the process of flashing your Jetson device with the latest JetPack software using the NVIDIA SDK Manager.

**Prerequisites:**

*   A host computer running Ubuntu 22.04 (AMD64 architecture).
*   The Jetson AGX Orin 64GB Developer Kit.
*   A USB-C cable to connect the Jetson device to the host PC.

**Steps:**

1.  **Install NVIDIA SDK Manager:**
    *   Navigate to the [NVIDIA SDK Manager website](https://developer.nvidia.com/sdk-manager).
    *   Download the `.deb` package for Ubuntu 22.04.
    *   Install the package using the following command in your terminal:
        ```bash
        sudo apt install ./sdkmanager_[version]-[build#]_amd64.deb
        ```

2.  **Enter Force Recovery Mode:**
    *   Familiarize yourself with the hardware layout by consulting the "How-To" and "Hardware Layout" sections of the [Jetson AGX Orin Developer Kit User Guide](https://developer.nvidia.com/embedded/learn/getting-started-jetson).
    *   With the developer kit powered on, press and hold the Force Recovery button.
    *   While holding the Force Recovery button, press and release the Reset button.
    *   Release the Force Recovery button.

3.  **Flash the Jetson Device:**
    *   Launch the NVIDIA SDK Manager.
    *   Connect the Jetson AGX Orin to your host PC via the USB-C port.
    *   The SDK Manager should automatically detect the device. Follow the on-screen instructions.
    *   **High-level flow:**
        *   The SDK Manager will download the necessary packages and build the OS image.
        *   During the flashing process, you may be prompted to select the Jetson device again. If it's not detected, reboot the device into recovery mode and reconnect the USB cable.
        *   You will be asked to create a new username and password for the Jetson device. **Remember these credentials.**
        *   Crucially, when prompted for the installation location, select **"NVMe"** to install the operating system on your SSD.
        *   After the initial flash, the SDK Manager will install the remaining JetPack components. This process utilizes the USB cable connection to function as an Ethernet connection for the Jetson device.

4.  **First Boot:**
    *   Once the installation is complete, disconnect the Jetson from the host PC.
    *   Connect a keyboard, mouse, and monitor to the Jetson AGX Orin and power it on.

## 2. Installing JetPack Components

After the initial setup, you need to install the core JetPack packages on the Jetson device itself.

1.  Open a terminal on your Jetson AGX Orin.
2.  Update the package lists and upgrade existing packages:
    ```bash
    sudo apt update
    sudo apt dist-upgrade
    ```
3.  Reboot the system:
    ```bash
    sudo reboot
    ```
4.  Install the `nvidia-jetpack` meta-package:
    ```bash
    sudo apt install nvidia-jetpack
    ```

## 3. Further System Configuration

This section covers additional setup steps to optimize your Jetson AGX Orin for AI development. For more detailed tutorials, visit the [Jetson AI Lab](https://www.jetson-ai-lab.com/tutorial-intro.html).

### Docker Setup

Configure Docker to use the NVIDIA runtime by default.

1.  **Add User to Docker Group:**
    ```bash
    sudo usermod -aG docker $USER
    ```
    You will need to log out and log back in for this change to take effect.

2.  **Set Default Runtime:**
    ```bash
    sudo apt install -y jq
    sudo jq '. + {"default-runtime": "nvidia"}' /etc/docker/daemon.json | \
      sudo tee /etc/docker/daemon.json.tmp && \
      sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json
    ```

3.  **Restart Docker Service:**
    ```bash
    sudo systemctl daemon-reload && sudo systemctl restart docker
    ```

### Memory Optimization (Swap File)

Create a swap file to increase the available virtual memory, which is beneficial for memory-intensive applications.

1.  **Disable ZRAM:**
    ```bash
    sudo systemctl disable nvzramconfig
    ```

2.  **Create a 64GB Swap File:**
    ```bash
    sudo fallocate -l 64G /mnt/64GB.swap
    sudo chmod 0600 /mnt/64GB.swap
    sudo mkswap /mnt/64GB.swap
    sudo swapon /mnt/64GB.swap
    ```

3.  **Make the Swap File Permanent:**
    Add the following line to the end of your `/etc/fstab` file to ensure the swap file is mounted on boot:
    ```
    /mnt/64GB.swap  none  swap  sw 0  0
    ```

## 4. System Monitoring with JTOP

`jtop` is a useful command-line tool for monitoring the status and resource usage of your Jetson device.

1.  **Install pip:**
    ```bash
    sudo apt install python3-pip
    ```

2.  **Install jetson-stats:**
    ```bash
    sudo -H pip3 install -U jetson-stats
    ```

3.  **Restart the Service:**
    ```bash
    sudo systemctl restart jetson_stats.service
    ```

### Fixing JTOP for JetPack 6.2.1

If `jtop` fails to detect your JetPack version, apply the following patch.

1.  **Clone the Patch Repository:**
    ```bash
    git clone https://github.com/jetsonhacks/jetson-jtop-patch.git
    ```

2.  **Apply the Fix:**
    ```bash
    cd jetson-jtop-patch
    chmod +x apply_jtop_fix.sh
    ./apply_jtop_fix.sh
    ```

3.  **Reboot:**
    ```bash
    sudo reboot
    ```
    After rebooting, you should be able to run the `jtop` command successfully.

## 5. Installing Conda for Python Environment Management

Conda is a popular package and environment manager that simplifies the process of installing and managing software libraries.

1.  **Download the Miniconda Installer:**
    ```bash
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
    ```

2.  **Make the Installer Executable:**
    ```bash
    chmod +x Miniconda3-latest-Linux-aarch64.sh
    ```

3.  **Run the Installer:**
    ```bash
    ./Miniconda3-latest-Linux-aarch64.sh
    ```
    Follow the on-screen prompts to complete the installation. It is recommended to allow the installer to initialize Conda in your shell.

4.  **Update Conda:**
    Open a new terminal or source your `.bashrc` file, then run:
    ```bash
    conda update conda
    ```

## 6. Configuring pip for Jetson-Optimized Packages

To ensure you are installing Python packages that are optimized for the Jetson platform, you should set the `PIP_INDEX_URL` environment variable.

1.  **Check Your JetPack Version:**
    ```bash
    cat /etc/*release*
    ```

2.  **Find the Correct Index URL:**
    *   Go to [https://pypi.jetson-ai-lab.io/](https://pypi.jetson-ai-lab.io/).
    *   Locate the index URL that corresponds to your JetPack and CUDA versions. For example, for JetPack 6 and CUDA 12.6, the URL is `https://pypi.jetson-ai-lab.io/jp6/cu126`.

3.  **Add the URL to your `~/.bashrc`:**
    Open your `~/.bashrc` file in a text editor and add the following line, replacing the URL with the one you identified in the previous step:
    ```bash
    export PIP_INDEX_URL=https://pypi.jetson-ai-lab.io/jp6/cu126
    ```

4.  **Apply the Changes:**
    Open a new terminal or run `source ~/.bashrc` for the changes to take effect.