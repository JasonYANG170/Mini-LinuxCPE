# HLK-7628N custom ImmortalWrt build

Pinned sources:

- ImmortalWrt source: branch `openwrt-25.12`, commit `3a0f609352e0b582fc670af865ad449a65b18e62`.
- Kernel: `6.12.103`.

Hardware configuration:

- GPIO22-29: native MT7628 SDXC/SDIO interface, active-low card detect.
- USB host: CH334P hub with EC200 cellular modem and USB storage.
- GPIO46: WNM6002 N-MOS fan gate, exposed through `pwm-fan` at 100 Hz.
- GPIO4/5: native I2C controller for an SSD1362 160x64 display.
- GPIO43/42/41: native active-low switch LED outputs for ports 0/1/2.

The SSD1362 does not have a native Linux 6.12 DRM/fbdev driver in this tree.
The image therefore enables the hardware I2C controller and includes
`i2c-tools`; a display application can access it through `/dev/i2c-*`.

Fan commands after boot:

```sh
fanctl status
fanctl 0
fanctl 128
fanctl 255
```

The persistent default is stored in `/etc/config/board-hardware`.

The build includes LuCI, SD/MMC, USB mass storage, USB serial/option, and
CDC Ethernet/NCM/MBIM/RNDIS/QMI support. The EC200 operating mode still has
to match the selected LuCI protocol and its USB composition.
