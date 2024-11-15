//
//  HeatMapRequestView.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/17/24.
//

import SwiftUI
import Vision
import OSLog

struct HeapMapRequestView: View {
    let requestType: RequestType
    
    @Environment(PhotoModel.self) private var photoModel
    @Environment(\.displayScale) private var displayScale
    
    @State private var observation: SaliencyImageObservation?
    @State private var opacityValue = 1.0
    @State private var imagePosition = CGRect()
    
    private let logger = Logger(subsystem: "views", category: "HeatMapRequestView")
    
    var body: some View {
        VStack {
            ZStack {
                Image(platformImage: photoModel.photo)
                    .resizable()
                    .scaledToFit()
                    .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .named("contentView")) }, action: {
                        imagePosition = $0
                    })
                
                if let observation, let cgImage = try? observation.heatMap.cgImage {
                    Image(cgImage, scale: displayScale, orientation: photoModel.photo.orientation, label: Text(""))
                        .resizable()
                        .frame(width: imagePosition.width, height: imagePosition.height)
                        .opacity(opacityValue)
                    
                    ForEach(observation.salientObjects, id: \.uuid) { object in
                        Quadrilateral(observation: object)
                            .stroke(Color.red, lineWidth: 3)
                            .frame(width: imagePosition.width, height: imagePosition.height)
                            .position(x: imagePosition.origin.x + imagePosition.width / 2, y: imagePosition.origin.y + imagePosition.height / 2)
                            .overlay(alignment: .topTrailing) {
                                let imageCoords: CGRect = object.boundingBox.toImageCoordinates(imagePosition.size, origin: .upperLeft)
                                let frame = imageCoords.offsetBy(dx: imagePosition.origin.x, dy: imagePosition.origin.y)
                                
                                Rectangle()
                                    .stroke(Color.clear, lineWidth: 0)
                                    .overlay(alignment: .topTrailing) {
                                        ObservationDetails {
                                            requestType.detailView(observation: object)
                                        }
                                    }
                                    .frame(width: frame.width, height: frame.height)
                                    .position(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
                            }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Heat map opacity")
                
                Slider(value: $opacityValue, minimumValueLabel: Text("0"), maximumValueLabel: Text("1")) {
                    Text("Heat map opacity")
                }
                .labelsHidden()
            }
            .padding(.horizontal)
            .opacity((try? observation?.heatMap.cgImage) == nil ? 0 : 1)
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
        .onChange(of: requestType) { oldValue, newValue in
            Task {
                await updateObservations(photo: photoModel.photo)
            }
        }
    }
    
    func updateObservations(photo: PlatformImage) async {
        do {
            let observation = try await requestType.performSaliencyRequest(on: photo.cgImage!)
            
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
