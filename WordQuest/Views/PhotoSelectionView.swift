//
//  PhotoSelectionView.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import SwiftUI
import Photos

struct PhotoSelectionView: View {
    @StateObject private var photoLibraryService = PhotoLibraryService()
    @EnvironmentObject var userPreferences: UserPreferences
    var onPhotoSelected: ((PhotoData) -> Void)?
    
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
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 15) {
                        Text("Choose a Photo")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text("Select any photo from your library to practice describing")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Photo Grid
                    if photoLibraryService.authorizationStatus == .authorized || photoLibraryService.authorizationStatus == .limited {
                        PhotoGridView(
                            photos: photoLibraryService.photos,
                            selectedPhoto: photoLibraryService.selectedPhoto,
                            onPhotoSelected: { photo in
                                photoLibraryService.selectPhoto(photo)
                                onPhotoSelected?(photo) // Pass the photo to ContentView
                            }
                        )
                    } else {
                        PermissionRequestView(
                            authorizationStatus: photoLibraryService.authorizationStatus,
                            onRequestPermission: {
                                Task {
                                    await photoLibraryService.requestPermission()
                                }
                            }
                        )
                    }
                }
            }
            .onAppear {
                if photoLibraryService.authorizationStatus == .authorized || photoLibraryService.authorizationStatus == .limited {
                    photoLibraryService.loadPhotos()
                }
            }
    }
}

struct PhotoGridView: View {
    let photos: [PhotoData]
    let selectedPhoto: PhotoData?
    let onPhotoSelected: (PhotoData) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(photos) { photo in
                    PhotoThumbnailView(
                        photo: photo,
                        isSelected: selectedPhoto?.id == photo.id,
                        onTap: {
                            onPhotoSelected(photo)
                        }
                    )
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

struct PhotoThumbnailView: View {
    let photo: PhotoData
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let thumbnail = photo.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
                
                // Selection indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 150, height: 150)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                                .font(.title3)
                        }
                    }
                    .padding(8)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct PermissionRequestView: View {
    let authorizationStatus: PHAuthorizationStatus
    let onRequestPermission: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Photo Library Access")
                    .font(.system(size: 24, weight: .bold))
                
                Text("LanguageVision needs access to your photo library to let you select images for language practice.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            if authorizationStatus == .notDetermined {
                Button(action: onRequestPermission) {
                    HStack {
                        Image(systemName: "lock.open")
                        Text("Grant Access")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 40)
            } else if authorizationStatus == .denied {
                VStack(spacing: 15) {
                    Text("Access Denied")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                    
                    Text("Please enable photo library access in Settings to continue.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
            }
            
            Spacer()
        }
    }
}

struct PhotoPreviewView: View {
    let photo: PhotoData
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @State private var fullSizeImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let fullSizeImage = fullSizeImage {
                    Image(uiImage: fullSizeImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .ignoresSafeArea()
                } else if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading full size image...")
                            .foregroundColor(.white)
                            .padding(.top, 20)
                    }
                }
                
                // Bottom overlay with actions
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Use this photo for practice?")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            Button(action: onCancel) {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.gray.opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                            }
                            
                            Button(action: onConfirm) {
                                Text("Use This Photo")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Photo Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
        .onAppear {
            loadFullSizeImage()
        }
    }
    
    private func loadFullSizeImage() {
        Task {
            let photoLibraryService = PhotoLibraryService()
            let image = await photoLibraryService.getFullSizeImage(for: photo)
            await MainActor.run {
                self.fullSizeImage = image
                self.isLoading = false
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    PhotoSelectionView()
}
