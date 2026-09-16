# HLK-7628N custom ImmortalWrt build

固件构建会固定拉取 `MiniLinux-CPE_OpenWRT_Console` 的已验证源码提交，
并把 `yang-cpe-console` 与 `luci-app-yang-cpe-console` 直接编入镜像。
首次启动后可在 LuCI 的“服务 → MiniLinux CPE”打开实时数据看板，
无需再手工上传或安装 APK。

Pinned sources:

- ImmortalWrt source: branch `openwrt-25.12`, commit `3a0f609352e0b582fc670af865ad449a65b18e62`.
- Kernel: `6.12.103`.

System identity:

- Hostname: `YANG-RouterOS`.
- Model: `MiniLinux-CPE`.
- Displayed firmware name: `YANG-RouterOS` (the internal `1.0.0` version remains available for artifact traceability).

Hardware configuration:

- GPIO22-29: native MT7628 SDXC/SDIO interface using the `sdmode` pin group, with active-low card detect. Do not enable the `esd`/`iot` mux: it converts EPHY ports 1-4 into digital SDXC pads.
- USB host: CH334P hub with EC200 cellular modem and USB storage.

CH334P 使用 Linux USB 核心内置的标准 Hub 驱动，不需要单独的 CH334P
软件包。固件同时启用 EHCI（USB 2.0 高速）、OHCI（全速/低速）和 MT7628
USB PHY，并包含 U 盘、USB 串口、Quectel Option、QMI、MBIM 与 NCM 驱动。
SDXC 固定使用 3.3 V，禁用 1.8 V 切换；构建脚本会拒绝任何会把 EPHY
Port 1–4 改作数字 SDXC 引脚的 `esd/iot` 配置。
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
