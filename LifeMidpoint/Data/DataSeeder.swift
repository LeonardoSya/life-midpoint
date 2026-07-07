import Foundation
import SwiftData

/// 首次启动种子数据.
///
/// 通过"判断关键表是否为空"来决定是否需要 seed (无需额外标志位).
/// 种子内容与原 `MockData.swift` 一致, 保证 demo 视觉效果不变.
@MainActor
enum DataSeeder {
    /// 检查并植入种子数据. 多次调用安全 (已 seed 过会跳过).
    static func seedIfNeeded(context ctx: ModelContext) {
        let needsSeed = isEmpty(SymptomLog.self, in: ctx)
            && isEmpty(Medication.self, in: ctx)
            && isEmpty(PenPal.self, in: ctx)
        let needsHeartRateSeed = isEmpty(HeartRateDay.self, in: ctx)
        let needsSleepSeed = isEmpty(SleepDay.self, in: ctx)
        // 笔友信件历史单独判断 (不并入 needsSeed 门槛), 这样即使老用户之前已经跑过
        // 一次主种子 (只有笔友、没有关联信件), 也能补种上往来记录, 让"我的笔友"日历/详情页
        // 首次打开时就有真实数据, 而不是一片空白.
        let needsPenPalLetterSeed = !isEmpty(PenPal.self, in: ctx) && hasNoPenPalLetters(ctx)

        guard needsSeed || needsHeartRateSeed || needsSleepSeed || needsPenPalLetterSeed else { return }

        var seededPenPals: [PenPal] = []
        if needsSeed {
            seedSymptoms(ctx)
            seedMedications(ctx)
            seededPenPals = seedPenPals(ctx)
        }
        // 心率/睡眠/笔友信件分别单独判断是否为空 (不并入上面的整体门槛), 这样即使老用户已经跑过一次
        // 主种子, 后续版本新增的表也能补种上, 而不会被"已经 seed 过"跳过.
        if needsHeartRateSeed {
            seedHeartRate(ctx)
        }
        if needsSleepSeed {
            seedSleep(ctx)
        }
        if needsPenPalLetterSeed {
            let pals = seededPenPals.isEmpty ? fetchAllPenPals(ctx) : seededPenPals
            seedPenPalLetters(ctx, penPals: pals)
        }

        do {
            try ctx.save()
            #if DEBUG
            print("✅ DataSeeder: 种子数据已写入")
            #endif
        } catch {
            #if DEBUG
            print("❌ DataSeeder save failed: \(error)")
            #endif
        }
    }

    private static func isEmpty<T: PersistentModel>(_ type: T.Type, in ctx: ModelContext) -> Bool {
        ((try? ctx.fetchCount(FetchDescriptor<T>())) ?? 0) == 0
    }

    private static func hasNoPenPalLetters(_ ctx: ModelContext) -> Bool {
        let predicate = #Predicate<Letter> { $0.penPal != nil }
        return ((try? ctx.fetchCount(FetchDescriptor<Letter>(predicate: predicate))) ?? 0) == 0
    }

    private static func fetchAllPenPals(_ ctx: ModelContext) -> [PenPal] {
        (try? ctx.fetch(FetchDescriptor<PenPal>())) ?? []
    }

    // MARK: - 各领域种子

    private static func seedSymptoms(_ ctx: ModelContext) {
        let today = Date()
        let demos: [(String, String, Int)] = [
            ("潮热", "flame", 3),
            ("失眠", "moon.zzz", 2),
            ("盗汗", "drop", 1),
            ("心悸", "heart", 2),
            ("焦虑", "waveform.path", 2),
            ("头痛", "brain", 0),
        ]
        for (name, icon, severity) in demos {
            ctx.insert(SymptomLog(name: name, iconSystemName: icon, severity: severity, date: today))
        }
    }

    private static func seedMedications(_ ctx: ModelContext) {
        let demos: [(name: String, dosage: String?, notes: String?, time: String)] = [
            ("大豆异黄酮", "1 粒", "空腹服用", "09:00"),
            ("雌激素制剂", "1 片", nil, "11:00"),
            ("鱼油", "2 粒", "随餐", "13:00"),
            ("褪黑素", "1 粒", "睡前 30 分钟", "22:00"),
        ]
        for d in demos {
            ctx.insert(Medication(
                name: d.name, dosageText: d.dosage, notes: d.notes,
                defaultReminderTime: d.time, frequency: "每日"
            ))
        }
    }

    @discardableResult
    private static func seedPenPals(_ ctx: ModelContext) -> [PenPal] {
        let demos: [(name: String, avatar: String, info: String)] = [
            ("偷喝一口月亮", "偷", "往来二十三封书信"),
            ("云端的朋友", "云", "往来五封书信"),
            ("旷野之息", "野", "往来九封书信"),
        ]
        return demos.map { d in
            let pal = PenPal(name: d.name, avatar: d.avatar, info: d.info)
            ctx.insert(pal)
            return pal
        }
    }

