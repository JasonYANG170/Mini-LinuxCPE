# MT7628 串口刷入 Breed 

本文记录在 **MediaTek MT7628A** 上，通过串口升级功能刷入 Breed 的完整流程。

> [!WARNING]
> Bootloader 刷写失败可能导致设备无法启动，只能使用 SPI 编程器恢复。操作期间必须保证供电稳定，并确认镜像、芯片型号和 Flash 分区完全匹配。

## 1. 本次验证环境

| 项目 | 参数 |
|---|---|
| SoC | MediaTek MT7628AN |
| 内存 | 128 MB |
| Flash | Winbond W25Q256，32 MB |
| 串口 | COM26，57600，8N1，无流控 |
| Breed 镜像 | `breed-mt7688-reset38.bin` |
| Breed 版本 | 1.1 r1337，构建日期 2021-12-15 |

`breed-mt7688-reset38.bin` 是 MT7628AN/MT7688AN 通用版本：

- 串口波特率：57600
- 恢复键：GPIO#38
- Breed 默认管理地址：`192.168.1.1`


## 2. 准备工作

### 2.1 硬件连接

使用 3.3V TTL 串口连接模块 UART0：

| USB-TTL | HLK-7628N |
|---|---|
| TX | RX0 |
| RX | TX0 |
| GND | GND |

注意：

- TX 和 RX 需要交叉连接。
- 必须共地。
- 不要把 5V TTL 电平直接接入模块。
- 模块应使用稳定电源供电，不建议仅依靠 USB-TTL 的 3.3V 引脚供电。

串口参数：

```text
57600 baud
8 data bits
No parity
1 stop bit
No flow control
```

### 2.2 下载并校验 Breed

从 Breed 官方目录下载：

```text
https://breed.hackpascal.net/breed-mt7688-reset38.bin
```

文件信息：

```text
文件大小：90074 字节
MD5：CC80874B1B7363929661616B333B6F53
SHA-256：51F1C14CCA89AEACB3B47C1F7BC1507186E19A6E9904F666DA4287CE1740F373
```

Windows PowerShell 校验命令：

```powershell
Get-Item .\breed-mt7688-reset38.bin | Select-Object Name, Length
Get-FileHash .\breed-mt7688-reset38.bin -Algorithm MD5
Get-FileHash .\breed-mt7688-reset38.bin -Algorithm SHA256
```

如果文件大小或哈希不一致，不要继续刷写。

## 3. 检查板型和 Flash 分区

进入 OpenWrt 后执行：

```sh
ubus call system board
cat /proc/mtd
cat /proc/cmdline
```

设备输出为：

```text
model: HILINK HLK-7628N
system: MediaTek MT7628AN ver:1 eco:2

mtd0: 00030000 00010000 "u-boot"
mtd1: 00010000 00010000 "u-boot-env"
mtd2: 00010000 00010000 "factory"
mtd3: 01fb0000 00010000 "firmware"
```

其中：

- `mtd0` 是 Bootloader 分区。
- `mtd0` 大小为 `0x30000`，即 196608 字节。
- Breed 镜像为 90074 字节，可以放入该分区。
- 不要写入 `u-boot-env`、`factory` 或 `firmware` 分区。

## 4. 备份原 U-Boot

在 OpenWrt 中执行：

```sh
dd if=/dev/mtd0 of=/root/u-boot-before-breed.bin bs=65536
sync
ls -l /root/u-boot-before-breed.bin
sha256sum /root/u-boot-before-breed.bin
```

备份大小为 196608 字节。建议再通过 SCP、网页或其他可靠方式把备份复制到电脑上。

> [!IMPORTANT]
> `/root` 位于 OpenWrt overlay 中。若 Bootloader 刷坏，该备份不能代替外部 SPI 编程器上的离线备份。


## 6. 进入原 U-Boot

重启设备：

```sh
sync
reboot -f
```

启动时串口会显示类似菜单：

```text
Please choose the operation:
   1: Load system code to SDRAM via TFTP.
   2: Load system code then write to Flash via TFTP.
   3: Boot system code via Flash (default).
   4: Entr boot command line interface.
   7: Load Boot Loader code then write to Flash via Serial.
   9: Load Boot Loader code then write to Flash via TFTP.
```

### 方法 A：串口刷入

在倒计时结束前按数字 `7`：

```text
7: System Load Boot Loader then write to Flash via Serial.
## Ready for binary (kermit) download to 0x80100000 at 57600 bps...
```

