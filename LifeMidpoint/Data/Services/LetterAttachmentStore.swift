import Foundation
import UIKit

/// 信件图片附件的磁盘存储.
///
/// 图片以 JPEG 压缩后存放在 `Documents/LetterAttachments/` 下,
/// `Letter.attachmentFilenames` 只保存文件名, 不直接把大图数据塞进 SwiftData 记录里.
enum LetterAttachmentStore {
    private static var directory: URL {
        let dir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LetterAttachments", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    @discardableResult
    static func save(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.82) else { return nil }
        let filename = "\(UUID().uuidString).jpg"
        do {
            try data.write(to: directory.appendingPathComponent(filename), options: .atomic)
            return filename
        } catch {
            return nil
        }
    }

    static func load(_ filename: String) -> UIImage? {
        guard let data = try? Data(contentsOf: directory.appendingPathComponent(filename)) else { return nil }
        return UIImage(data: data)
    }

    static func delete(_ filename: String) {
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(filename))
    }
}
