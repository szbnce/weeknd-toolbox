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
