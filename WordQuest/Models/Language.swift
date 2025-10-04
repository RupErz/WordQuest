//
//  Language.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import Foundation

struct Language: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String
    let locale: String
    
    static let supportedLanguages: [Language] = [
        Language(name: "English", code: "en", flag: "🇺🇸", locale: "en-US"),
        Language(name: "Spanish", code: "es", flag: "🇪🇸", locale: "es-ES"),
        Language(name: "French", code: "fr", flag: "🇫🇷", locale: "fr-FR"),
        Language(name: "German", code: "de", flag: "🇩🇪", locale: "de-DE"),
        Language(name: "Italian", code: "it", flag: "🇮🇹", locale: "it-IT"),
        Language(name: "Japanese", code: "ja", flag: "🇯🇵", locale: "ja-JP"),
        Language(name: "Chinese", code: "zh", flag: "🇨🇳", locale: "zh-CN"),
        Language(name: "Korean", code: "ko", flag: "🇰🇷", locale: "ko-KR"),
        Language(name: "Portuguese", code: "pt", flag: "🇵🇹", locale: "pt-PT"),
        Language(name: "Russian", code: "ru", flag: "🇷🇺", locale: "ru-RU")
    ]
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var description: String {
        switch self {
        case .beginner:
            return "Perfect for new learners"
        case .intermediate:
            return "For those with basic knowledge"
        case .advanced:
            return "Challenge yourself with complex descriptions"
        }
    }
    
    var color: String {
        switch self {
        case .beginner:
            return "green"
        case .intermediate:
            return "orange"
        case .advanced:
            return "red"
        }
    }
}
