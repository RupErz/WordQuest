//
//  ContentView.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userPreferences = UserPreferences()
    @State private var currentView: AppView = .landing
    @State private var selectedPhoto: PhotoData?
    @State private var generatedQuestion: String = ""
    @State private var correctAnswer: String = ""
    @State private var translation: String = ""
    @State private var nativeLanguage: String = "English"
    @State private var targetLanguage: String = "Spanish"
    
    enum AppView {
        case landing
        case languageSelection
        case photoSelection
        case imagePreview
        case objectDetection
        case languageLearning
        case speechRecording
        case feedback
    }
    
    var body: some View {
        ZStack {
            switch currentView {
            case .landing:
                LandingView(onStartLearning: {
                    currentView = .languageSelection
                })
                    .onAppear {
                        if userPreferences.hasCompletedOnboarding {
                            currentView = .photoSelection
                        }
                    }
                
            case .languageSelection:
                LanguageSelectionView(onLanguageSelected: {
                    currentView = .photoSelection
                })
                    .onAppear {
                        if userPreferences.hasCompletedOnboarding {
                            currentView = .photoSelection
                        }
                    }
                    .onChange(of: userPreferences.hasCompletedOnboarding) { _, newValue in
                        if newValue {
                            currentView = .photoSelection
                        }
                    }
                
            case .photoSelection:
                PhotoSelectionView(onPhotoSelected: { photo in
                    selectedPhoto = photo
                    currentView = .imagePreview
                })
                
            case .imagePreview:
                if let photo = selectedPhoto {
                    ImagePreviewView(
                        selectedPhoto: photo,
                        onAnalyze: {
                            currentView = .objectDetection
                        },
                        onBack: {
                            currentView = .photoSelection
                        }
                    )
                }
                
            case .objectDetection:
                ObjectDetectionView(selectedPhoto: selectedPhoto, onContinue: { question, answer, translationText, native, target in
                    generatedQuestion = question
                    correctAnswer = answer
                    translation = translationText
                    nativeLanguage = native
                    targetLanguage = target
                    currentView = .languageLearning
                })
                
            case .languageLearning:
                if let photo = selectedPhoto {
                    LanguageLearningView(
                        selectedPhoto: photo,
                        question: generatedQuestion.isEmpty ? "Loading your personalized question..." : generatedQuestion,
                        nativeLanguage: nativeLanguage,
                        targetLanguage: targetLanguage,
                        onStartRecording: {
                            currentView = .speechRecording
                        }
                    )
                }
                
            case .speechRecording:
                if let photo = selectedPhoto {
                    SpeechRecordingView(
                        selectedPhoto: photo,
                        question: generatedQuestion,
                        correctAnswer: correctAnswer,
                        translation: translation,
                        nativeLanguage: nativeLanguage,
                        targetLanguage: targetLanguage,
                        onBackToPhotoSelection: {
                            currentView = .photoSelection
                        }
                    )
                }
                
            case .feedback:
                // TODO: Implement FeedbackView
                Text("Feedback - Coming Soon")
                    .font(.title)
            }
        }
        .environmentObject(userPreferences)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
