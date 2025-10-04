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
    
    enum AppView {
        case landing
        case languageSelection
        case photoSelection
        case objectDetection
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
                LanguageSelectionView()
                    .onAppear {
                        if userPreferences.hasCompletedOnboarding {
                            currentView = .photoSelection
                        }
                    }
                
            case .photoSelection:
                PhotoSelectionView()
                
            case .objectDetection:
                // TODO: Implement ObjectDetectionView
                Text("Object Detection - Coming Soon")
                    .font(.title)
                
            case .speechRecording:
                // TODO: Implement SpeechRecordingView
                Text("Speech Recording - Coming Soon")
                    .font(.title)
                
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
