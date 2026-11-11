<!-- appstore-review-audit-report:v1 -->
# App Store 首审风险审计

项目：Chan

审计日期：2026-11-11；技能版本：1.2.0

版本/工作区：Git repository has no commits; all project files untracked.

Target：Chan \(SwiftUI iOS/iPadOS\)；配置：Release project settings; no matching Release artifact supplied

审计范围：Read-only source, target membership, configuration, resource references, Apple documentation, anonymous HTTP checks of policy links. Old simulator builds are not release artifacts and predate WebView integration.

规则核验：在线核验；日期：2026-11-11

> 本报告由已脱敏的输入生成。渲染成功仅说明数据形状有效，不证明证据真实、条款适用或能够过审；渲染器不代替脱敏检查。

## 结论

当前源码不建议直接送审：缺少 UserDefaults required-reason 隐私清单；正式身份、签名、提审包和 ASC 状态未获证据。产品价值及 4.3 存在待审核判断的风险。

活跃风险共 2 项（P0：0，P1：2，P2：0，P3：0）。

其中已确认 1 项；高度疑似 0 项；待核验 1 项。

历史项目 0 项、代码外待补证 5 项，均不计入上述活跃风险数。

## 覆盖范围

- 发布配置 · 待补证：工程是 iOS 17+、iPhone/iPad、版本 1.0\(1\)，示例 Bundle ID；没有 ASC、签名、Release Archive 或最终上传包证据。
- 启动和核心功能 · 待补证：此前在 iOS 27.0 模拟器检查英文版与短计时通知；协议 WebView 是后续改动，当前源码及 Release 尚未重新编译或运行。
- 账户 · 已检查：已审查本项目 Swift 源码与入口，未见注册登录；范围限定当前工程。
- 隐私 · 已检查：沿便签、计时、本地通知与 Google Docs WebView 路径检查。源工程无 PrivacyInfo.xcprivacy；最终包和 ASC 声明未验证。
- 支付 · 不适用：源码及项目配置范围内未发现购买、订阅或 StoreKit 流程。
- 内容安全 · 不适用：便签在设备本地，当前代码无共享、公开发布、社交或聊天入口。
- Web 与远程行为 · 待补证：两份 Google Docs 预览链接匿名 HTTP 200 且可查到正文；WKWebView 线上显示、离线重试及最终包未验证。
- 依赖与平台 API · 待补证：项目源码和构建配置未显示三方依赖；最终归档关联 framework 和隐私报告未检查。
- 产品及版权 · 待补证：存在自制图片和三个简单工具；截图版权、开发者账号其他产品及 4.2/4.3 审核判断未核实。
- 提交材料 · 待补证：没有 ASC 配置、隐私问卷、Support URL、审核截图、设备验证或上传版本的证据。
- 二进制逆向 · 待补证：无可确认匹配当前代码的 Release IPA/Archive/Mach-O；旧模拟器 Debug 包不代表拟提交产物，未调用 REA/Hopper。

“已检查”表示完成所述范围的检查，不是认证通过。

## 官方来源核验记录

仅获取页面或 HTTP 请求成功不等于已阅读并核验。

