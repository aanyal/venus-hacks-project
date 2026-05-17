//
//  SpeechPlaybackService.swift
//  VenusHacksProject
//

import AVFAudio
import Foundation

@MainActor
final class SpeechPlaybackService: NSObject {
    private let synthesizer = AVSpeechSynthesizer()
    private(set) var selectedVoiceDescription = "System Default"

    func speak(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }

        stop()

        let utterance = AVSpeechUtterance(string: trimmed)
        let voice = preferredVoice()
        utterance.voice = voice
        utterance.rate = 0.46
        utterance.pitchMultiplier = 0.96
        utterance.prefersAssistiveTechnologySettings = true
        utterance.preUtteranceDelay = 0.08
        utterance.postUtteranceDelay = 0.04
        selectedVoiceDescription = describe(voice)
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func preferredVoice() -> AVSpeechSynthesisVoice? {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        let preferredLanguageCode = Locale.current.language.languageCode?.identifier ?? "en"

        let matchingLanguageVoices = allVoices.filter { voice in
            voice.language.lowercased().hasPrefix(preferredLanguageCode.lowercased())
        }

        let fallbackEnglishVoices = allVoices.filter { voice in
            voice.language.lowercased().hasPrefix("en")
        }

        let candidates = matchingLanguageVoices.isEmpty ? fallbackEnglishVoices : matchingLanguageVoices

        return bestVoice(from: candidates)
            ?? bestVoice(from: allVoices)
            ?? AVSpeechSynthesisVoice(language: Locale.current.identifier)
            ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    private func bestVoice(from voices: [AVSpeechSynthesisVoice]) -> AVSpeechSynthesisVoice? {
        voices
            .filter { $0.voiceTraits.contains(.isNoveltyVoice) == false }
            .sorted { lhs, rhs in
            voiceRank(lhs) > voiceRank(rhs)
        }.first
    }

    private func voiceRank(_ voice: AVSpeechSynthesisVoice) -> Int {
        switch voice.quality {
        case .premium:
            return 3
        case .enhanced:
            return 2
        default:
            return 1
        }
    }

    private func describe(_ voice: AVSpeechSynthesisVoice?) -> String {
        guard let voice else { return "System Default" }

        let quality: String = switch voice.quality {
        case .premium:
            "Premium"
        case .enhanced:
            "Enhanced"
        default:
            "Default"
        }

        return "\(voice.name) · \(quality)"
    }
}
