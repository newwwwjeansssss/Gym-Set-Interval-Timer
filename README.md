# 组间 · iPhone 健身休息计时器

设定休息时长，每组结束开始计时，到时提醒。极简黑白界面，支持操作按钮快捷指令、灵动岛及锁屏实时活动。

**仅支持 iPhone，不包含 Android 版本。** Mac 和 Windows 指安装时使用的电脑，不是 App 运行平台。

## 从这里开始

| 你的电脑 | 下载什么 | 安装方式 | 安装指南 |
|---|---|---|---|
| Mac | 整个仓库源码 | Xcode 用自己的 Apple 账号签名，再通过数据线安装 | [Mac → iPhone](docs/mac-iphone.md) |
| Windows 10/11 | 整个仓库或 IPA 安装包 | Sideloadly 用自己的 Apple 账号重新签名，再通过数据线安装 | [Windows → iPhone](docs/windows-iphone.md) |

**免费 Apple 账号可用，但签名 7 天到期，需要续签/重装。** 不需要分享作者的账号或证书，也不需要越狱。本仓库不能免除苹果的签名要求。

### 手机要求

- iOS 26.0 或更新版本。
- 支持该系统的 iPhone 可使用页面计时与通知。
- 实体操作按钮需要带 Action Button 的机型；右侧相机控制按钮不支持。
- 灵动岛需要相应硬件；其他兼容机型可以使用锁屏实时活动。

## 下载 / 拉取

点击 **Code → Download ZIP** 并解压，或运行：

```bash
git clone https://github.com/newwwwjeansssss/Gym-Set-Interval-Timer.git
```

两种方式得到相同源码。

[下载待重签 IPA](downloads/RestTimer-resign-required.ipa)（不是已签名安装包，不能在 iPhone 中直接点开安装）。如果 GitHub 显示文件预览页，点击下载原始文件。

## 安装后

1. 打开「组间」，允许通知，设置时长。
2. 如需侧键：系统设置 → 操作按钮 → 快捷指令 → 组间 → 开始休息。
3. 开始计时后退出 App，在灵动岛或锁屏查看倒计时；长按灵动岛查看进度。

通知横幅设为「临时」；健身专注模式允许组间通知。实时活动到时停在零，打开 App 后清除；取消计时立即移除。

## 文件结构

- `ios/`：完整 Xcode 工程、实时活动扩展和测试。
- `downloads/`：Release IPA 与 SHA-256 校验值。
- `docs/`：Mac、Windows 安装步骤及验收记录。
- `scripts/`：Mac 生成 IPA、Windows 校验文件。

## 验证范围

Mac + Xcode 安装路径已在作者的 iPhone 17 上使用；本分享包的源码完成 Release 编译，IPA 结构、真机架构和实时活动扩展已检查。

**Windows + Sideloadly 路径尚未实机验证**，属于待验证的安装方案；尤其需确认重签保留实时活动扩展后，灵动岛与操作按钮能正常工作。详见 [验收清单](docs/verification.md)。

## 数据与源码使用

无账号系统、无广告、无分析 SDK、无服务器；休息时长等设置保存在手机本地。通知和实时活动由 iOS 提供。

本仓库尚未选择开源许可证。公开源码不等于授予任意使用、修改或再分发的开源许可。

## 维护

Mac 上运行 `bash scripts/build-ipa-mac.sh` 可重新生成待重签 IPA，无需填入 Apple 账号。使用 Xcode 26 或更高且能编译 iOS 26 SDK 的版本。

后续版本沿用 App 标识，用户也沿用自己的签名账号与 Bundle ID，便于覆盖更新。不要将私钥、Apple 登录信息、签名证书或设备描述文件提交到 GitHub。

参考：[苹果免费签名限制](https://developer.apple.com/help/account/basics/about-your-developer-account)、[Sideloadly 官网](https://sideloadly.io/)、[Sideloadly FAQ](https://sideloadly.io/faq)。
