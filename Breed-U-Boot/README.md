# Breed U-Boot

本目录保存 MT7628AN 串口救援与 Breed 刷写所需文件。

## 文件

- [`MT7628串口刷入Breed教程.md`](MT7628串口刷入Breed教程.md)：COM26、57600、8N1 环境下的完整刷写与验证步骤。
- `breed-mt7688-reset38.bin`：MT7628AN/MT7688AN Breed 镜像，复位键使用 GPIO38。

镜像信息：

| 项目 | 值 |
|---|---|
| 文件大小 | 90,074 bytes |
| SHA-256 | `51f1c14cca89aeacb3b47c1f7bc1507186e19a6e9904f666da4287ce1740f373` |
| Breed 串口波特率 | 57600 |
| Breed 默认管理地址 | `192.168.1.1` |

## 重要警告

Bootloader 刷错型号、写错 Flash 地址或写入过程中掉电，均可能导致设备无法启动，
届时通常只能拆机使用 SPI 编程器恢复。开始前务必核对教程中的 Flash 布局并完成备份。

该 `.bin` 不是 OpenWrt 固件，禁止通过 LuCI 的系统升级页面刷入。
