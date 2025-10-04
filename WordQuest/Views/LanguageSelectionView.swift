//
//  LanguageSelectionView.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var showingDifficultySelection = false
    var onLanguageSelected: (() -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            Text("Choose Your Languages")
                                .font(.system(size: 32, weight: .bold))
                                .multilineTextAlignment(.center)
                            
                            Text("Select your native language and the language you want to learn")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        // Native Language Selection
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .foregroundColor(.green)
                                Text("Native Language")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            
                            if let nativeLanguage = userPreferences.nativeLanguage {
                                SelectedLanguageCard(
                                    language: nativeLanguage,
                                    isNative: true,
                                    onRemove: {
                                        userPreferences.nativeLanguage = nil
                                    }
                                )
                            } else {
                                LanguageGrid(
                                    languages: Language.supportedLanguages,
                                    selectedLanguage: userPreferences.nativeLanguage,
                                    onLanguageSelected: { language in
                                        userPreferences.nativeLanguage = language
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Target Language Selection
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "target")
                                    .foregroundColor(.blue)
                                Text("Target Language")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            
                            if let targetLanguage = userPreferences.targetLanguage {
                                SelectedLanguageCard(
                                    language: targetLanguage,
                                    isNative: false,
                                    onRemove: {
                                        userPreferences.targetLanguage = nil
                                    }
                                )
                            } else {
                                LanguageGrid(
                                    languages: Language.supportedLanguages.filter { language in
                                        language != userPreferences.nativeLanguage
                                    },
                                    selectedLanguage: userPreferences.targetLanguage,
                                    onLanguageSelected: { language in
                                        userPreferences.targetLanguage = language
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Continue Button
                        if userPreferences.canProceed {
                            Button(action: {
                                showingDifficultySelection = true
                            }) {
                                HStack {
                                    Text("Continue")
                                        .font(.system(size: 20, weight: .semibold))
                                    Image(systemName: "arrow.right")
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
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("Language Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingDifficultySelection) {
            DifficultySelectionView(userPreferences: userPreferences)
        }
    }
}

struct SelectedLanguageCard: View {
    let language: Language
    let isNative: Bool
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(language.flag)
                        .font(.system(size: 30))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(language.name)
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text(isNative ? "Your native language" : "Language to learn")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct LanguageGrid: View {
    let languages: [Language]
    let selectedLanguage: Language?
    let onLanguageSelected: (Language) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(languages) { language in
                LanguageCard(
                    language: language,
                    isSelected: selectedLanguage?.id == language.id,
                    onTap: {
                        onLanguageSelected(language)
                    }
                )
            }
        }
    }
}

struct LanguageCard: View {
    let language: Language
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(language.flag)
                    .font(.system(size: 40))
                
                Text(language.name)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                isSelected ? 
                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                LinearGradient(colors: [.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DifficultySelectionView: View {
    @ObservedObject var userPreferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDifficulty: DifficultyLevel = .beginner
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Text("Choose Your Level")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us provide the right level of feedback for your practice")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Difficulty Options
                VStack(spacing: 15) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                        DifficultyCard(
                            difficulty: difficulty,
                            isSelected: selectedDifficulty == difficulty,
                            onTap: {
                                selectedDifficulty = difficulty
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Start Button
                Button(action: {
                    userPreferences.difficultyLevel = selectedDifficulty
                    userPreferences.hasCompletedOnboarding = true
                    dismiss()
                    // Trigger navigation to photo selection
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // This will be handled by the parent view
                    }
                }) {
                    HStack {
                        Text("Start Learning")
                            .font(.system(size: 20, weight: .semibold))
                        Image(systemName: "arrow.right")
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
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            .navigationTitle("Difficulty")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DifficultyCard: View {
    let difficulty: DifficultyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(difficulty.description)
                        .font(.system(size: 14))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                isSelected ?
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(
                    colors: [.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview(windowStyle: .automatic) {
    LanguageSelectionView()
}
