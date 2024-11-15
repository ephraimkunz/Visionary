//
//  ContourPathRequestView.swift
//  Visionary
//
//  Created by Ephraim Kunz on 11/4/24.
//

import SwiftUI
import Vision
import OSLog

struct CountourPathRequestView: View {
    let requestType: RequestType
    
    private let logger = Logger(subsystem: "views", category: "ContourPathRequestView")

    @State private var observation: ContoursObservation?
    @State private var imagePosition = CGRect()
    @Environment(PhotoModel.self) private var photoModel
    
    var body: some View {
        VStack {
            ZStack {
                Image(platformImage: photoModel.photo)
                    .resizable()
                    .scaledToFit()
                    .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .named("contentView")) }, action: { imagePosition = $0 })
                
                if let observation {
                    Path(observation.normalizedPath)
                        .applying(CGAffineTransform(scaleX: imagePosition.width, y: imagePosition.height))
                        .applying(CGAffineTransform(1, 0, 0, -1, 0, imagePosition.height))
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.purple)
                        .offset(x: imagePosition.origin.x, y: imagePosition.origin.y)
                }
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
    }
    
    func updateObservations(photo: PlatformImage) async {
        do {
            let observation = try await requestType.performContoursRequest(on: photo.cgImage!)
            
            Task { @MainActor in
                self.observation = observation
            }
        } catch {
            logger.error("Error performing \(requestType.title) request: \(error)")
        }
    }
}
