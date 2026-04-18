import Foundation
import AVFoundation
import SwiftUI

/// 音频播放服务: 同时管理多通道 (intro 旁白 + 背景音乐 + 白噪音)
@MainActor
final class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()

    enum Channel {
        case voice    // 旁白/对话音效, 不循环
        case music    // 背景音乐, 循环
        case ambient  // 白噪音, 循环
    }

    private var players: [Channel: AVAudioPlayer] = [:]

    @Published private(set) var currentMusic: String?
    @Published private(set) var currentAmbient: String?

    private init() {
        configureSession()
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession config failed: \(error)")
        }
    }

    /// 在指定通道播放音频, 文件必须打包在 Bundle 中
    func play(file: String, channel: Channel, loop: Bool = false, volume: Float = 1.0) {
        let parts = file.split(separator: ".")
        let name = parts.dropLast().joined(separator: ".")
        let ext = parts.last.map(String.init) ?? "mp3"

        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("⚠️ Audio file not found: \(file)")
            return
        }

        // Stop existing on same channel
        players[channel]?.stop()

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = loop ? -1 : 0
            player.volume = volume
            player.prepareToPlay()
            player.play()
            players[channel] = player

            switch channel {
            case .music: currentMusic = file
            case .ambient: currentAmbient = file
            case .voice: break
            }
        } catch {
            print("⚠️ Failed to play \(file): \(error)")
        }
    }

    func stop(channel: Channel) {
        players[channel]?.stop()
        players[channel] = nil
        switch channel {
        case .music: currentMusic = nil
        case .ambient: currentAmbient = nil
        case .voice: break
        }
    }

    func stopAll() {
        for ch in [Channel.voice, .music, .ambient] {
            stop(channel: ch)
        }
    }

    func setVolume(_ volume: Float, channel: Channel) {
        players[channel]?.volume = volume
    }

    func isPlaying(channel: Channel) -> Bool {
        players[channel]?.isPlaying ?? false
    }
}

// MARK: - Asset Constants

enum AudioAssets {
    static let introStep1 = "intro_step1.mp3"      // 1下班音效
    static let introStep2 = "intro_step2.mp3"      // 2走路声
    static let introStep3 = "intro_step3.mp3"      // 3叹气声
    static let introMusic = "intro_music.mp3"      // 4-14 一直循环的音乐

    static let whiteNoiseWaves = "whitenoise_waves.mp3"  // 海浪
    static let whiteNoiseRain = "whitenoise_rain.mp3"    // 雨
    static let whiteNoiseWind = "whitenoise_wind.mp3"    // 风

    /// 引导步骤对应的旁白音效
    static func voiceForOnboardingStep(_ step: Int) -> String? {
        switch step {
        case 0: return introStep1     // Step 1 = index 0
        case 1: return introStep2     // Step 2
        case 2: return introStep3     // Step 3
        default: return nil           // Step 4+ 用 introMusic 持续播放
        }
    }
}
