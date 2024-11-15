//
//  ClassificationViews.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/12/24.
//

import SwiftUI
import Vision
import OSLog

struct ClassificationRequestView: View {
    let requestType: RequestType
    
    @Environment(PhotoModel.self) private var photoModel
    @State private var observations: [ClassificationObservation] = []
    
    private let logger = Logger(subsystem: "views", category: "ClassificationRequestView")
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(platformImage: photoModel.photo)
                .resizable()
                .scaledToFit()
            
            List {
                ForEach(observations, id: \.uuid) { observation in
                    VStack(alignment: .leading) {
                        Text("**Identifier**: \(observation.identifier)")
                        Text("**Confidence**: \(observation.confidence)")
                    }
                }
            }
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
            let observations = try await requestType.performClassificationRequest(on: photo.cgImage!)
                .filter { $0.hasMinimumPrecision(0.1, forRecall: 0.5) }
            
            Task { @MainActor in
                self.observations = observations
            }
        } catch {
            logger.error("Error performing \(requestType.title) request: \(error)")
        }
    }
}
