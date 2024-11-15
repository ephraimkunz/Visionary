//
//  ImagePoseRequestView.swift
//  Visionary
//
//  Created by Ephraim Kunz on 11/4/24.
//

import SwiftUI
import Vision
import OSLog

struct ImagePoseRequestView: View {
    let requestType: RequestType
    
    @Environment(PhotoModel.self) private var photoModel
    @State private var observations: [HumanBodyPoseObservation] = []
    @State private var imagePosition = CGRect()
    
    private let logger = Logger(subsystem: "views", category: "ImagePoseRequestView")
    
    func jointsForObservation(_ observation: HumanBodyPoseObservation) -> [Joint] {
        var joints = Array(observation.allJoints().values)
        if let leftHand = observation.leftHand {
            joints.append(contentsOf: leftHand.allJoints().values)
        }
        if let rightHand = observation.rightHand {
            joints.append(contentsOf: rightHand.allJoints().values)
        }
        return joints
    }
    
    var body: some View {
        ZStack {
            Image(platformImage: photoModel.photo)
                .resizable()
                .scaledToFit()
                .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .named("contentView")) }, action: { imagePosition = $0 })
            
            ForEach(observations, id: \.uuid) { observation in
                ForEach (jointsForObservation(observation), id: \.self) { joint in
                    let jointPos = joint.location.toImageCoordinates(imagePosition.size, origin: .upperLeft)
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 10, height: 10)
                        .overlay {
                            PoseJointDetail(joint: joint)
                        }
                        .position(x: jointPos.x, y: jointPos.y)
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
    }
    
    func updateObservations(photo: PlatformImage) async {
        do {
            let observations = try await requestType.performPoseRequest(on: photo.cgImage!)
            
            Task { @MainActor in
                self.observations = observations
            }
        } catch {
            logger.error("Error performing \(requestType.title) request: \(error)")
        }
    }
}

struct PoseJointDetail: View {
    let joint: Joint
    @State private var showingPopover = false

    var body: some View {
        Button {
            showingPopover = true
        } label: {
            Color.clear
        }
        .popover(isPresented: $showingPopover) {
            VStack(alignment: .leading) {
                Text("**Joint Name**: \(joint.jointName)")
                Text("**Confidence**: \(joint.confidence)")
            }
            .padding()
        }
    }
}
