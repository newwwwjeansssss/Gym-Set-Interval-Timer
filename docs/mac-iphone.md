# Mac → iPhone

准备：Mac、Xcode 26 或更新且支持 iOS 26 SDK 的版本、自己的 Apple 账号、iOS 26+ iPhone、数据线。

## 第一次安装

1. 下载整个仓库并解压，或用 Git 拉取。打开 `ios/RestTimer.xcodeproj`。
2. Xcode → Settings → Accounts，登录自己的 Apple 账号。
3. 点击左侧蓝色工程图标。在 **RestTimer** 和 **RestActivity** 两个 target 的 **Signing & Capabilities** 中，选中 Automatically manage signing，Team 都选择自己的团队。免费账号一般显示 Personal Team。
4. 如果提示 App 标识不可用，把主 App 的 Bundle Identifier 改成自己的唯一值，例如 `com.yourname.zujiantimer`，扩展改成同一前缀加 `.activity`。下次更新沿用这两个值。
5. 连接并解锁 iPhone，手机点「信任」。按提示在手机 设置 → 隐私与安全性 → 开发者模式 中开启并重启；若尚未出现该选项，先等待 Xcode 完成配对。
6. Xcode 顶部 Scheme 选 **RestTimer**，运行设备选你的 **iPhone**，点击 ▶︎。
7. 若 Mac 弹出 codesign 钥匙串窗口，在本机窗口输入 Mac 登录密码并允许。若手机提示未受信任，进入 设置 → 通用 → VPN 与设备管理，信任你自己的开发者账号。
8. 打开「组间」，允许通知，选择 30 秒点击开始。回到主屏幕观察灵动岛，或锁屏观察卡片，确认到时通知。

## 绑定操作按钮

系统设置 → 操作按钮 → 快捷指令 → 组间 → 开始休息。

若找不到：先启动组间一次，再到「快捷指令」新建快捷指令，添加「组间 → 开始休息」，保存后绑定。按住左侧操作按钮即可计时，重复执行重新开始。

## 7 天到期 / 更新

使用免费账号时，重新连接手机，在同一工程中选择同一 Team 和 Bundle ID，再点击 ▶︎。不必先删除 App。更新源码后也按此操作。

## 常见问题

- 构建通过但安装失败：确认主 App 与实时活动扩展都选了同一个 Team。
- 未找到手机：解锁、换数据线，检查 Xcode → Window → Devices and Simulators。
- 灵动岛未显示：先退出 App，检查系统设置中组间的实时活动权限，确认机型有灵动岛。
- “需要更新 Xcode”：手机系统比本机 Xcode 支持的系统新，按提示升级 Xcode。

签名限制见 [苹果说明](https://developer.apple.com/help/account/basics/about-your-developer-account)。
