//
//  SpeechRecordingView.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import SwiftUI

struct SpeechRecordingView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var isRecording = false
    @State private var recordedText = ""
    @State private var showingFeedback = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.1),
                        Color.blue.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        Text("Practice Speaking")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text("Describe the objects you see in your target language")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    // Recording Interface
                    VStack(spacing: 20) {
                        if isRecording {
                            RecordingView()
                        } else {
                            ReadyToRecordView()
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Instructions
                    VStack(spacing: 10) {
                        Text("Instructions:")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("• Look at the detected objects")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text("• Describe what you see in \(userPreferences.targetLanguage?.name ?? "your target language")")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text("• Speak clearly and take your time")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    Spacer()
                }
            }
            .navigationTitle("Speech Practice")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ReadyToRecordView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Ready to Record")
                .font(.system(size: 20, weight: .semibold))
            
            Text("Tap the button below to start recording")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                // Start recording
            }) {
                HStack {
                    Image(systemName: "mic.fill")
                    Text("Start Recording")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.blue, .green],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

struct RecordingView: View {
    @State private var animationPhase = 0
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.red.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(Double(animationPhase) * 360))
                    .animation(
                        .linear(duration: 1).repeatForever(autoreverses: false),
                        value: animationPhase
                    )
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("Recording...")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Speak clearly and describe what you see")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                // Stop recording
            }) {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("Stop Recording")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.red, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .onAppear {
            animationPhase = 1
        }
    }
}

#Preview(windowStyle: .automatic) {
    SpeechRecordingView()
        .environmentObject(UserPreferences())
}
