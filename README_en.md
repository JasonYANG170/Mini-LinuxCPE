[简体中文](README.md) | [English](README_en.md)

# Mini-LinuxCPE Router SDK

This is an ImmortalWrt 25.12-SNAPSHOT
custom firmware build project for Mini-LinuxCPE. Builds use a locally verified source commit and Linux 6.12.103.

# System adaptation

The router is adapted to OpenWRT ImmortalWrt 25.12-SNAPSHOT
Support Linux kernel 6.12.103

- Default hostname: `YANG-RouterOS`
- Equipment model: `MiniLinux-CPE`
- Firmware display name: `YANG-RouterOS`

| OpenWRT 25.12 Linux Kernel 6.12| Breed U-boot |
| --- | --- |
|![7c1a67f6f7ad758e5a9c905bf85bde93.jpg](https://image.lceda.cn/oshwhub/pullImage/79e944b359bd430fad4d9a6f793900ef.jpg)|![d91e4e891d665e680ba23cabdc63dfea.jpg](https://image.lceda.cn/oshwhub/pullImage/2c16707686ac40db9b7140207a2d942c.jpg)|


## Flash Breed-UBoot

> [!CAUTION]
> Bootloader flashing has the risk of bricking. Please back up the complete Flash, Factory/ART and EEPROM first.
> Verify that the device is indeed MT7628AN/MT7688AN, the serial port level is 3.3 V, and ensure that the power supply is stable during flashing.

- [View serial port flashing Breed complete tutorial](Breed-U-Boot/MT7628串口刷入Breed教程.md)
- [Breed-U-Boot file description and image check value](Breed-U-Boot/README.md)
- Image: `Breed-U-Boot/breed-mt7688-reset38.bin`

The Breed image is only for the Bootloader partition. **Never upload it as an OpenWrt sysupgrade image**.

## GitHub Actions builds

1. Open the **Actions** page of the repository.
2. Select **Build ImmortalWrt for MiniLinux-CPE**.
3. Click **Run workflow**.
4. Download the `YANG-RouterOS-1.0.0-MT7628-4G-CPE-kernel-6.12.103` artifact after the build is successful.
5. Use the image whose name in the artifact ends with `yang_minilinux-cpe-squashfs-sysupgrade.bin`.

MiniLinux-CPE now uses independent build target `yang_minilinux-cpe` and board level identification
`yang,minilinux-cpe`. Upstream HLK-7628N definitions remain original. When old custom firmware is first migrated,
Please refer to [Stand-alone device description](MiniLinux-CPE/README.md) to confirm the upgrade method.

## Local WSL validation

Execute in Ubuntu WSL:

```bash
bash MiniLinux-CPE/build-wsl.sh
```

The resulting firmware has built-in `yang-cpe-console` and
`luci-app-yang-cpe-console` 1.1.0. After flashing, open LuCI's
**Services → MiniLinux CPE** page to use gauges, resource and traffic charts, fan PWM
control, and EC200 status/configuration, without installing additional APKs.

## Fan Control

After flashing and booting successfully:

```sh
fanctl status
fanctl 0
fanctl 128
fanctl 255
```


## Hardware validation over serial

Confirmed via COM26 (57600, 8N1) on Linux 6.12.103 firmware:

- GPIO41/42/43 have entered the `p2led_an`, `p1led_an`, and `p0led_an` hardware multiplexing respectively.
- The switch LED mode `5` is Link/Activity, and the mode `12` can be used to force constant light diagnosis.
- The old default device name of GPIO44 `wlan0` does not exist in the current mac80211. This project has been changed to the measured device name `phy0-ap0`.
- The actual measurement of switch logical Port 0 can be negotiated to 100baseT full duplex, and has normal transmit and receive counts.
- SDXC uses GPIO22–29 (unused EPHY Port 3/4 pins). The new patch to be verified on the actual machine configures TF through `sdmode = sdxc`, `esd = iot` and port-based digital mode mask `0x18`, and reserves the Port 0/1/2 network port; only configuring `sdmode` is not enough to switch analog pins. See `MiniLinux-CPE/README.md` for details.

# Finished product display
| Front | Interior |
| --- | --- |
|![55d02288c010fed076bd289bb4af9c3c.jpg](https://image.lceda.cn/oshwhub/pullImage/3244ce4f27b842e8a6e5b5b8cd180766.jpg)|![ef5bb61245d1315190dbf52053799b59.jpg](https://image.lceda.cn/oshwhub/pullImage/92390fc6341d498b88f7a08ab8136f28.jpg)|






## Features
- ✅Support OpenWRT 25.12 system
- ✅Support Linux Kernel 6.12 kernel
- ✅Support 3X100M wired interface
- ✅Support 2.4GH 40MHz bandwidth
- ✅Supports 802.11n mode up to 300Mbps
- ✅Supports TF card/USB extended storage
- 🚧OLED screen data display (planned to adapt to SSD1362 160*64 screen)

If you encounter any problems, please submit issues to me

## Project parameters
* This project uses MediaTek MT7628 chip to realize wireless routing function;
* This project uses Quectel EC200 4G module to achieve 4G signal reception function;
* This project uses Qinheng CH334p chip to realize USB device connection

## Open Source Agreement
This project follows the CC BY-NC-SA 4.0 open source agreement. When using this program, please indicate the source and make a copyright statement.
This project is for study and research only, and unauthorized commercial profits are strictly prohibited.
If you have better suggestions, please PR

## Actual picture

| PCB front | PCB back |
| --- | --- |
|![bcd2555e52877d8d69233d5921827625.jpg](https://image.lceda.cn/oshwhub/pullImage/ae385424c6e44543bd8d39ab2799ada5.jpg)|![fbbc196dcc839f75e37966b85f570939.jpg](https://image.lceda.cn/oshwhub/pullImage/2042319566c14a4191aa70e113fd3a60.jpg)|
| Shell | Complete product |
|![fb753eea4a7ee68c1100ae98cb5186fa.jpg](https://image.lceda.cn/oshwhub/pullImage/cf87679824ec4201a932adaa8c32fbc3.jpg)|![e26c371cfde8e4c45cf90c47002376c6.jpg](https://image.lceda.cn/oshwhub/pullImage/1a7dc7ac60384b449b4af9bf0409ce2e.jpg)|





