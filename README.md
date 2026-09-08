# Mini-LinuxCPE路由器 SDK

这是面向 Mini-LinuxCPE 的 ImmortalWrt 25.12-SNAPSHOT
定制构建项目。构建固定到经过本地验证的源码提交，并使用 Linux 6.12.103。

# 系统适配

路由器已适配OpenWRT ImmortalWrt 25.12-SNAPSHOT 
支持Linux内核6.12.103

| OpenWRT 25.12 Linux Kernel 6.12| Breed U-boot |
| --- | --- |
|![7c1a67f6f7ad758e5a9c905bf85bde93.jpg](https://image.lceda.cn/oshwhub/pullImage/79e944b359bd430fad4d9a6f793900ef.jpg)|![d91e4e891d665e680ba23cabdc63dfea.jpg](https://image.lceda.cn/oshwhub/pullImage/2c16707686ac40db9b7140207a2d942c.jpg)|


## 刷入 Breed-UBoot 

> [!CAUTION]
> Bootloader 刷写有变砖风险。请先备份完整 Flash、Factory/ART 与 EEPROM，
> 核对设备确为 MT7628AN/MT7688AN、串口电平为 3.3 V，并保证刷写期间供电稳定。

- [查看串口刷入 Breed 完整教程](Breed-U-Boot/MT7628串口刷入Breed教程.md)
- [Breed-U-Boot 文件说明与镜像校验值](Breed-U-Boot/README.md)
- 镜像：`Breed-U-Boot/breed-mt7688-reset38.bin`

Breed 镜像仅用于写入 Bootloader 分区，**绝不能作为 OpenWrt sysupgrade 镜像上传**。

## GitHub Actions 构建

1. 打开仓库的 **Actions** 页面。
2. 选择 **Build ImmortalWrt for HLK-7628N**。
3. 点击 **Run workflow**。
4. 构建成功后下载 `YANG-RouterOS-1.0.0-MT7628-4G-CPE-kernel-6.12.103` artifact。
5. 使用 artifact 内名称含 `yang-routeros-1.0.0-ramips-mt76x8-squashfs-sysupgrade.bin` 的镜像。

## 本地 WSL 验证

Ubuntu WSL 中执行：

```bash
bash custom-hlk7628/build-wsl.sh
```

## 风扇控制

刷机并启动成功后：

```sh
fanctl status
fanctl 0
fanctl 128
fanctl 255
```


## 串口实机验证

在 Linux 6.12.103 固件上通过 COM26（57600、8N1）确认：

- GPIO41/42/43 已分别进入 `p2led_an`、`p1led_an`、`p0led_an` 硬件复用。
- 交换机 LED 模式 `5` 为 Link/Activity，模式 `12` 可用于强制常亮诊断。
- GPIO44 的旧默认设备名 `wlan0` 在当前 mac80211 中不存在，本项目已改为实测设备名 `phy0-ap0`。
- 交换机逻辑 Port 0 实测可协商至 100baseT 全双工，并有正常收发计数。
- SDXC 必须只使用 GPIO22–29 的 `sdmode` 复用；`esd = iot` 会禁用 EPHY Port 1–4，本项目已移除该错误配置。

# 成品展示
| 正面 | 内部 |
| --- | --- |
|![55d02288c010fed076bd289bb4af9c3c.jpg](https://image.lceda.cn/oshwhub/pullImage/3244ce4f27b842e8a6e5b5b8cd180766.jpg)|![ef5bb61245d1315190dbf52053799b59.jpg](https://image.lceda.cn/oshwhub/pullImage/92390fc6341d498b88f7a08ab8136f28.jpg)|






## 功能
- ✅支持OpenWRT 25.12系统
- ✅支持Linux Kernel 6.12内核
- ✅支持3X100M有线接口
- ✅支持2.4GH 40MHz带宽
- ✅支持802.11n 模式下可达到最高的 300Mbps
- ✅支持TF卡/USB扩展存储
- 🚧OLED屏幕数据显示（计划适配SSD1362 160*64屏幕）

如遇问题，请向我提出issues

## 项目参数
* 本项目采用 联发科MT7628芯片，以实现无线路由功能；
* 本项目采用 移远通信EC200 4G模组,以实现4G信号接收功能；
* 本项目采用 沁恒CH334p 芯片,以实现USB设备连接

## 开源协议
本项目遵循CC BY-NC-SA 4.0开源协议，使用本程序时请注明出处并进行版权声明  
本项目仅供学习研究，严禁非授权的商业获利，  
如果您有更好的建议，欢迎PR

## 实物图

| PCB正面 | PCB背面 |
| --- | --- |
|![bcd2555e52877d8d69233d5921827625.jpg](https://image.lceda.cn/oshwhub/pullImage/ae385424c6e44543bd8d39ab2799ada5.jpg)|![fbbc196dcc839f75e37966b85f570939.jpg](https://image.lceda.cn/oshwhub/pullImage/2042319566c14a4191aa70e113fd3a60.jpg)|
| 外壳 | 完整成品 |
|![fb753eea4a7ee68c1100ae98cb5186fa.jpg](https://image.lceda.cn/oshwhub/pullImage/cf87679824ec4201a932adaa8c32fbc3.jpg)|![e26c371cfde8e4c45cf90c47002376c6.jpg](https://image.lceda.cn/oshwhub/pullImage/1a7dc7ac60384b449b4af9bf0409ce2e.jpg)|





