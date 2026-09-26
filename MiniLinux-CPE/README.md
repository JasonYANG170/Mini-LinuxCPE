# MiniLinux-CPE custom ImmortalWrt build

此目录为 MiniLinux-CPE 的独立设备支持：构建目标 `yang_minilinux-cpe`，
设备树 `mt7628an_yang_minilinux-cpe.dts`，板级标识 `yang,minilinux-cpe`。
上游 HLK-7628N 的设备树、型号和构建目标保留原始定义；构建时自动检查这一点。
PORT0 为 WAN，PORT1/2 为 LAN，PORT3/4 仅用于 TF 卡信号。

迁移后固件文件名包含 `yang_minilinux-cpe`。旧定制固件仍使用原板级标识，
因此升级校验可能拒绝新固件；首次迁移应先备份配置并通过 Breed 刷入匹配的固件，
不要把新设备标识作为所有原型号硬件的通用兼容声明。

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

- GPIO22-29: native MT7628 SDXC interface on the unused EPHY3/4 pads, with active-low card detect. `sdmode = sdxc` and `esd = iot` select the route; the board-specific `mediatek,ephy-digital-mask = <0x18>` switches only EPHY3/4 to digital mode. Ethernet ports 0/1/2 remain available by design; simultaneous operation still needs hardware validation.
- USB host: CH334P hub with EC200 cellular modem and USB storage.

CH334P 使用 Linux USB 核心内置的标准 Hub 驱动，不需要单独的 CH334P
软件包。固件同时启用 EHCI（USB 2.0 高速）、OHCI（全速/低速）和 MT7628
USB PHY，并包含 U 盘、USB 串口、Quectel Option、QMI、MBIM 与 NCM 驱动。
SDXC 设备树配置为 3.3 V、禁用 1.8 V 切换。`esd/iot` 只选择 SD 信号路由，
模拟/数字模式由 `AGPIO_CFG` 另外控制；不能仅凭 `sdmode` 判断实体管脚配置正确。
补丁 150 增加按物理端口选择数字模式的支持：掩码 `0x18` 对应 PORT3/4，
更新寄存器 bit19/20，并保持 PORT1/2 为模拟网口。不要使用把 PORT1–4
全部切为数字模式的 `ephy-digital;` 属性。此修复尚未编译、刷机或实机验证。
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

## SD PORT3/4 修复验证

2026-09-26 串口实测：旧固件 `AGPIO_CFG=0x00e001ff`，共享管脚仍为模拟模式；
重新绑定 SD 控制器不能消除初始化错误。用户确认 TF 使用 PORT3/4 对应管脚，
三个网口使用 PORT0/1/2。

已有构建目录若已应用旧版自定义补丁，请使用新的构建目录，例如：

```sh
BUILD_ROOT=/root/immortalwrt-MiniLinux-CPE-sd34 \
SOURCE_DIR=/root/immortalwrt-MiniLinux-CPE-sd34/source \
bash MiniLinux-CPE/build-wsl.sh
```

在验证固件上先检查：

```sh
cat /sys/kernel/debug/regmap/dummy-syscon@0x10000000/registers | grep -E '^(3c|60):'
dmesg | grep -iE 'mmc|sdhci|sdxc'
cat /proc/partitions
block info
```

对于本次实测的初始寄存器值，预期 `3c: 00f801ff`；关键是 bit19/20 为 1、
bit17/18 为 0，其余位按原值保留。确认出现 `mmcblk0` 及对应分区后，
逐一验证 PORT0/1/2 的协商和实际流量，并验证重启、重新插卡后的识别。
这只是管脚模式修复；exFAT 挂载仍需要单独的文件系统驱动。
