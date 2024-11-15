//
//  ContentView.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/11/24.
//

import SwiftUI
import Vision
import PhotosUI

struct ContentView: View {
    @Environment(PhotoModel.self) private var photoModel
    @State private var selectedRequestType: RequestType? = RequestCategory.allCases.sorted().first?.children.first
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showsPhotoPicker = false
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedRequestType) {
                ForEach(RequestCategory.allCases.sorted()) { category in
                    Section(category.title) {
                        ForEach(category.children) { requestType in
                            Text(requestType.title)
                        }
                    }
                }
            }
            .navigationTitle("Request Types")
        } detail: {
            if let selectedRequestType {
                Group {
                    switch selectedRequestType {
                    case .detectBarcodes, .detectDocumentSegmentation, .detectFaceRectangles, .detectFaceLandmarks, .detectFaceCaptureQuality, .detectHumanRectangles, .detectTextRectangles, .recognizeText:
                        BoundingBoxRequestView(requestType: selectedRequestType)
                    case .classifyImage:
                        ClassificationRequestView(requestType: selectedRequestType)
                    case .generatePersonSegmentation:
                        OverlayedImageRequestView(requestType: selectedRequestType)
                    case .generatePersonInstanceMask:
                        OverlayedImageInstanceRequestView(requestType: selectedRequestType)
                    case .calculateImageAestheticsScores:
                        ImageWithDetailInfoRequestView(requestType: selectedRequestType)
                    case .generateAttentionBasedSaliencyImage, .generateObjectnessBasedSaliencyImage:
                        HeapMapRequestView(requestType: selectedRequestType)
                    case .detectHumanBodyPose:
                        ImagePoseRequestView(requestType: selectedRequestType)
                    case .detectContours:
                        CountourPathRequestView(requestType: selectedRequestType)
                    case .detectHorizon:
                        HorizonRequestView(requestType: selectedRequestType)
                    }
                }
                .toolbar {
                    Menu {
                        Button {
                            showsPhotoPicker = true
                        } label: {
                            Label("Photo Library", systemImage: "photo")
                        }
                        
                        Button {
                            selectedPhoto = nil
                        } label: {
                            Label("Default Image", systemImage: "square")
                        }
                    } label: {
                        if selectedPhoto == nil {
                            Label("Default Image", systemImage: "square")
                        } else {
                            Label("Photo Library", systemImage: "photo")
                        }
                    }
                }
            }
        }
        .photosPicker(isPresented: $showsPhotoPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedRequestType) { oldValue, newValue in
            Task {
                await photoModel.updateModel(selectedPhoto: selectedPhoto, selectedRequestType: selectedRequestType)
            }
        }
        .onChange(of: selectedPhoto) { oldValue, newValue in
            Task {
                await photoModel.updateModel(selectedPhoto: selectedPhoto, selectedRequestType: selectedRequestType)
            }
        }
    }
}
