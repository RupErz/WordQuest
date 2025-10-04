//
//  PhotoLibraryService.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import Foundation
import Photos
import UIKit
import Combine

class PhotoLibraryService: NSObject, ObservableObject {
    @Published var photos: [PhotoData] = []
    @Published var selectedPhoto: PhotoData?
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let imageManager = PHCachingImageManager()
    
    override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestPermission() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        DispatchQueue.main.async {
            self.authorizationStatus = status
            if status == .authorized || status == .limited {
                self.loadPhotos()
            }
        }
    }
    
    func loadPhotos() {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 50 // Limit for performance
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var photoDataArray: [PhotoData] = []
        
        assets.enumerateObjects { asset, _, _ in
            let photoData = PhotoData(
                assetIdentifier: asset.localIdentifier,
                creationDate: asset.creationDate
            )
            photoDataArray.append(photoData)
        }
        
        DispatchQueue.main.async {
            self.photos = photoDataArray
            self.isLoading = false
        }
        
        // Load thumbnails asynchronously
        loadThumbnails(for: photoDataArray)
    }
    
    private func loadThumbnails(for photos: [PhotoData]) {
        let assetIdentifiers = photos.map { $0.assetIdentifier }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        
        let thumbnailSize = CGSize(width: 200, height: 200)
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic
        requestOptions.resizeMode = .exact
        
        var photoIndex = 0
        assets.enumerateObjects { asset, _, _ in
            self.imageManager.requestImage(
                for: asset,
                targetSize: thumbnailSize,
                contentMode: .aspectFill,
                options: requestOptions
            ) { image, _ in
                DispatchQueue.main.async {
                    if photoIndex < self.photos.count {
                        let updatedPhoto = PhotoData(
                            assetIdentifier: self.photos[photoIndex].assetIdentifier,
                            thumbnail: image,
                            creationDate: self.photos[photoIndex].creationDate,
                            isSelected: self.photos[photoIndex].isSelected
                        )
                        self.photos[photoIndex] = updatedPhoto
                    }
                }
                photoIndex += 1
            }
        }
    }
    
    func selectPhoto(_ photo: PhotoData) {
        // Deselect all other photos
        photos = photos.map { photoData in
            PhotoData(
                assetIdentifier: photoData.assetIdentifier,
                thumbnail: photoData.thumbnail,
                creationDate: photoData.creationDate,
                isSelected: photoData.assetIdentifier == photo.assetIdentifier
            )
        }
        
        selectedPhoto = photo
    }
    
    func getFullSizeImage(for photo: PhotoData) async -> UIImage? {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [photo.assetIdentifier], options: nil).firstObject else {
            return nil
        }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: requestOptions
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
