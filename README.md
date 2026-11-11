# Chan 日常工具箱

一个使用英文界面、以 Swift 和 SwiftUI 开发的轻量 iOS 应用，包含专注计时、长度／重量／温度换算和自动保存在本机的便签。核心工具无需账户、网络或第三方依赖；应用内查看用户协议和隐私政策需要联网，并加载 Google Docs 页面。

用 Xcode 打开 `Chan.xcodeproj`，选择合适的开发团队，确认 Bundle Identifier `com.chantools.simplekit` 已在该团队注册并与 App Store Connect 一致后即可配置签名。最低支持 iOS 17。`project.yml` 是 XcodeGen 工程定义；修改后可使用 `xcodegen generate` 重新生成工程。

计时使用结束时间计算，切换页面或重新打开应用后会恢复剩余时间。首次开始计时时可授权本地通知，允许后计时结束会安排系统提醒；通知被关闭或设置失败时，计时仍会继续。便签存储在设备本地，删除应用会删除便签。

布局采用 SwiftUI 安全区和自适应容器。已在 iPhone 18 Pro（iOS 27.0）模拟器检查首页、启动画面及工具操作，并以短时验收构建确认计时完成通知；iPhone Duo（iOS 27.1）检查过单个外屏首页。真机、大字体、Duo 开合与分屏仍需验证。

英文版本已在 iPhone 18 Pro 模拟器检查启动页、首页、三个工具页面和温度换算；`docs/verification` 中不带 `-en` 的截图来自旧版中文界面。系统权限提示的语言由 iOS 设置决定。

首页 Information 区域通过应用内 WKWebView 打开云盘中的英文用户协议和隐私政策；网页不可用时可重试。原始文档由 Google 托管，查看时会连接 Google 服务。

工程中的 `Chan/PrivacyInfo.xcprivacy` 已声明当前本地 UserDefaults 的 CA92.1 使用理由；正式归档仍需检查该文件是否包含在应用包中。更换 Bundle ID 后，旧标识安装的应用数据不会自动迁移到新标识。
