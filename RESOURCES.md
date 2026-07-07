# 资源清单

> 本文档描述项目中所有图片、音频等静态资源的来源和用途。

## 图片资源 (Assets.xcassets) - 共 78 个 imageset

### 引导流程插画 (14 张)
来源: 用户提供 `intro+日记页12/`

| Asset | 文件 | 描述 |
|-------|------|------|
| OnboardingStep01 | 1下班.JPEG | 电梯中的女人下班 |
| OnboardingStep02 | 2.JPEG | 走出电梯 |
| OnboardingStep03 | 3走路街道.JPEG | 走在街道上 |
| OnboardingStep04 | 4两个人的.JPG | 蛋糕店遇见小女孩 |
| OnboardingStep05 | 5你不要拿走.PNG | 小女孩看着蛋糕 |
| OnboardingStep06 | 6哦你没拿走.JPEG | 让出蛋糕 |
| OnboardingStep07 | 7你怎么也有.PNG | 发现胎记 |
| OnboardingStep08 | 8兔子给你.JPG | 获得兔子 |
| OnboardingStep09 | 9同学你东西掉了.jpeg | 兔子掉落 |
| OnboardingStep10 | 10谁的名片.JPEG | 输入名字 |
| OnboardingStep11 | (复用 step10) | 完成输入 |
| OnboardingStep12 | 12天啊好卷.JPG | 梦幻漩涡 |
| OnboardingStep13 | 13海边.JPEG | 海边相遇 |
| OnboardingStep14 | 14海边思考.JPEG | 海边咖啡厅 + CTA |

### 日记页背景 (2 张)
| Asset | 文件 | 用途 |
|-------|------|------|
| DiaryBackground | 日记页面1.JPEG | 主日记页全屏背景 |
| DiarySummaryBackground | 日记页面2.JPEG | 日记总结页背景 |

### 邮票系列 (51 张)
来源: 用户提供 `人生中点邮票/`

- **GoldStamp1-14** (鎏金典藏): 波动之间, 情绪采样者, 第一封寄出, 仍在书写, 缓缓回温, 四时有迹, 初次留痕, 旧字重逢, 一月成册, 回望之眼, 回音抵达, 鎏金典藏, 百日留金, 接住自己
- **MidpointStamp14-17** (人生中点): 落点, 转弯, 交汇, 留白
- **MigrationStamp18-26** (候鸟归家): 潮边短歇, 月下辨途, 雾湖长翼, 逆风而行, 归枝已定, 落水成纹, 檐下归巢, 斜阳归影, 启程
- **FlowerStamp27-38** (四时之花): 桃枝含春, 玉枝含光, 藤影低垂, 茉香留白, 铃语初夏, 云团成色, 荷心映日, 向光而生, 紫雾轻眠, 桂影藏香, 菊色成秋, 虞色流火
- **ChildhoodStamp39-50** (童年): 灯火童年, 骑风而行, 掌心小兽, 旋转时光, 折纸远航, 琉璃旧梦, 风起蜻蜓, 甜夏一支, 悠悠时刻, 羽落之间, 收藏秘密, 倒带时光

### 登录/认证 (3 张)
| Asset | 来源 | 用途 |
|-------|------|------|
| LoginBackground | Figma 原始 | 登录页海滩日落背景 |
| WeChatIcon | Figma 原始 | 微信登录图标 (2300×2300 PNG) |
| EmailIcon | Figma 原始 | 邮箱登录图标 (SVG 矢量) |

### 邮局/集邮 (5 张)
| Asset | 来源 | 用途 |
|-------|------|------|
| DiaryMenuIcon | Figma 原始 | 日记页左侧菜单图标 |
| PostOfficeWriteIcon | Figma 原始 | 写一封信 - 笔图标 |
| PostOfficeMailIcon | Figma 原始 | 邮局捷报 - 信封图标 |
| EnvelopeImage | Figma 原始 | 寄信确认页 - 信封图 |
| StampOnLetter | Figma 原始 | 寄信确认页 - 树木邮票 |
| StampObtainedImage | Figma 原始 | 获得邮票默认占位 (花卉邮票) |

### 心境/健康 (2 张)
| Asset | 来源 | 用途 |
|-------|------|------|
| MindStoneImage | Figma 原始 | 心境首页禅石图 |
| MedicationIllustration | Figma 原始 | 健康页彩色药丸插画 (2300×2300) |

---

## 音频资源 (LifeMidpoint/Resources/Audio) - 共 7 个文件

来源: 用户提供 `intro+日记页12/` 和 `白噪音/`

### Intro 旁白音效
| Asset | 文件 | 用途 |
|-------|------|------|
| intro_step1.mp3 | 1下班.MP3 | 引导 Step 1 旁白 |
| intro_step2.mp3 | 2走路声.MP3 | 引导 Step 2 走路声 |
| intro_step3.mp3 | 3.叹气声.MP3 | 引导 Step 3 叹气声 |
| intro_music.mp3 | 4-14一音乐.MP3 | Step 4-14 持续背景音乐 |

### 白噪音
| Asset | 文件 | 用途 |
|-------|------|------|
| whitenoise_waves.mp3 | 13-14海浪声.MP3 | 海浪白噪音 |
| whitenoise_rain.mp3 | 雨声.MP3 | 雨声白噪音 |
| whitenoise_wind.mp3 | 风声.MP3 | 风声白噪音 |

### 集成位置
| 页面 | 音频通道 | 触发方式 |
|------|---------|---------|
| 引导流程 | voice (Step 1-3) + music (Step 4+) | 自动随步骤播放 |
| 设置 - 白噪音选择器 | ambient | 点击 Chip 切换 |
| 微行为实验 - 背景音 | ambient | 点击 Chip 切换 |

---

## 资源使用约定

1. **图片资源**: 通过 Asset Catalog 名称引用 `Image("AssetName")`
2. **音频资源**: 通过 `AudioPlayer.shared.play(file: AudioAssets.xxx, channel:)` 播放
3. **音频通道**:
   - `voice` - 旁白对话, 不循环
   - `music` - 背景音乐, 循环
   - `ambient` - 环境白噪音, 循环
   - 三通道独立, 可同时播放
