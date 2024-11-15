//
//  ImageExtensions.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/16/24.
//

import Foundation
import SwiftUI
import VideoToolbox

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage

#else
import AppKit
typealias PlatformImage = NSImage
#endif

#if canImport(UIKit)
extension UIImage.Orientation {
    func swiftUIImageOrientation() -> Image.Orientation {
        switch self {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .upMirrored:
            return .upMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        default:
            return .up
        }
    }
}

extension UIImage {
    var orientation: Image.Orientation {
        return self.imageOrientation.swiftUIImageOrientation()
    }
    
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        guard let cgImage = cgImage else {
            return nil
        }
        
        self.init(cgImage: cgImage)
    }
}
#else
extension NSImage {
    var orientation: Image.Orientation {
        return .up
    }
    
    var cgImage: CGImage? {
        return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        guard let cgImage = cgImage else {
            return nil
        }
        
        self.init(cgImage: cgImage, size: .zero)
    }
}
#endif

extension Image {
    init(platformImage: PlatformImage) {
#if canImport(UIKit)
        self.init(uiImage: platformImage)
#else
        self.init(nsImage: platformImage)
#endif
    }
}
