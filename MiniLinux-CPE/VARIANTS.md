# 固件版本

每次 CI 分别构建两个版本，均提供 initramfs-kernel.bin 和
squashfs-sysupgrade.bin，板型都是 yang_minilinux-cpe。

| 版本 | Linux SPI Flash 频率上限 |
| --- | --- |
| standard（标准版） | 10,000,000 Hz，保留原设置 |
| spi38m | 38,333,333 Hz |

spi38m 是频率上限，不是精确锁频。Linux 驱动按总线时钟向上取整分频；
当前设备日志中的总线时钟为 193,333,333 Hz，因此预计实际频率约为
32.22 MHz。不能将 Breed 下测得的 38.33 MHz 直接视为 Linux 实际频率。

这两种 OpenWrt 镜像均不修改 Breed。Breed 的启动读取频率需要另行设置，
刷入 spi38m 不能修复 Breed 默认频率下的 Flash 读取错误。

GitHub Actions 提供 firmware-standard 与 firmware-spi38m 两份产物。
Release 保留标准版散装文件，额外提供 MiniLinux-CPE-spi38m.zip；
压缩包内的 FIRMWARE_VARIANT 和 SHA256SUMS 可用于辨别版本和校验文件。
不要把 ZIP 文件直接上传到刷机界面，应先解压并选择适合刷写方式的镜像。

本地构建通过 FIRMWARE_VARIANT=standard 或 FIRMWARE_VARIANT=spi38m 选择。
不同版本必须使用独立、全新的 SOURCE_DIR 和 OUTPUT_DIR。
