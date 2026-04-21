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

        guard needsSeed else { return }

        seedSymptoms(ctx)
        seedMedications(ctx)
        seedPenPals(ctx)

        do {
            try ctx.save()
            print("✅ DataSeeder: 首次种子数据已写入")
        } catch {
            print("❌ DataSeeder save failed: \(error)")
        }
    }

    private static func isEmpty<T: PersistentModel>(_ type: T.Type, in ctx: ModelContext) -> Bool {
        ((try? ctx.fetchCount(FetchDescriptor<T>())) ?? 0) == 0
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

    private static func seedPenPals(_ ctx: ModelContext) {
        let demos: [(name: String, avatar: String, info: String)] = [
            ("偷喝一口月亮", "偷", "往来二十三封书信"),
            ("云端的朋友", "云", "往来五封书信"),
            ("旷野之息", "野", "往来九封书信"),
        ]
        for d in demos {
            ctx.insert(PenPal(name: d.name, avatar: d.avatar, info: d.info))
        }
    }
}
