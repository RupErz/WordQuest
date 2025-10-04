//
//  ImagePreviewView.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import SwiftUI

struct ImagePreviewView: View {
    let selectedPhoto: PhotoData
    var onAnalyze: () -> Void
    var onBack: () -> Void
    
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
                    VStack(spacing: 10) {
                        Text("Preview Your Photo")
                            .font(.extraLargeTitle)
                            .fontWeight(.bold)
                        
                        Text("Ready to create your language learning question?")
                            .font(.title2)
                            .opacity(0.8)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    // Image Preview - Full Width
                    if let uiImage = selectedPhoto.thumbnail {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 500)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(radius: 15)
                            .padding(.horizontal, 20)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.2))
                            .frame(maxWidth: .infinity, maxHeight: 500)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                            )
                            .padding(.horizontal, 20)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 20) {
                        Button(action: onAnalyze) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .font(.title2)
                                Text("Analyze with AI")
                                    .font(.title2)
                                    .fontWeight(.semibold)
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
                        .buttonStyle(.borderedProminent)
                        
                        Button(action: onBack) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Choose Different Photo")
                            }
                            .foregroundColor(.blue)
                            .font(.headline)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
    }
}

// ScaleButtonStyle moved to ObjectDetectionView to avoid duplication

#Preview {
    ImagePreviewView(
        selectedPhoto: PhotoData(
            assetIdentifier: "test",
            thumbnail: nil,
            creationDate: Date(),
            isSelected: false
        ),
        onAnalyze: {},
        onBack: {}
    )
}
