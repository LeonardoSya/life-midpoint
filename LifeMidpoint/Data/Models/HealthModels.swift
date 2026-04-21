import Foundation
import SwiftData

// MARK: - 日期工具

enum DayKey {
    /// "yyyy-MM-dd" 字符串, 用作 SwiftData 唯一约束键.
    /// 保证同一天只对应一行 SleepDay / HeartRateDay.
    static func key(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f.string(from: date)
    }
}

// MARK: - 睡眠

/// 一天的睡眠汇总 (按日 unique).
/// minutes 字段全部以"分钟"为单位, 便于按周/月聚合.
@Model
final class SleepDay {
    @Attribute(.unique) var dayKey: String
    var date: Date
    var totalMinutes: Int
    var deepMinutes: Int
    var lightMinutes: Int
    var remMinutes: Int
    var qualityScore: Int           // 0...100
    var qualityNote: String?

    init(date: Date, totalMinutes: Int, deepMinutes: Int = 0,
         lightMinutes: Int = 0, remMinutes: Int = 0,
         qualityScore: Int = 0, qualityNote: String? = nil) {
        self.dayKey = DayKey.key(for: date)
        self.date = Calendar.current.startOfDay(for: date)
        self.totalMinutes = totalMinutes
        self.deepMinutes = deepMinutes
        self.lightMinutes = lightMinutes
        self.remMinutes = remMinutes
        self.qualityScore = qualityScore
        self.qualityNote = qualityNote
    }
}

// MARK: - 心率

/// 一天的静息心率 (按日 unique).
@Model
final class HeartRateDay {
    @Attribute(.unique) var dayKey: String
    var date: Date
    var restingBpm: Int

    init(date: Date, restingBpm: Int) {
        self.dayKey = DayKey.key(for: date)
        self.date = Calendar.current.startOfDay(for: date)
        self.restingBpm = restingBpm
    }
}

// MARK: - 症状

/// 症状打卡记录. 同一天可有多条症状, 因此 NOT unique.
/// `severity`: 0 (无) / 1 (轻) / 2 (中) / 3 (重).
@Model
final class SymptomLog {
    var date: Date
    var name: String
    var iconSystemName: String
    var severity: Int

    init(name: String, iconSystemName: String, severity: Int, date: Date = Date()) {
        self.name = name
        self.iconSystemName = iconSystemName
        self.severity = severity
        self.date = Calendar.current.startOfDay(for: date)
    }
}

// MARK: - 月经周期

/// 一段经期记录 (`AddPeriodView`).
/// `endDate` 为 nil 表示尚未结束 (用户在经期当中记录).
@Model
final class MenstrualPeriod {
    var startDate: Date
    var endDate: Date?

    init(startDate: Date, endDate: Date? = nil) {
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.endDate = endDate.map { Calendar.current.startOfDay(for: $0) }
    }

    /// 返回本段经期的天数 (含端点). endDate 为 nil 时返回 nil.
    var dayCount: Int? {
        guard let endDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return days + 1
    }
}

// MARK: - 用药

/// 药品定义 + 默认提醒配置.
/// 名称 unique 防止重复药品.
@Model
final class Medication {
    @Attribute(.unique) var name: String
    var dosageText: String?         // "1 粒"
    var notes: String?              // "空腹服用"
    var defaultReminderTime: String?// "09:00" HH:mm
    var frequency: String           // "每日" / "每周" / "隔日"
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \MedicationDoseEvent.medication)
    var events: [MedicationDoseEvent] = []

    init(name: String, dosageText: String? = nil, notes: String? = nil,
         defaultReminderTime: String? = nil, frequency: String = "每日") {
        self.name = name
        self.dosageText = dosageText
        self.notes = notes
        self.defaultReminderTime = defaultReminderTime
        self.frequency = frequency
        self.createdAt = Date()
    }
}

/// 单次服药事件 (某天某剂打勾).
/// `date` 是当天 0 点, `scheduledTime` 是 "HH:mm" 字符串.
@Model
final class MedicationDoseEvent {
    var date: Date
    var scheduledTime: String
    var taken: Bool
    var medication: Medication?

    init(date: Date = Date(), scheduledTime: String, taken: Bool = false,
         medication: Medication? = nil) {
        self.date = Calendar.current.startOfDay(for: date)
        self.scheduledTime = scheduledTime
        self.taken = taken
        self.medication = medication
    }
}
