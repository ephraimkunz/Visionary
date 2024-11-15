//
//  OverlayedImageRequestView.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/12/24.
//

import SwiftUI
import Vision
import OSLog

struct OverlayedImageRequestView: View {
    let requestType: RequestType
    
    @Environment(PhotoModel.self) private var photoModel
    @Environment(\.displayScale) private var displayScale
    
    @State private var observation: PixelBufferObservation?
    @State private var opacityValue = 1.0
    @State private var imagePosition = CGRect()
    
    private let logger = Logger(subsystem: "views", category: "OverlayedImageRequestView")
    
    var body: some View {
        VStack {
            ZStack {
                Image(platformImage: photoModel.photo)
                    .resizable()
                    .scaledToFit()
                    .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .named("contentView")) }, action: {
                        imagePosition = $0
                    })
                
                if let observation, let cgImage = try? observation.cgImage {
                    Image(cgImage, scale: displayScale, orientation: photoModel.photo.orientation, label: Text(""))
                        .resizable()
                        .frame(width: imagePosition.width, height: imagePosition.height)
                        .opacity(opacityValue)
                }
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Segmentation mask opacity")
                
                Slider(value: $opacityValue, minimumValueLabel: Text("0"), maximumValueLabel: Text("1")) {
                    Text("Segmentation mask opacity")
                }
                .labelsHidden()
            }
            .padding(.horizontal)
            .opacity((try? observation?.cgImage) == nil ? 0 : 1)
        }
        .coordinateSpace(name: "contentView")
        .task {
            await updateObservations(photo: photoModel.photo)
        }
        .onChange(of: photoModel.photo, { oldValue, newValue in
            Task {
                await updateObservations(photo: newValue)
            }
        })
    }
    
    func updateObservations(photo: PlatformImage) async {
        do {
            let observation = try await requestType.performSegmentationRequest(on: photo.cgImage!)
            
            Task { @MainActor in
                withAnimation {
                    self.observation = observation
                }
            }
        } catch {
            logger.error("Error performing \(requestType.title) request: \(error)")
        }
    }
}
