# Installing Fedora F18 on HP Touchpad
1. Put device in developer mode (if not done already), by typing **webos20090606** or **upupdowndownleftrightleftrightbastart** in the "Just Type" text box, and launch the developer-mode app.  You turn it on and your device should be in developer mode. If it requests a password you may just press submit.
2. Install novacom on your host desktop/laptop:
  * if your host is fedora, `sudo yum install novacom`.. and then `sudo novacomd` to launch the server.
  * From there, you can use `novaterm` command to connect to the device or `novacom` to transfer files.
3. Install adb on your host.. you will need this later
  * for fedora, `sudo yum install android-tools`
  * if you get permission errors when adb tries to spawn the server, `adb kill-server` and then `sudo adb start-server`
3. run: ./create-partition.sh _size_
  * for example on a 32GB device if you want to create a 20GB linux partition:
     `./create-partition.sh 20480`
  * this step can take quite a while
4. run: ./install-boot.sh
   this will install moboot bootloader and kernel
5. run: ./install-rootfs.sh
   this will install the root filesystem, and then reboot.
6. At the moboot screen, use the volume rocker switch to select whether to boot webOS or fedora
7. Once fedora has booted, you can use `adb shell` to connect to the device.
  * `export TERM=xterm` and `/usr/bin/resize` to get a semi-sane console
8. rndis is enabled, so you should see a new wired connection in network manager.  To allow network access over usb/adb, in network manager IPv4 settings, select: Method: Shared to other computers
  * at this point, you could enable sshd in order to connect to the touchpad over ssh

TODO:
- [ ] wifi patch: https://github.com/TouchpadCM/compat-wireless-3.3-rc1-2/commit/4f92acb42c210e08ff20853d82afdacf7da28354
- [x] touchscreen
- [ ] gnome-shell
- [ ] re-enable android ram-console in kernel config..  it is quite useful for debugging crashes, but seems to be causing some memory corruption itself

