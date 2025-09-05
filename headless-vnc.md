# Headless VNC Setup for Jetson AGX Orin

This guide provides step-by-step instructions for setting up headless VNC on your Jetson AGX Orin, allowing you to access the desktop environment remotely without a physical monitor connected.

## Overview

Headless VNC setup enables:
- Remote desktop access without a physical monitor
- Virtual display configuration for GUI applications
- Persistent desktop sessions
- Access to web interfaces and desktop applications from any device

**Reference:** Based on [Mauro Arcidiacono's Jetson Headless VNC Guide](https://mauroarcidiacono.github.io/jetson-headless-vnc/)

## Prerequisites

- Jetson AGX Orin with JetPack 6.2.1 installed
- SSH access to the device
- Network connectivity

## Step 1: Install VNC Server

Update the package list and install x11vnc:

```bash
sudo apt-get update
sudo apt-get install x11vnc
```

Set up a VNC password:

```bash
x11vnc -storepasswd
```

You'll be prompted to enter and confirm a password for VNC connections.

## Step 2: Create Virtual EDID (Extended Display Identification Data)

Download a sample EDID file for a 1920x1080 display:

```bash
wget https://raw.githubusercontent.com/linuxhw/EDID/refs/heads/master/Digital/Dell/DELF03C/F0E718A8BB64
```

Rename the downloaded file:

```bash
mv F0E718A8BB64 EDID.txt
```

Convert the EDID text file to binary format:

```bash
cat EDID.txt | grep -E '^([a-f0-9]{32}|[a-f0-9 ]{47})$' | tr -d '[:space:]' | xxd -r -p > EDID.bin
```

Create the firmware directory and copy the EDID file:

```bash
sudo mkdir -p /lib/firmware/edid
sudo cp EDID.bin /lib/firmware/edid/EDID.bin
```

## Step 3: Configure X11 for Virtual Display

Create or edit the X11 configuration file:

```bash
sudo nano /etc/X11/xorg.conf
```

Add the following configuration:

```
# Copyright (c) 2011-2013 NVIDIA CORPORATION.  All Rights Reserved.

#
# This is the minimal configuration necessary to use the Tegra driver.
# Please refer to the xorg.conf man page for more configuration
# options provided by the X server, including display-related options
# provided by RandR 1.2 and higher.

# Disable extensions not useful on Tegra.
Section "Module"
    Disable     "dri"
    SubSection  "extmod"
        Option  "omit xfree86-dga"
    EndSubSection
EndSection

Section "Device"
    Identifier  "Tegra0"
    Driver      "nvidia"
    Option      "PrimaryGPU" "Yes"
    Option      "AllowEmptyInitialConfiguration" "true"
    Option      "ConnectedMonitor" "DFP-0"
    Option      "CustomEDID" "DFP-0:/lib/firmware/edid/EDID.bin"
    Option      "UseDisplayDevice" "DFP-0"
    Option      "IgnoreEDIDChecksum" "DFP-0"
    Option      "AllowNonEdidModes" "true"
EndSection

Section "Monitor"
    Identifier "Monitor0"
    VendorName "FakeVendor"
    ModelName  "Fake1920x1080"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device     "Tegra0"
    Monitor    "Monitor0"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection
```

## Step 4: Enable Auto-Login

Configure automatic login to ensure the desktop environment starts without manual intervention:

1. Open the system settings or use the command line to enable auto-login
2. Set your user account to automatically log in at boot

## Step 5: Reboot and Test Display

Reboot the system to apply the X11 configuration:

```bash
sudo reboot
```

After reboot, test the virtual display:

```bash
DISPLAY=:0 xrandr
```

This should show the virtual 1920x1080 display.

## Step 6: Test VNC Connection

Start x11vnc manually to test:

```bash
x11vnc -usepw -forever -display :0
```

You should see output indicating the VNC server is running on port 5900.

## Step 7: Create VNC Service for Auto-Start

Create a systemd service file for automatic VNC startup:

```bash
sudo nano /etc/systemd/system/x11vnc.service
```

Add the following content (replace `ubuntu` with your actual username):

```ini
[Unit]
Description=Start x11vnc at startup
Requires=display-manager.service
After=display-manager.service

[Service]
Type=simple
User=ubuntu
ExecStart=/usr/bin/x11vnc -auth guess -display WAIT:0 -loop -usepw -forever -rfbport 5900
Restart=on-failure

[Install]
WantedBy=graphical.target
```

Enable and start the service:

```bash
sudo systemctl enable x11vnc.service
sudo systemctl daemon-reload
sudo systemctl restart x11vnc.service
```

Reboot to ensure everything starts automatically:

```bash
sudo reboot
```

## Step 8: Verify Service Status

After reboot, check that the VNC service is running:

```bash
systemctl status x11vnc.service
```

You should see the service as "active (running)".

## Connecting to VNC

### Connection Details
- **IP Address:** Your Jetson's IP address
- **Port:** 5900 (default VNC port)
- **Password:** The password you set with `x11vnc -storepasswd`
- **Resolution:** 1920x1080

### VNC Clients
- **Windows:** TightVNC, UltraVNC, RealVNC
- **macOS:** Built-in Screen Sharing, RealVNC
- **Linux:** Remmina, TigerVNC, RealVNC
- **Mobile:** VNC Viewer apps

### Example Connection
Using a VNC client, connect to:
```
<jetson-ip-address>:5900
```

## Troubleshooting

### VNC Service Not Starting
```bash
# Check service logs
journalctl -u x11vnc.service -f

# Restart the service
sudo systemctl restart x11vnc.service
```

### Display Issues
```bash
# Check X11 logs
sudo cat /var/log/Xorg.0.log

# Verify EDID file
ls -la /lib/firmware/edid/EDID.bin
```

### Connection Problems
```bash
# Check if VNC is listening
sudo netstat -tlnp | grep :5900

# Test local connection
vncviewer localhost:5900
```

### Performance Optimization
- Reduce color depth in VNC client settings for faster performance
- Use compression options in your VNC client
- Consider adjusting the virtual display resolution if needed

## Security Considerations

- Change the default VNC password regularly
- Consider using SSH tunneling for secure connections:
  ```bash
  ssh -L 5900:localhost:5900 user@jetson-ip
  ```
- Restrict VNC access to specific IP addresses using firewall rules
- Use VNC over VPN for external access

## Advanced Configuration

### Custom Resolution
To change the virtual display resolution, modify the `xorg.conf` file:
- Update the `Modes` line in the Display subsection
- Ensure the EDID file supports the desired resolution

### Multiple Virtual Displays
You can configure multiple virtual displays by adding additional Device and Screen sections to the `xorg.conf` file.

## Conclusion

Your Jetson AGX Orin is now configured for headless VNC access. You can remotely access the desktop environment, run GUI applications, and access web interfaces like ComfyUI without needing a physical monitor connected to the device.