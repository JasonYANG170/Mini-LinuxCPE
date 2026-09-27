# 固件版本

每次 CI 分别构建四个版本，均提供 initramfs-kernel.bin 和
squashfs-sysupgrade.bin，板型都是 yang_minilinux-cpe。

| 版本 | Linux SPI Flash 频率上限 |
| --- | --- |
| standard（标准版） | 10,000,000 Hz，保留原设置 |
| spi38m | 38,333,333 Hz |
| full（全功能版） | 10,000,000 Hz |
| full-spi38m（全功能限速版） | 38,333,333 Hz |

全功能版在标准版基础上增加 luci-app-partexp、luci-theme-argon、
luci-app-passwall（包含 Xray 核心和中文翻译）、dnsmasq-full、exFAT 驱动。
block-mount 已在所有版本中。Argon 和 PassWall 使用 ImmortalWrt 的 LuCI feed；
partexp 固定为 sirpdboy/luci-app-partexp 的提交
236187cfe4f1fab7f2dde5279ce378324c3e5f40。
受 32 MB Flash 限制，不包含其他可选代理核心和大型 GeoIP/GeoSite 数据包。
全功能不代表包含 PassWall 的全部可选协议实现；节点需要用户自行配置。
CI 检查所需软件包配置和最终 manifest，并确认两种镜像实际生成，
不会通过增大固件分区上限来绕过镜像体积限制。

spi38m 是频率上限，不是精确锁频。Linux 驱动按总线时钟向上取整分频；
当前设备日志中的总线时钟为 193,333,333 Hz，因此预计实际频率约为
32.22 MHz。不能将 Breed 下测得的 38.33 MHz 直接视为 Linux 实际频率。

这四种 OpenWrt 镜像均不修改 Breed。Breed 的启动读取频率需要另行设置，
刷入 spi38m 不能修复 Breed 默认频率下的 Flash 读取错误。

GitHub Actions 提供 firmware-standard、firmware-spi38m、firmware-full、
firmware-full-spi38m 四份产物。Release 保留标准版散装文件，并提供
MiniLinux-CPE-<版本名>.zip 四份压缩包；
压缩包内的 FIRMWARE_VARIANT 和 SHA256SUMS 可用于辨别版本和校验文件。
不要把 ZIP 文件直接上传到刷机界面，应先解压并选择适合刷写方式的镜像。

本地构建通过 FIRMWARE_VARIANT=standard、spi38m、full 或 full-spi38m 选择。
不同版本必须使用独立、全新的 SOURCE_DIR 和 OUTPUT_DIR。
