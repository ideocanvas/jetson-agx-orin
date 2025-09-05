https://mauroarcidiacono.github.io/jetson-headless-vnc/

sudo apt-get update
sudo apt-get install x11vnc
x11vnc -storepasswd

 wget https://raw.githubusercontent.com/linuxhw/EDID/refs/heads/master/Digital/Dell/DELF03C/F0E718A8BB64

 mv F0E718A8BB64 EDID.txt

cat EDID.txt | grep -E '^([a-f0-9]{32}|[a-f0-9 ]{47})$' | tr -d '[:space:]' | xxd -r -p > EDID.bin

sudo mkdir -p /lib/firmware/edid
sudo cp /tmp/EDID.bin /lib/firmware/edid/EDID.bin

/etc/X11/xorg.conf

# Copyright (c) 2011-2013 NVIDIA CORPORATION.  All Rights Reserved.

#
# This is the minimal configuration necessary to use the Tegra driver.
# Please refer to the xorg.conf man page for more configuration
# options provided by the X server, including display-related options
# provided by RandR 1.2 and higher.

# Disable extensions not useful on Tegra.
========================================
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
====================================

Enable Auto-Login, Reboot and Verify

Test:
DISPLAY=:0 xrandr

Test Start VNC:
x11vnc -usepw -forever -display :0

sudo nano /etc/systemd/system/x11vnc.service
Paste this inside and update the username field:

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

sudo systemctl enable x11vnc.service
sudo systemctl daemon-reload
sudo systemctl restart x11vnc.service
sudo reboot

systemctl status x11vnc.service