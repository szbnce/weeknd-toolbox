# Nokia 2780 hacking toolbox

This small Linux system replaces the stock "recovery" system and lets you expose
the internal storage of a Nokia 2780 (and maybe also 2760) Flip via USB.

It uses [lk2nd](https://github.com/msm8916-mainline/lk2nd) and a
close-to-mainline kernel:
<https://github.com/affenull2345/linux/tree/wip/qm215/6.3-rc7>

### Building

#### Requirements: TODO

To download and build all components, run:

```sh
CROSS_COMPILE=aarch64-linux-gnu- TOOLCHAIN_PREFIX=arm-none-eabi- ./build.sh
```

You can optionally set the JOBS environment variable to the number of make jobs
to use for building the Linux kernel.

### Booting
After building, you can run `./flash.sh` to boot the hacking toolbox.
This script permanently modifies the recovery partition by installing lk2nd
to it.

To boot the hacking toolbox, hold the volume-up key while turning on the
phone, then release it when the "custom operating system" warning appears, and
start holding the key again as soon as the warning disappears.

# Sideloading guide

### Preparation (only once)
- Perform the above steps to build and flash the toolkit
- Select "Disable encryption" and follow the on-screen instructions
- **WARNING**: Disabling encryption modifies the vendor partition. Please
  make a backup first using `dd` after exposing it via USB **without**
  mounting it.

### Sideloading apps

```sh
# Boot the hacking toolbox
# Select "USB storage" -> "userdata"
# Mount the exposed storage device on a Linux machine
# You might have to execute these commands as root to avoid permission errors
cd /path/to/userdata/

# If you have installed the app in the KaiOS simulator:
cp -r /path/to/kaiosrt/gaia/profile/webapps/installed/<app-name> local/webapps/installed
# Otherwise:
mkdir local/webapps/installed/<app-name>
cp /path/to/application.zip local/webapps/installed/<app-name>/

# Symlink the application directory
ln -s /data/local/webapps/installed/<app-name> local/webapps/vroot/<app-name>

# Ensure that the SELinux contexts are correct
setfattr -n security.selinux -v u:object_r:system_data_file:s0 local/webapps/installed/<app-name>
setfattr -n security.selinux -v u:object_r:system_data_file:s0 local/webapps/installed/<app-name>/application.zip
setfattr -h -n security.selinux -v u:object_r:system_data_file:s0 local/webapps/vroot/<app-name>

# Open the database:
sqlite3 local/webapps/db/apps.sqlite

sqlite> INSERT INTO apps VALUES ("<app-name>", "<version>", 1,
                                 "http://<app-name>.localhost/manifest.webmanifest",
                                 "", "", 0,
                                 "Enabled",
                                 "Installed",
                                 "Idle",
                                 0, 0, "", "", "");
sqlite> .exit

# Eject the storage device
# Power off and power on
```

# Known issues

- The font is ugly. Workaround: remove `fbcon=font:10x18` from cmdline
  in `build.sh`
