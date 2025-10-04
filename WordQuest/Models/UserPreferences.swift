//
//  UserPreferences.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import Foundation
import Combine

class UserPreferences: ObservableObject {
    @Published var nativeLanguage: Language?
    @Published var targetLanguage: Language?
    @Published var difficultyLevel: DifficultyLevel = .beginner
    @Published var hasCompletedOnboarding: Bool = false
    
    var isSetupComplete: Bool {
        return nativeLanguage != nil && targetLanguage != nil
    }
    
    var canProceed: Bool {
        return isSetupComplete && nativeLanguage != targetLanguage
    }
    
    func reset() {
        nativeLanguage = nil
        targetLanguage = nil
        difficultyLevel = .beginner
        hasCompletedOnboarding = false
    }
}
