//
//  PhotoModel.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/12/24.
//

import Observation
import Foundation
import PhotosUI
import SwiftUI

@Observable
class PhotoModel {
    init() {
        self.photo = PlatformImage(named: RequestCategory.allCases.sorted()[0].children[0].defaultImageName)!
    }
    
    var photo: PlatformImage
    
    @MainActor
    func updateModel(selectedPhoto: PhotosPickerItem?, selectedRequestType: RequestType?) async {
        var updatedPhoto: PlatformImage?
        
        if let selectedPhoto {
            if let data = try? await selectedPhoto.loadTransferable(type: PhotoModelImage.self)?.data {
                updatedPhoto = PlatformImage(data: data)
            }
        }
        
        if updatedPhoto == nil, let selectedRequestType {
            updatedPhoto = PlatformImage(named: selectedRequestType.defaultImageName)
        }
        
        if let updatedPhoto {
            self.photo = updatedPhoto
        }
    }
}

struct PhotoModelImage: Transferable {
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            return PhotoModelImage(data: data)
        }
    }
}

enum TransferError: Error {
    case importFailed
}