此时 U-Boot 正在等待 Kermit 文件传输。

### 方法 B：TFTP 刷入

厂商升级文档主要介绍菜单 `9` 的 TFTP Bootloader 升级方式。如果已经配置好直连网线、电脑静态 IP 和 TFTP 服务器，也可以使用该方式。

串口方式不需要配置网络，因此本文使用菜单 `7`。

## 7. Windows 使用 Kermit 发送 Breed

U-Boot 的 `loadb` 使用 Kermit 协议。可以使用 Kermit 95、G-Kermit 或支持 Kermit 发送的终端软件。

本次使用开源的 [Kermit 95](https://github.com/davidrg/ckwin/releases)。

### 7.1 创建 Kermit 脚本

新建 `k95-send.ksc`，内容如下。根据实际串口号和文件路径修改：

```text
set modem type none
set line COM26
set speed 57600
set parity none
set flow none
set carrier-watch off
set file type binary
set protocol kermit
set window 1
set send packet-length 90
set receive packet-length 90
set block-check 1
set streaming off
set prefixing all
set retry 30
send C:/path/to/breed-mt7688-reset38.bin
exit
```

这些是偏保守的传输参数，适合旧版 Ralink U-Boot：

- 单窗口传输；
- 90 字节小数据包；
- 关闭流式发送；
- 转义全部控制字符；
- 提高重试上限。

旧 U-Boot 与 Kermit 95 默认的大包、滑动窗口参数可能不兼容，常见错误是：

```text
Protocol Error: Too many retries
```

### 7.2 开始发送

关闭 PuTTY、串口助手等占用 COM26 的程序，然后执行：

```powershell
& 'C:\path\to\k95.exe' 'C:\path\to\k95-send.ksc'
```

本次传输结果：

```text
complete, size: 90074
elapsed time: 26 seconds
```

传输过程中不要断电、拔串口或启动其他占用 COM26 的程序。

## 8. 擦写与重启

菜单 `7` 在接收完整 Bootloader 后会自动执行以下流程：

1. 将 Breed 接收到内存地址 `0x80100000`；
2. 校验接收结果；
3. 擦除 Bootloader Flash 区域；
4. 写入 Breed；
5. 重启设备。

不要在文件尚未完整接收时强制重启。若传输失败且显示 `0 Bytes`，通常尚未擦写，可以重新进入菜单 `7` 再传一次。

## 9. 验证 Breed

刷写成功并重启后，串口应显示：

```text
Boot and Recovery Environment for Embedded Devices
Copyright (C) 2021 HackPascal
Version 1.1 (r1337)

DRAM: 128MB
Platform: MediaTek MT7628AN/MT7688AN ver 1, eco 2
Flash: Winbond W25Q256 (32MB)
Network started on eth0, inet addr 192.168.1.1
```

这表示 Breed 已经正常执行。

如果仍能进入 OpenWrt，可以回读 Bootloader 前 90074 字节进行校验：

```sh
dd if=/dev/mtd0 bs=90074 count=1 2>/dev/null | sha256sum
```

正确结果应为：

```text
51f1c14cca89aeacb3b47c1f7bc1507186e19a6e9904f666da4287ce1740f373  -
```

## 10. 进入 Breed Web 恢复页面

1. 用网线把电脑连接到模块 LAN 口。
2. 将电脑 IPv4 地址临时设置为 `192.168.1.2`。
3. 子网掩码设置为 `255.255.255.0`。
4. 网关可以留空或设置为 `192.168.1.1`。
5. 按住与 GPIO#38 相连的复位键，再给模块上电。
6. 浏览器打开 `http://192.168.1.1/`。

进入 Breed 后，可以备份或更新固件、Bootloader、EEPROM/Factory 等区域。操作前务必再次确认目标分区。

## 11. 本次出现的 OpenWrt 启动问题

Breed 刷入成功后，尝试启动设备中原有 Kwrt 固件时出现：

```text
Trying to boot firmware from 0x00050000 in flash bank 0 ...
U-Boot firmware image header detected.
Uncompressing data (LZMA) ... ERROR: LzmaDecode.c, 534
Decoding error = 1
Starting breed built-in shell
breed>
```

进入 Breed Web 恢复页面，重新刷入适用于 `hilink_hlk-7628n` 的兼容固件。不要把 OpenWrt `sysupgrade.bin` 当作 Bootloader 写入，也不要再次写入 `u-boot` 分区。
