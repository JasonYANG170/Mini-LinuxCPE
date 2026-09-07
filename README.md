# MT7628 4G CPE 定制固件

这是面向 HILINK HLK-7628N（MT7628AN）的 ImmortalWrt 25.12-SNAPSHOT
定制构建项目。构建固定到经过本地验证的源码提交，并使用 Linux 6.12.103。

## MT7628 串口刷入 Breed 教程入口

> [!CAUTION]
> Bootloader 刷写有变砖风险。请先备份完整 Flash、Factory/ART 与 EEPROM，
> 核对设备确为 MT7628AN/MT7688AN、串口电平为 3.3 V，并保证刷写期间供电稳定。

- [查看 COM26（57600）串口刷入 Breed 完整教程](Breed-U-Boot/MT7628串口刷入Breed教程.md)
- [Breed-U-Boot 文件说明与镜像校验值](Breed-U-Boot/README.md)
- 教程配套镜像：`Breed-U-Boot/breed-mt7688-reset38.bin`

Breed 镜像仅用于写入 Bootloader 分区，**绝不能作为 OpenWrt sysupgrade 镜像上传**。

## 硬件映射

- GPIO22/23/24/25/26/28/29/27：SD_WP、SD_CD、SD_D1、SD_D0、SD_CLK、SD_CMD、SD_D3、SD_D2。
- USB Host：连接 CH334P Hub，供 EC200 4G 模块与 U 盘使用。
- GPIO46：连接 WNM6002 N-MOS 栅极，通过 `pwm-gpio` 与 `pwm-fan` 调速。
- GPIO4/5：硬件 I2C SCL/SDA，连接 SSD1362 160x64 屏幕。
- GPIO43/42/41：分别复用为 MT7628 `p0led_an`、`p1led_an`、`p2led_an`，由交换机硬件驱动 Port 0/1/2 链路/活动灯。

SSD1362 在本分支的 Linux 6.12 中没有可直接使用的原生 DRM/fbdev 驱动，
因此固件先提供硬件 I2C 与 `i2c-tools`；显示内容需要后续用户态程序驱动。

## GitHub Actions 构建

1. 打开仓库的 **Actions** 页面。
2. 选择 **Build ImmortalWrt for HLK-7628N**。
3. 点击 **Run workflow**。
4. 构建成功后下载 `YANG-RouterOS-1.0.0-MT7628-4G-CPE-kernel-6.12.103` artifact。
5. 使用 artifact 内名称含 `hilink_hlk-7628n-squashfs-sysupgrade.bin` 的镜像。

推送 `.github/workflows/build-hlk7628.yml` 或 `custom-hlk7628/` 下的变更也会自动触发构建。

固件品牌字段为 `YANG-RouterOS 1.0.0 / MT7628-4G-CPE / YANG-OS v1`。

## 本地 WSL 验证

Ubuntu WSL 中执行：

```bash
bash custom-hlk7628/build-wsl.sh
```

产物写入 `output/`，同时生成 `SHA256SUMS` 和完整 `.config`。源码提交、
补丁、软件包及硬件操作说明见 [`custom-hlk7628/README.md`](custom-hlk7628/README.md)。

## 风扇控制

刷机并启动成功后：

```sh
fanctl status
fanctl 0
fanctl 128
fanctl 255
```

首次刷写前请备份原厂 ART/Factory、EEPROM 和完整 Flash。不要把 Breed/U-Boot
文件当作 sysupgrade 固件上传。

## 参考项目

- [JasonYANG170/JDCloud-AX6000-OpenWRT](https://github.com/JasonYANG170/JDCloud-AX6000-OpenWRT)
- [kiddin9/Kwrt](https://github.com/kiddin9/Kwrt)
- [xinlingduyu/build-openwrt](https://github.com/xinlingduyu/build-openwrt)
- [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt)
