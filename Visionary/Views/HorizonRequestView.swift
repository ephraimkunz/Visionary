//
//  HorizonRequestView.swift
//  Visionary
//
//  Created by Ephraim Kunz on 11/4/24.
//

import SwiftUI
import Vision
import OSLog

struct HorizonRequestView: View {
    let requestType: RequestType
    
    @Environment(PhotoModel.self) private var photoModel
    @Environment(\.displayScale) private var displayScale
    
    @State private var observation: HorizonObservation?
    @State private var imagePosition = CGRect()
    
    private let logger = Logger(subsystem: "views", category: "HorizonRequestView")
    
    var body: some View {
        ZStack {
            Image(platformImage: photoModel.photo)
                .resizable()
                .scaledToFit()
                .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .named("contentView")) }, action: { imagePosition = $0 })
            
            if let observation {
                VStack {
                    Spacer()
                    Rectangle()
                        .transform(CGAffineTransform(rotationAngle: observation.angle.value))
                        .foregroundStyle(Color.red)
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                    Spacer()
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
    }
    
    func updateObservations(photo: PlatformImage) async {
        do {
            let observation = try await requestType.performHorizonRequest(on: photo.cgImage!)
            
            Task { @MainActor in
                self.observation = observation
            }
        } catch {
            logger.error("Error performing \(requestType.title) request: \(error)")
        }
    }
}
