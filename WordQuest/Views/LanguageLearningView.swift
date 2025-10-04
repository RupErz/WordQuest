//
//  LanguageLearningView.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import SwiftUI

struct LanguageLearningView: View {
    let selectedPhoto: PhotoData
    let question: String
    let nativeLanguage: String
    let targetLanguage: String
    var onStartRecording: () -> Void
    
    @State private var isRecording = false
    
    var body: some View {
        ZStack {
            // Background Image
            if let uiImage = selectedPhoto.thumbnail {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                // Dark overlay for text readability
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
            } else {
                // Fallback background
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            VStack {
                Spacer()
                
                // Language Learning Question
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🎓 Your Language Learning Question")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("🌍 \(nativeLanguage)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("→")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            Text("🎯 \(targetLanguage)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    // Question Display
                    VStack(spacing: 15) {
                        Text(question)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Instructions
                    Text("Look at the image and fill in the blank with a word in \(targetLanguage)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Start Button
                    Button(action: {
                        // Start the learning session
                        onStartRecording()
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Start Learning")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.green)
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Speech Recording Button
                VStack(spacing: 15) {
                    Button(action: {
                        isRecording.toggle()
                        onStartRecording()
                    }) {
                        HStack {
                            Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.title2)
                            Text(isRecording ? "Stop Recording" : "Start Recording")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(isRecording ? Color.red : Color.blue)
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Text("Tap to record your answer in \(targetLanguage)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
}

// ScaleButtonStyle moved to ObjectDetectionView to avoid duplication

#Preview {
    LanguageLearningView(
        selectedPhoto: PhotoData(
            assetIdentifier: "test",
            thumbnail: nil,
            creationDate: Date(),
            isSelected: false
        ),
        question: "There is a tall _____ in the middle of the picture",
        nativeLanguage: "English",
        targetLanguage: "German",
        onStartRecording: {}
    )
}