- [App Review](https://developer.apple.com/distribute/app-review/)；日期：2026-11-11；状态：已阅读并核验；范围：Review preparation and submission context
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)；日期：2026-11-11；状态：已阅读并核验；范围：2.1, 2.3, 4.2, 4.3 and 5.1.1
- [Required reason API](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api)；日期：2026-11-11；状态：已阅读并核验；范围：App code required reason API manifest and upload requirement
- [Required reason API categories](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype)；日期：2026-11-11；状态：已阅读并核验；范围：UserDefaults and CA92.1
- [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)；日期：2026-11-11；状态：已阅读并核验；范围：Required iPhone and supported iPad screenshots
- [Upcoming Requirements](https://developer.apple.com/news/upcoming-requirements/)；日期：2026-11-11；状态：已阅读并核验；范围：Current minimum SDK and target iOS requirements
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)；日期：2026-11-11；状态：已阅读并核验；范围：Privacy links and third-party web practices
- [Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/)；日期：2026-11-11；状态：已阅读并核验；范围：Support URL
- [Complete review information](https://developer.apple.com/help/app-review/before-submitting-for-review/complete-review/)；日期：2026-11-11；状态：已阅读并核验；范围：Review information
- [Set an app age rating](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/)；日期：2026-11-11；状态：已阅读并核验；范围：Age-rating questionnaire

## 活跃风险

### AR-001 · P1 · UserDefaults required-reason 隐私清单缺失

状态：已确认；置信度：高；领域：隐私及上传

发布路径：HomeView → FocusTimer.standard defaults 保存计时；NotesView @AppStorage 保存便签。两个 Swift 文件列入应用 target。

触发条件：以当前源工程生成、上传没有额外注入隐私清单的应用包。

影响：Apple 要求在应用的隐私清单中声明覆盖 API 的使用理由；缺失声明的包将不能被 App Store Connect 接受。

证据：

- code · Chan/FocusView.swift:13 — UserDefaults.standard 与保存恢复计时状态。
- code · Chan/NotesView.swift:4 — AppStorage 持久化便签。
- search\_scope · Chan.xcodeproj/project.pbxproj:116 — 主目标资源及项目文件盘点未发现 PrivacyInfo.xcprivacy；最终 Release 包或构建注入未知。

适用规则：

- [Required reason API / UserDefaults](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api)；核对日期：2026-11-11；适用性：应用代码使用 UserDefaults 须在自身隐私清单声明适用理由；CA92.1 对仅供自身访问的数据是候选。
- [UserDefaults CA92.1](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype)；核对日期：2026-11-11；适用性：对应应用私有默认值读写，须结合最终构建用途核对。

整改步骤：

1. 为应用 target 添加 PrivacyInfo.xcprivacy，按真实用途声明 NSPrivacyAccessedAPICategoryUserDefaults 和适用理由；检查其他构建引入的 required-reason API。
2. 确认该文件在正式归档主 bundle 中。

验证步骤与预期结果：

1. Archive 后查看 App Privacy Report 与打包后的隐私清单；完成一次 App Store Connect 上传验证。

负责模块/角色：iOS / 发布；工作量：S

剩余不确定性：

- 如果外部构建系统注入清单，必须以拟提交包核对；没有该证据。

### AR-002 · P1 · 工具组合的独特性和实用价值存在 4.2/4.3 审核风险

状态：待核验；置信度：中；领域：产品价值

发布路径：HomeView 暴露计时、单位换算、单条便签三个主要工具。

触发条件：Apple 认为该组合与现有产品区别不足或实用价值不够。

影响：可能依据 4.2 或 4.3 拒审；不是已确认违规，也不能由代码判断审核结果。

证据：

- code · Chan/HomeView.swift:3 — 核心工具枚举为 focus、convert、notes；WebView 为附加协议。

适用规则：

- [4.2 Minimum Functionality / 4.3 Spam](https://developer.apple.com/app-store/review/guidelines/)；核对日期：2026-11-11；适用性：Apple 要求足够的实用价值，并指出简单计时器等饱和类别需要有显著不同或改进的体验。

整改步骤：

1. 以产品自身真实使用场景检查这三个工具是否形成有价值且差异化的体验；真实反映在功能和商店介绍中。
2. 不要仅靠添加装饰、虚构能力或堆砌无关功能规避审核。

验证步骤与预期结果：

1. 通过目标用户流程、竞品差异和审核截图核对；Apple 最终裁量不可预先保证。

负责模块/角色：产品；工作量：M，取决于产品范围

剩余不确定性：

- 工具箱不等同于仅有简单计时器；最终是否满足 4.2/4.3 须由 Apple 判断。

## 代码外待补证

优先级表示潜在影响，以下缺口不是已确认风险。

### GAP-001 · P1

正式 Bundle ID、团队签名、ASC 记录与可上传构建是否已就绪？

需要的证据：项目示例值替换或证明受控构建覆盖；与 ASC App ID 一致的 Release Archive 与上传处理状态。

负责角色：发布

### GAP-002 · P1

最新协议 WebView 代码是否能在最终 Release 包中构建、打开并返回，离线时能重试？

需要的证据：对与上传包一致的构建在设备检查两个协议、返回、弱网与离线；无登录公开访问。

负责角色：iOS / QA

### GAP-003 · P1

ASC 隐私、可公开访问的隐私政策、Support URL、年龄分级和审核资料是否已经填写？

需要的证据：ASC 相应页面和无登录访问验证；隐私问卷包括 Google Docs 页面请求及实际第三方处理。

负责角色：App Store Connect

### GAP-004 · P2

目标设备截图和 iPad 实际体验是否准备完毕？

需要的证据：当前构建真实截图，支持 iPad 则提供符合要求的 13 英寸 iPad 截图；核对实际设置。

负责角色：产品 / 发布

### GAP-005 · P2

Duo 开合、分屏和真机长文本是否可用？

需要的证据：在匹配构建上进行 Duo 姿态与真机验证。

负责角色：iOS / QA

## 已解决与不适用历史

本次无历史项目。