    /// 给每位笔友补几封往来信件, 时间打散在最近一个月内 (含今天所在月份),
    /// 让"我的笔友"页的日历能高亮出真实的往来日期, 点开笔友详情也有真实的信件历史.
    private static func seedPenPalLetters(_ ctx: ModelContext, penPals: [PenPal]) {
        guard !penPals.isEmpty else { return }
        let calendar = Calendar.current
        let today = Date()

        let sentSnippets = [
            "今天的风很轻, 我想把那些焦虑\n都吹散在云里...",
            "最近总是很晚才睡, 但看到你的信\n心里一下子踏实了不少。",
            "窗外下了一整天雨, 就窝在家里\n把想说的话都写给你。",
            "今天路过一片银杏林, 想到你说\n最喜欢秋天, 就拍了张照片留着。",
        ]
        let receivedSnippets = [
            "愿你的世界总有暖阳, 那些不安\n终会成为过去的风景。",
            "读完你的信, 也想起了自己类似\n的经历, 原来我们都不是一个人。",
            "此时云朵很美, 身处旅行途中,\n觉察充满期待, 寄出一份今日见闻。",
            "谢谢你愿意分享这些, 好好休息,\n下次见面再慢慢聊。",
        ]
        let aliases = ["屋檐与猫", "晚风与信", "远方来客", "旧巷邮差"]

        // 每位笔友按 info 里的"往来 N 封"大致决定信件数量, 最多 6 封, 保证详情页不会过长.
        for (index, pal) in penPals.enumerated() {
            let letterCount = min(6, max(3, (index + 1) * 2))
            for i in 0..<letterCount {
                // 时间打散在最近 0~27 天, 且第 0 封固定落在"今天", 保证日历本月至少有一天高亮.
                let dayOffset = i == 0 ? 0 : Int.random(in: 1...27)
                guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
                let isSent = i % 2 == 0
                let body = isSent
                    ? sentSnippets[i % sentSnippets.count]
                    : receivedSnippets[i % receivedSnippets.count]
                let letter = Letter(
                    direction: isSent ? "sent" : "received",
                    recipientMode: "penPal",
                    body: body,
                    alias: isSent ? nil : aliases[index % aliases.count],
                    penPal: pal,
                    status: "sent"
                )
                letter.createdAt = date
                letter.sentAt = date
                ctx.insert(letter)
                if date > pal.lastActiveAt {
                    pal.lastActiveAt = date
                }
            }
        }
    }

    /// 近 14 天静息心率, 让"静息心率"页首次打开时就有真实的图表和历史记录.
    private static func seedHeartRate(_ ctx: ModelContext) {
        let calendar = Calendar.current
        let today = Date()
        let bpmPattern = [72, 70, 74, 69, 73, 71, 68, 75, 70, 72, 69, 74, 71, 70]
        for offset in 0..<14 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            ctx.insert(HeartRateDay(date: date, restingBpm: bpmPattern[offset % bpmPattern.count]))
        }
    }

    /// 近 14 天睡眠记录 (入睡/起床时间 + 深/浅/REM 分布), 让"睡眠跟踪"页首次打开
    /// 就有真实的表盘、时长与历史卡片, 而不是空数据.
    private static func seedSleep(_ ctx: ModelContext) {
        let calendar = Calendar.current
        let today = Date()
        // (总时长分钟, 深睡占比, 浅睡占比, 质量分, 入睡时:分, 起床时:分)
        let pattern: [(total: Int, deepPct: Double, lightPct: Double, score: Int, bedH: Int, bedM: Int, wakeH: Int, wakeM: Int)] = [
            (495, 0.22, 0.55, 82, 22, 40, 6, 55),
            (462, 0.18, 0.58, 74, 23, 10, 6, 52),
            (528, 0.25, 0.52, 88, 22, 20, 7, 8),
            (438, 0.15, 0.60, 66, 23, 45, 6, 43),
            (510, 0.23, 0.53, 85, 22, 35, 7, 5),
            (474, 0.19, 0.57, 76, 23, 0, 6, 54),
            (549, 0.27, 0.50, 91, 22, 10, 7, 19),
        ]
        for offset in 0..<14 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let p = pattern[offset % pattern.count]
            let deep = Int(Double(p.total) * p.deepPct)
            let light = Int(Double(p.total) * p.lightPct)
            let rem = max(0, p.total - deep - light)
            let dayStart = calendar.startOfDay(for: date)
            let bedTime = calendar.date(byAdding: .day, value: -1, to: dayStart)
                .flatMap { calendar.date(bySettingHour: p.bedH, minute: p.bedM, second: 0, of: $0) }
            let wakeTime = calendar.date(bySettingHour: p.wakeH, minute: p.wakeM, second: 0, of: dayStart)
            ctx.insert(SleepDay(
                date: date, totalMinutes: p.total, deepMinutes: deep,
                lightMinutes: light, remMinutes: rem, qualityScore: p.score,
                qualityNote: nil, bedTime: bedTime, wakeTime: wakeTime
            ))
        }
    }
}
