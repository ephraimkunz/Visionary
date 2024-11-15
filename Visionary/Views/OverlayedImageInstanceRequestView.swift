//
//  OverlayedImageInstanceRequestView.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/12/24.
//

import SwiftUI
import Vision
import OSLog

struct OverlayedImageInstanceRequestView: View {
    let requestType: RequestType
    
    @Environment(PhotoModel.self) private var photoModel
    @Environment(\.displayScale) private var displayScale
    
    @State private var observation: InstanceMaskObservation?
    @State private var numShown = 0.0
    @State private var imagePosition = CGRect()
    
    private let logger = Logger(subsystem: "views", category: "OverlayedImageInstanceRequestView")
    
    var body: some View {
        VStack {
            ZStack {
                if let observation {
                    let imageRequestHandler = ImageRequestHandler(photoModel.photo.cgImage!)
                    let visibleIndexes = IndexSet(0..<Int(numShown + 1))
                    
                    if let pixelBuffer = try? observation.generateMaskedImage(for: visibleIndexes, imageFrom: imageRequestHandler, croppedToInstancesExtent: false) {
                        if let uiImage = PlatformImage(pixelBuffer: pixelBuffer) {
                            Image(platformImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }
            
            let allIndexes = Double(observation?.allInstances.count ?? 1)
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Image instances shown")
                
                Slider(
                    value: $numShown,
                    in: 0...allIndexes,
                    step: 1
                ) {
                    Text("")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("\(allIndexes)")
                }
                .labelsHidden()
            }
            .padding(.horizontal)
            .opacity(observation == nil ? 0 : 1)
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
            let observation = try await requestType.performInstanceMaskRequest(on: photo.cgImage!)
            
            Task { @MainActor in
                self.observation = observation
            }
        } catch {
            logger.error("Error performing \(requestType.title) request: \(error)")
        }
    }
}
