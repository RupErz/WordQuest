//
//  LandingView.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var showingHowItWorks = false
    @State private var animateGradient = false
    var onStartLearning: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.4),
                    Color.pink.opacity(0.3)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo and Branding
                VStack(spacing: 20) {
                    // App Icon
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 120, height: 120)
                            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 50, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    // App Name
                    Text("WordQuest")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Tagline
                    Text("Learn languages by describing your world")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 20) {
                    // Start Learning Button
                    Button(action: {
                        onStartLearning?()
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Start Learning")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // How It Works Button
                    Button(action: {
                        showingHowItWorks = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .font(.title3)
                            Text("How It Works")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Privacy Note
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.green)
                        Text("Privacy First")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Your photos are processed securely and never stored")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showingHowItWorks) {
            HowItWorksView()
        }
    }
}

struct HowItWorksView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text("How LanguageVision Works")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Steps
                    VStack(spacing: 25) {
                        HowItWorksStep(
                            number: "1",
                            title: "Choose Your Languages",
                            description: "Select your native language and the language you want to learn",
                            icon: "globe"
                        )
                        
                        HowItWorksStep(
                            number: "2",
                            title: "Pick a Photo",
                            description: "Choose any photo from your library that you'd like to describe",
                            icon: "photo"
                        )
                        
                        HowItWorksStep(
                            number: "3",
                            title: "AI Detects Objects",
                            description: "Our AI identifies all the objects in your photo to help guide your practice",
                            icon: "eye"
                        )
                        
                        HowItWorksStep(
                            number: "4",
                            title: "Describe & Practice",
                            description: "Speak your description in your target language and get instant feedback",
                            icon: "mic"
                        )
                        
                        HowItWorksStep(
                            number: "5",
                            title: "Learn & Improve",
                            description: "Receive detailed feedback on vocabulary, grammar, and pronunciation",
                            icon: "graduationcap"
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("How It Works")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HowItWorksStep: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 20) {
            // Step Number
            ZStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 50, height: 50)
                
                Text(number)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

// ScaleButtonStyle moved to ObjectDetectionView to avoid duplication

#Preview(windowStyle: .automatic) {
    LandingView()
}
