# 人生中点 (LifeMidpoint)

一个用 SwiftUI + SwiftData 写的个人成长记录 App（日记、健康、心境练习、写信邮局），配一个本地跑的 Bun/TypeScript AI 后端（`agent-server/`）做日记对话、写信助手这些 AI 功能。

这份文档的目标：换一台全新的 Mac，也能靠一条命令把整个项目跑起来，不用再翻聊天记录回忆当初怎么配的环境。

## 快速开始

```sh
./run.sh
```

第一次跑会自动装好所有依赖（Homebrew / XcodeGen / Bun）、生成 Xcode 工程、启动本地 AI 后端、编译 App、开模拟器装上并启动。全程幂等，重复跑不会出问题。

唯一需要你手动做一步的：本地 AI 后端需要一个大模型 API Key。第一次运行 `./run.sh` 如果发现没配置，会自动帮你从模板复制出 `agent-server/.env`，并提示你去填 `LLM_API_KEY`（默认对接智谱 GLM，[https://open.bigmodel.cn/](https://open.bigmodel.cn/) 免费申请一个即可；也可以换成任何 OpenAI 兼容的接口，改 `.env` 里的 `LLM_BASE_URL`/`LLM_MODEL` 就行，不用改代码）。填完 key 再跑一次 `./run.sh` 就好了。

## 前置要求

- macOS + 完整版 Xcode（不是只装 Command Line Tools）。首次打开 Xcode 需要手动同意一次许可协议。
- 网络（用来装 Homebrew / XcodeGen / Bun，以及调用大模型 API）。
- 其余的（Homebrew、XcodeGen、Bun、iOS 模拟器）`./run.sh` 都会自己检查并安装，不需要提前准备。

## 真机调试

```sh
./run.sh device
```

跟模拟器模式的区别：会把 App 直接装到一台真实 iPhone 上，并且让手机能访问 Mac 上跑的本地 AI 后端。

### 一次性配对（每台新 Mac + 每台新 iPhone 只需要做一次）

真机调试离不开 Xcode 的设备签名机制，这一步没法完全用脚本代劳，需要手动做一遍：

1. 用数据线把 iPhone 接到 Mac 上，手机上点「信任此电脑」。
2. 打开一次 Xcode，菜单栏 `Xcode > Settings > Accounts`，登录你的 Apple ID（**免费账号即可，不需要付费开发者账号**）。
3. Xcode 顶部的设备下拉栏里选一次这台 iPhone，等状态变成「就绪」（Xcode 会自动帮你注册设备、生成开发证书）。
4. iPhone 上：`设置 > 隐私与安全性 > 开发者模式`，打开并按提示重启手机（iOS 16+ 都需要这一步，不然装上的 App 打不开）。

做完这四步之后，以后**不用再插数据线**，只要 iPhone 和 Mac 连在同一个 Wi-Fi 下，`./run.sh device` 就能直接把新的构建无线装到手机上。

### 关于二维码

`./run.sh device` 跑完之后会在终端打印一个二维码（同时也存一张 PNG 图片）。这个二维码扫开是本地 AI 后端的健康检查页面（`http://<Mac的局域网地址>:8787/health`），**不是用来装 App 的**——真机调试最常踩的坑就是"App 装上了，但打不通本地 AI 服务"，用手机摄像头扫一下这个码、在 Safari 里能看到 `{"ok":true,...}` 就说明网络这块没问题；打不开就说明手机和 Mac 没在同一个 Wi-Fi 下，或者 Mac 的防火墙/网络设置挡住了。

> 关于二维码"直接扫码安装 App"：iOS 的这套机制（OTA / `itms-services` 协议）**必须**用 Ad Hoc 或 Enterprise 签名，而这两种签名方式都只有付费的 Apple Developer Program（$99/年）才能用。免费 Apple ID 只能签 Development 证书，装机只能靠 Xcode/命令行直接装到已配对的设备上，没法做成"扫码在 Safari 里弹出安装"的效果。所以这里选择了更实际的方案：`run.sh device` 负责把 App 无线装好，二维码只负责验证网络连通性。如果以后办了付费开发者账号，想要真正的扫码安装，可以按 Apple 的 [Ad Hoc 分发文档](https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices) 加一段导出 `.ipa` + 生成 `manifest.plist` + 通过 HTTPS 托管的流程。

### 真机看实时日志

```sh
xcrun devicectl device process launch --console --device <设备ID> com.lifemidpoint.app
```

`<设备ID>` 可以用 `xcrun devicectl list devices` 查看。

## 项目结构

```
LifeMidpoint/          App 源码 (SwiftUI + SwiftData)
agent-server/          本地 AI 后端 (Bun + TypeScript), 见 agent-server/README.md
project.yml            XcodeGen 配置, 是 .xcodeproj 的唯一 source of truth
                        (.xcodeproj 本身不进 git, 每次 run.sh 都会重新生成)
run.sh                 一键启动脚本 (本文档的主角)
scripts/                辅助脚本 (agent-server 启停、截图对比工具)
PLAN.md                开发过程记录 (按 Figma 设计稿逐页实现的进度)
RESOURCES.md           图片/音频素材来源说明
docs/                  其他专题文档 (响应式布局适配等)
```

## 常见问题

**`xcodebuild` 报 "xcode-select" 相关错误 / simctl 找不到**
说明 `xcode-select` 指向了只有 Command Line Tools 的路径。执行一次：
```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

**`./run.sh device` 报"没有找到已配对的 iOS 设备"**
按上面「一次性配对」的四个步骤做一遍。

**`./run.sh device` 能装上但 App 里的 AI 功能（日记对话/写信助手）转圈不出结果**
八成是手机连不上 Mac 的本地服务，用上面说的二维码验证一下网络；也可能是 Mac 的系统防火墙挡住了入站连接（`系统设置 > 网络 > 防火墙`，允许一下终端/bun 的入站连接）。

**agent-server 报 "LLM API key is not configured"**
`agent-server/.env` 里的 `LLM_API_KEY` 没填或填错了，参考本文档「快速开始」一节。

**换了新 Mac，git clone 下来发现没有 `.xcodeproj`**
这是预期行为：项目用 XcodeGen 管理，`.xcodeproj` 不追踪进 git（避免生成文件冲突），跑一次 `./run.sh`（内部会调 `xcodegen generate`）就会自动生成。

## 从零迁移到一台全新的 Mac

1. 装 Xcode（App Store），打开一次同意许可协议。
2. `git clone` 这个仓库。
3. `cd life-midpoint && ./run.sh`，跟着提示填好 `agent-server/.env` 里的 API Key，再跑一次。
4. 需要真机调试的话，参考上面「真机调试」一节做一次性配对，然后 `./run.sh device`。

大功告成，不需要再做任何其他配置。
