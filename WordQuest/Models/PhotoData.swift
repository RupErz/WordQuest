//
//  PhotoData.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import Foundation
import UIKit

struct PhotoData: Identifiable, Hashable {
    let id = UUID()
    let assetIdentifier: String
    var thumbnail: UIImage?
    let creationDate: Date?
    let isSelected: Bool
    
    init(assetIdentifier: String, thumbnail: UIImage? = nil, creationDate: Date? = nil, isSelected: Bool = false) {
        self.assetIdentifier = assetIdentifier
        self.thumbnail = thumbnail
        self.creationDate = creationDate
        self.isSelected = isSelected
    }
}

struct DetectedObject: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let confidence: Double
    let category: ObjectCategory
    
    enum ObjectCategory: String, CaseIterable {
        case furniture = "Furniture"
        case electronics = "Electronics"
        case food = "Food"
        case decoration = "Decoration"
        case clothing = "Clothing"
        case nature = "Nature"
        case people = "People"
        case other = "Other"
        
        var color: String {
            switch self {
            case .furniture: return "brown"
            case .electronics: return "blue"
            case .food: return "orange"
            case .decoration: return "purple"
            case .clothing: return "pink"
            case .nature: return "green"
            case .people: return "yellow"
            case .other: return "gray"
            }
        }
        
        var icon: String {
            switch self {
            case .furniture: return "chair"
            case .electronics: return "tv"
            case .food: return "fork.knife"
            case .decoration: return "star"
            case .clothing: return "tshirt"
            case .nature: return "leaf"
            case .people: return "person"
            case .other: return "questionmark"
            }
        }
    }
}
