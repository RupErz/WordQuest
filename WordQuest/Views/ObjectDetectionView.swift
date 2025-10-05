//
//  ObjectDetectionView.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import SwiftUI
import Photos

struct ObjectDetectionView: View {
    @StateObject private var backendService = BackendService()
    @EnvironmentObject var userPreferences: UserPreferences
    let selectedPhoto: PhotoData?
    @State private var detectedObjects: [DetectedObject] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isDetecting = false
    @State private var detectionComplete = false
    @State private var backendAnalysis: BackendAnalysis?
    var onContinue: ((String, String, String, String, String) -> Void)? // question, answer, translation, nativeLanguage, targetLanguage
    
    var body: some View {
        ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        Text("AI Object Detection")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text("Our AI is analyzing your photo to identify objects for language practice")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    // Image Display
                    if let photo = selectedPhoto, let uiImage = photo.thumbnail {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 400)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                            .shadow(radius: 10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 400)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                    
                    // Detection Status
                    if isDetecting {
                        DetectionProgressView()
                    } else if detectionComplete {
                        BackendResultsView(
                            analysis: backendAnalysis,
                            objects: detectedObjects,
                            onContinue: {
                                // Pass the question data to the parent
                                if let analysis = backendAnalysis {
                                    onContinue?(analysis.question, analysis.answer, analysis.translation, analysis.native_language, analysis.target_language)
                                }
                            }
                        )
                    } else {
                        StartDetectionView {
                            startObjectDetection()
                        }
                    }
                }
            .onAppear {
                loadSelectedPhoto()
            }
            .alert("Detection Error", isPresented: $showingError) {
                Button("Try Again") {
                    startObjectDetection()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadSelectedPhoto() {
        print("📸 Loading selected photo...")
        if let photo = selectedPhoto {
            print("📸 Using passed photo: \(photo.assetIdentifier)")
        } else {
            print("❌ No photo passed to ObjectDetectionView")
        }
    }
    
    private func startObjectDetection() {
        guard let photo = selectedPhoto, let image = photo.thumbnail else { return }
        
        isDetecting = true
        detectionComplete = false
        detectedObjects = []
        
        // Get user's language preferences
        let nativeLanguage = userPreferences.nativeLanguage?.name ?? "English"
        let targetLanguage = userPreferences.targetLanguage?.name ?? "Spanish"
        
        print("🌍 Using languages - Native: \(nativeLanguage), Target: \(targetLanguage)")
        
        Task {
            do {
                // Use backend service for personalized language learning
                let analysis = try await backendService.analyzeImage(image, nativeLanguage: nativeLanguage, targetLanguage: targetLanguage)
                
                await MainActor.run {
                    self.backendAnalysis = analysis
                    // Create mock objects from analysis for now
                    self.detectedObjects = createObjectsFromAnalysis(analysis.question)
                    self.isDetecting = false
                    self.detectionComplete = true
                }
            } catch {
                await MainActor.run {
                    self.isDetecting = false
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                }
            }
        }
    }
    
    private func createObjectsFromAnalysis(_ analysis: String) -> [DetectedObject] {
        // For now, create mock objects. In the future, you could parse the analysis
        // to extract specific objects mentioned in the text
        return [
            DetectedObject(name: "analyzed scene", confidence: 0.95, category: .other),
            DetectedObject(name: "detailed description", confidence: 0.90, category: .other)
        ]
    }
}

struct StartDetectionView: View {
    var onStartDetection: () -> Void
    
    var body: some View {
        VStack {
            Text("Ready to detect objects?")
                .font(.title2)
                .padding(.bottom, 10)
            
            Button("Start Detection") {
                onStartDetection()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .glassBackgroundEffect()
    }
}

struct DetectionProgressView: View {
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
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
                
                Image(systemName: "eye.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text("Analyzing Photo...")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Identifying objects and their locations")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            animationPhase = 1
        }
    }
}

struct BackendResultsView: View {
    let analysis: BackendAnalysis?
    let objects: [DetectedObject]
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Success Header
            VStack(spacing: 10) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Language Learning Question Ready!")
                    .font(.system(size: 20, weight: .bold))
                
                Text("Personalized for your language learning")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            // Language Learning Question
            if let analysis = analysis {
                ScrollView {
                    VStack(alignment: .center, spacing: 15) {
                        Text("🎓 Your Fill-in-the-Blank Question")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Text(analysis.question)
                            .font(.body)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        
                        HStack {
                            Text("🌍 Native: \(analysis.native_language)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("🎯 Target: \(analysis.target_language)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 300)
            }
            
            // Continue Button
            Button(action: onContinue) {
                HStack {
                    Text("Continue to Practice")
                        .font(.system(size: 18, weight: .semibold))
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 40)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}


#Preview(windowStyle: .automatic) {
    ObjectDetectionView(selectedPhoto: nil, onContinue: { _, _, _, _, _ in })
        .environmentObject(UserPreferences())
}
