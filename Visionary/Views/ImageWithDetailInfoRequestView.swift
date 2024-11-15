//
//  ImageWithDetailInfoRequestView.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/16/24.
//

import SwiftUI
import OSLog
import Vision

struct ImageWithDetailInfoRequestView: View {
    let requestType: RequestType
    
    @Environment(PhotoModel.self) private var photoModel
    @State private var observation: ImageAestheticsScoresObservation?
    
    private let logger = Logger(subsystem: "views", category: "ImageWithDetailInfoRequestView")
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(platformImage: photoModel.photo)
                .resizable()
                .scaledToFit()
            
            HStack {
                VStack(alignment: .leading) {
                    if let observation {
                        Text("**Overall Score**: \(observation.overallScore)")
                        Text(.init("**Is Utility**: \(observation.isUtility)"))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding()
        }
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
            let observation = try await requestType.performAestheticScoresRequest(on: photo.cgImage!)
            
            Task { @MainActor in
                self.observation = observation
            }
        } catch {
            logger.error("Error performing \(requestType.title) request: \(error)")
        }
    }
}
