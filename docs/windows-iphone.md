# Windows → iPhone（待实机验证）

**Windows 不编译本仓库的 Swift 源码，也不能直接把下载的 IPA 拷进手机运行。** 此路径使用已经在 Mac 上编译好的 IPA，由 Sideloadly 按你的 Apple 账号重新签名后安装。

准备：Windows 10/11、自己的 Apple 账号、iOS 26+ iPhone、数据线。

## 第一次安装

1. 下载整个仓库 ZIP 并解压，找到 `downloads/RestTimer-resign-required.ipa`。不要解压 IPA，也不要把源码 ZIP 当作 IPA。
2. 从 [sideloadly.io](https://sideloadly.io/) 下载 Windows 版 Sideloadly；按官网说明安装所需 Apple 驱动、iTunes / iCloud 组件。本文不附带第三方安装器。
3. 连接并解锁 iPhone，在手机上点击「信任此电脑」。确认 Sideloadly 的设备列表能显示你的手机。
4. 将 IPA 拖进 Sideloadly，选择你的 iPhone，填写**你自己的 Apple 账号**，点击 Start，按提示在本机完成登录和验证。
5. 如果出现移除 App Extensions / PlugIns（应用扩展）的选项，不要移除。本包包含灵动岛所需的 `RestActivity.appex`；如果工具无法保留并正确重签扩展，本路径不能算完整成功，请改用 Mac 安装或反馈具体错误。
6. 按提示在手机开启 设置 → 隐私与安全性 → 开发者模式，并重启确认。再到 设置 → 通用 → VPN 与设备管理，信任用于安装的账号。
7. 打开「组间」，允许通知。设 30 秒开始计时，退到主屏幕看灵动岛，再检查锁屏通知。最后按 [验收清单](verification.md) 测试操作按钮。

Apple 账号密码只在你自己安装并信任的工具/系统登录流程中输入，不需要发给项目作者。Sideloadly 是第三方工具，其兼容性和服务状态以官方版本为准。

## 可选：下载校验

可在 PowerShell 中切换到仓库目录运行：

```powershell
powershell -NoProfile -File .\scripts\verify-ipa-windows.ps1
```

如果本机策略不允许运行脚本，不用修改策略；可直接计算：

```powershell
Get-FileHash .\downloads\RestTimer-resign-required.ipa -Algorithm SHA256
```

将 Hash 与 `downloads/SHA256SUMS.txt` 比较。校验只说明文件完整，不代表完成签名或安装。

## 7 天到期 / 更新

免费账号签名有效期 7 天。连接手机，用同一个 Apple 账号和同一个 Bundle ID 再安装同一 IPA 或新版 IPA。不要先删除 App。工具的自动续签需要电脑与手机满足 USB 或 Wi-Fi 连接条件，不代表永久签名。

## 常见问题

- 手机不在设备列表：解锁并信任电脑，检查 USB 数据线和官网要求的 Apple 驱动组件。
- 签名提示 App ID / App 数量上限：这是免费账号限制，实时活动扩展也使用 App ID。按工具提示处理，不要反复更改 Bundle ID。
- App 能打开但灵动岛消失：检查扩展是否被移除、是否被正确重签，以及手机实时活动权限。
- 功能或安装不兼容：请记录 Windows 版本、iOS 版本、Sideloadly 版本及错误文本。目前没有 Windows 真机验证记录，不能保证全部功能可用。

官方依据：[Sideloadly FAQ](https://sideloadly.io/faq)、[Apple 免费签名限制](https://developer.apple.com/help/account/basics/about-your-developer-account)。
