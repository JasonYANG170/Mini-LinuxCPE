# 固件版本

每次 CI 构建 standard（标准版）和 full（全功能版），均提供 initramfs 和 sysupgrade 镜像。
两版沿用原有 Linux SPI Flash 10 MHz 上限，不再提供单独的频率版本。
固件不修改 Breed；Breed 启动阶段的 SPI 读取问题需要在引导器中处理。

全功能版增加 partexp、Argon、PassWall（Xray 核心和中文翻译）、dnsmasq-full、exFAT 驱动。
block-mount 已在所有版本中。Argon 和 PassWall 使用 ImmortalWrt 的 LuCI feed；
partexp 固定为 sirpdboy/luci-app-partexp 的提交 236187cfe4f1fab7f2dde5279ce378324c3e5f40。
受 32 MB Flash 限制，不包含其他可选代理核心和大型 GeoIP/GeoSite 数据包，节点需自行配置。
CI 检查配置和最终 manifest，并确认两种镜像实际生成，不增大固件分区上限。

全功能 initramfs 在 128 MB 内存设备上已观察到启动异常，怀疑与解包、复制到 tmpfs
时的空间或内存限制有关；长期安装使用 squashfs-sysupgrade.bin。

Actions 提供 firmware-standard 和 firmware-full 两份产物。
Release 保留标准版散装文件，同时提供 MiniLinux-CPE-standard.zip 和 MiniLinux-CPE-full.zip。
压缩包内的 FIRMWARE_VARIANT 和 SHA256SUMS 用于辨别版本和校验文件。
应先解压，再选择适合刷写方式的镜像。

本地构建通过 FIRMWARE_VARIANT=standard 或 full 选择。
不同版本必须使用独立、全新的 SOURCE_DIR 和 OUTPUT_DIR。
