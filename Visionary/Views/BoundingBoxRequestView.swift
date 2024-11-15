//
//  BoundingBoxViews.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/12/24.
//

import SwiftUI
import Vision
import OSLog

struct BoundingBoxRequestView: View {
    let requestType: RequestType
    
    private let logger = Logger(subsystem: "views", category: "BoundingBoxRequestView")

    @State private var observations: [any VisionObservation & BoundingBoxProviding] = []
    @State private var imagePosition = CGRect()
    @State private var upperBodyOnly = true
    @Environment(PhotoModel.self) private var photoModel
    
    var body: some View {
        VStack {
            ZStack {
                Image(platformImage: photoModel.photo)
                    .resizable()
                    .scaledToFit()
                    .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .named("contentView")) }, action: { imagePosition = $0 })
                
                ForEach(observations, id: \.uuid) { observation in
                    if (observation as? QuadrilateralProviding) != nil {
                        Quadrilateral(observation: observation)
                            .stroke(Color.red, lineWidth: 3)
                            .frame(width: imagePosition.width, height: imagePosition.height)
                            .position(x: imagePosition.origin.x + imagePosition.width / 2, y: imagePosition.origin.y + imagePosition.height / 2)
                            .overlay(alignment: .topTrailing) {
                                let imageCoords: CGRect = observation.boundingBox.toImageCoordinates(imagePosition.size, origin: .upperLeft)
                                let frame = imageCoords.offsetBy(dx: imagePosition.origin.x, dy: imagePosition.origin.y)
                                
                                Rectangle()
                                    .stroke(Color.clear, lineWidth: 0)
                                    .overlay(alignment: .topTrailing) {
                                        ObservationDetails {
                                            requestType.detailView(observation: observation)
                                        }
                                    }
                                    .frame(width: frame.width, height: frame.height)
                                    .position(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
                            }
                    } else {
                        let imageCoords: CGRect = observation.boundingBox.toImageCoordinates(imagePosition.size, origin: .upperLeft)
                        let frame = imageCoords.offsetBy(dx: imagePosition.origin.x, dy: imagePosition.origin.y)
                        
                        Rectangle()
                            .stroke(Color.red, lineWidth: 3)
                            .overlay(alignment: .topTrailing) {
                                ObservationDetails {
                                    requestType.detailView(observation: observation)
                                }
                            }
                            .frame(width: frame.width, height: frame.height)
                            .position(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
                    }
                    
                    if let observation = observation as? FaceObservation, let landmarks = observation.landmarks?.allPoints.pointsInImageCoordinates(imagePosition.size, origin: .upperLeft) {
                        ForEach(landmarks, id: \.self) { landmark in
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 3, height: 3)
                                .position(x: landmark.x, y: landmark.y)
                                .offset(x: imagePosition.origin.x, y: imagePosition.origin.y)
                        }
                    }
                }
            }
            
            if case .detectHumanRectangles = requestType {
                HStack {
                    Toggle("Upper Body Only", isOn: $upperBodyOnly)
                    
                    Spacer(minLength: 0)
                }
                .padding()
            }
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
        .onChange(of: requestType, { oldValue, newValue in
            Task {
                await updateObservations(photo: photoModel.photo)
            }
        })
        .onChange(of: upperBodyOnly, { oldValue, newValue in
            Task {
                await updateObservations(photo: photoModel.photo)
            }
        })
    }
    
    func updateObservations(photo: PlatformImage) async {
        do {
            let newObservations: [any BoundingBoxProviding & VisionObservation]

            if case .detectHumanRectangles = requestType {
                newObservations = try await requestType.performHumanRectanglesRequest(on: photo.cgImage!, upperBodyOnly: upperBodyOnly)
            } else {
                newObservations = try await requestType.performRequest(on: photo.cgImage!)
            }
            
            Task { @MainActor in
                self.observations = newObservations
            }
        } catch {
            logger.error("Error performing \(requestType.title) request: \(error)")
        }
    }
}

struct Quadrilateral: Shape {
    let observation: any VisionObservation
    func path(in rect: CGRect) -> Path {
        Path { path in
            if let observation = observation as? QuadrilateralProviding {
                path.move(to: observation.topLeft.toImageCoordinates(rect.size, origin: .upperLeft));
                path.addLine(to: observation.topRight.toImageCoordinates(rect.size, origin: .upperLeft))
                path.addLine(to: observation.bottomRight.toImageCoordinates(rect.size, origin: .upperLeft))
                path.addLine(to: observation.bottomLeft.toImageCoordinates(rect.size, origin: .upperLeft))
                path.addLine(to: observation.topLeft.toImageCoordinates(rect.size, origin: .upperLeft))
            }
        }
        
    }
}

struct ObservationDetails<Content>: View where Content: View {
    @ViewBuilder let content: () -> Content
    
    private let offset: CGFloat = 18
    @State private var showingPopover = false

    var body: some View {
        Button {
            showingPopover = true
        } label: {
            Image(systemName: "info.circle")
        }
        .popover(isPresented: $showingPopover) {
            content()
                .padding()
        }
        .tint(Color.red)
        .offset(x: offset, y: -offset)
    }
}
