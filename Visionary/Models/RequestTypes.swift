//
//  RequestTypes.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/12/24.
//

import Vision
import SwiftUI

enum RequestCategory: CaseIterable, Identifiable {
    case stillImageAnalysis
    case imageSequenceAnalysis
    case aestheticsAnalysis
    case saliencyAnalysis
    case faceAndBodyDetection
    case bodyAndHandPoseDetection
    case textDetection
    case barcodeDetection
    case trajectoryContourHorizonDetection
    
    var id: Self {
        return self
    }
    
    var title: String {
        switch self {
        case .stillImageAnalysis:
            return "Still-image analysis"
        case .imageSequenceAnalysis:
            return "Image sequence analysis"
        case .barcodeDetection:
            return "Barcode detection"
        case .aestheticsAnalysis:
            return "Image aesthetics analysis"
        case .saliencyAnalysis:
            return "Saliency analysis"
        case .faceAndBodyDetection:
            return "Face and body detection"
        case .bodyAndHandPoseDetection:
            return "Body and hand pose detection"
        case .textDetection:
            return "Text detection"
        case .trajectoryContourHorizonDetection:
            return "Trajectory, contour, and horizon detection"
        }
    }
    
    var children: [RequestType] {
        RequestType.allCases.filter({ $0.category == self }).sorted()
    }
}

extension RequestCategory: Comparable {}

enum RequestType: String, CaseIterable, Identifiable {
    case classifyImage
    case generatePersonSegmentation
    case generatePersonInstanceMask
    case detectDocumentSegmentation
    case calculateImageAestheticsScores
    case generateAttentionBasedSaliencyImage
    case generateObjectnessBasedSaliencyImage
    case detectFaceRectangles
    case detectFaceLandmarks
    case detectFaceCaptureQuality
    case detectHumanRectangles
    case detectHumanBodyPose
    case detectTextRectangles
    case recognizeText
    case detectBarcodes
    case detectContours
    case detectHorizon
    
    var id: Self {
        return self
    }
    
    var title: String {
        switch self {
        case .detectBarcodes:
            return "Detect Barcodes"
        case .classifyImage:
            return "Classify Image"
        case .generatePersonSegmentation:
            return "Generate Person Segmentation"
        case .generatePersonInstanceMask:
            return "Generate Person Instance Mask"
        case .detectDocumentSegmentation:
            return "Detect Document Segmentation"
        case .calculateImageAestheticsScores:
            return "Calculate Image Aesthetics Score"
        case .generateAttentionBasedSaliencyImage:
            return "Generate Attention-Based Saliency Image"
        case .generateObjectnessBasedSaliencyImage:
            return "Generate Objectness-Based Saliency Image"
        case .detectFaceRectangles:
            return "Detect Face Rectangles"
        case .detectFaceLandmarks:
            return "Detect Face Landmarks"
        case .detectFaceCaptureQuality:
            return "Detect Face Capture Quality"
        case .detectHumanRectangles:
            return "Detect Human Rectangles"
        case .detectHumanBodyPose:
            return "Detect Human Body Pose"
        case .detectTextRectangles:
            return "Detect Text Rectangles"
        case .recognizeText:
            return "Recognize Text"
        case .detectContours:
            return "Detect Contours"
        case .detectHorizon:
            return "Detect Horizon"
        }
    }
    
    var defaultImageName: String {
        switch self {
        case .detectBarcodes:
            return "barcodes.png"
        case .classifyImage:
            return "house.jpg"
        case .generatePersonSegmentation:
            return "person.jpg"
        case .generatePersonInstanceMask, .detectFaceRectangles, .detectFaceLandmarks, .detectFaceCaptureQuality:
            return "people.jpg"
        case .detectDocumentSegmentation:
            return "document.jpg"
        case .calculateImageAestheticsScores:
            return "waterfall.jpg"
        case .generateAttentionBasedSaliencyImage, .generateObjectnessBasedSaliencyImage:
            return "lotsOfObjects.jpg"
        case .detectHumanRectangles, .detectHumanBodyPose:
            return "office.jpg"
        case .detectTextRectangles, .recognizeText:
            return "text.png"
        case .detectContours:
            return "lotsOfObjects.jpg"
        case .detectHorizon:
            return "horizon.jpg"
        }
    }
    
    var category: RequestCategory {
        switch self {
        case .detectBarcodes:
            return .barcodeDetection
        case .classifyImage:
            return .stillImageAnalysis
        case .generatePersonSegmentation, .generatePersonInstanceMask, .detectDocumentSegmentation:
            return .imageSequenceAnalysis
        case .calculateImageAestheticsScores:
            return .aestheticsAnalysis
        case .generateAttentionBasedSaliencyImage, .generateObjectnessBasedSaliencyImage:
            return .saliencyAnalysis
        case .detectFaceRectangles, .detectFaceLandmarks, .detectFaceCaptureQuality, .detectHumanRectangles:
            return .faceAndBodyDetection
        case .detectHumanBodyPose:
            return .bodyAndHandPoseDetection
        case .detectTextRectangles, .recognizeText:
            return .textDetection
        case .detectContours, .detectHorizon:
            return .trajectoryContourHorizonDetection
        }
    }
    
    @ViewBuilder
    func detailView(observation: any VisionObservation) -> some View {
        switch self {
        case .detectBarcodes:
            if let observation = observation as? BarcodeObservation {
                VStack(alignment: .leading) {
                    Text(.init("**Symbology**: \(observation.symbology)"))
                    
                    if let payload = observation.payloadString {
                        Text("**Payload**: \(payload)")
                    }
                    
                    if let supplementalPayload = observation.supplementalPayloadString {
                        Text("**Supplemental Payload**: \(supplementalPayload)")
                    }
                    
                    Text("**Confidence**: \(observation.confidence)")
                }
            }
        case .detectDocumentSegmentation:
            if let observation = observation as? DetectedDocumentObservation {
                VStack(alignment: .leading) {
                    Text("**Confidence**: \(observation.confidence)")
                }
            }
        case .generateAttentionBasedSaliencyImage, .generateObjectnessBasedSaliencyImage:
            if let observation = observation as? RectangleObservation {
                VStack(alignment: .leading) {
                    Text("**Confidence**: \(observation.confidence)")
                }
            }
        case .detectFaceRectangles, .detectFaceLandmarks, .detectFaceCaptureQuality:
            if let observation = observation as? FaceObservation {
                let formatter = MeasurementFormatter()
                VStack(alignment: .leading) {
                    if let captureQuality = observation.captureQuality {
                        Text("**Capture Quality**: \(captureQuality.score)")
                    }
                    Text("**Pitch**: \(formatter.string(from: observation.pitch.converted(to: .degrees)))")
                    Text("**Roll**: \(formatter.string(from: observation.roll.converted(to: .degrees)))")
                    Text("**Yaw**: \(formatter.string(from: observation.yaw.converted(to: .degrees)))")
                    Text("**Confidence**: \(observation.confidence)")
                }
            }
        case .detectHumanRectangles:
            if let observation = observation as? HumanObservation {
                VStack(alignment: .leading) {
                    Text(.init("**Is Upper Body Only**: \(observation.isUpperBodyOnly)"))
                    Text("**Confidence**: \(observation.confidence)")
                }
            }
        case .detectTextRectangles:
            if let observation = observation as? TextObservation {
                VStack(alignment: .leading) {
                    Text(.init("**Character Box Count**: \(observation.characterBoxes?.count ?? 0)"))
                    Text("**Confidence**: \(observation.confidence)")
                }
            }
        case .recognizeText:
            if let observation = observation as? RecognizedTextObservation, let candidate = observation.topCandidates(1).first {
                VStack(alignment: .leading) {
                    Text("**String**: \(candidate.string)")
                    Text("**Confidence**: \(candidate.confidence)")
                }
            }
        default:
            EmptyView()
        }
    }
    
    func performRequest(on image: CGImage) async throws -> [any BoundingBoxProviding & VisionObservation] {
        switch self {
        case .detectBarcodes:
            let request = DetectBarcodesRequest()
            let observations = try await request.perform(on: image)
            return observations
        case .detectDocumentSegmentation:
            let request = DetectDocumentSegmentationRequest()
            if let observation = try await request.perform(on: image) {
                return [observation]
            } else {
                return []
            }
        case .detectFaceRectangles:
            let request = DetectFaceRectanglesRequest()
            let observations = try await request.perform(on: image)
            return observations
        case .detectFaceLandmarks:
            let request = DetectFaceLandmarksRequest()
            let observations = try await request.perform(on: image)
            return observations
        case .detectFaceCaptureQuality:
            let request = DetectFaceCaptureQualityRequest()
            let observations = try await request.perform(on: image)
            return observations
        case .detectTextRectangles:
            var request = DetectTextRectanglesRequest()
            request.reportCharacterBoxes = true
            let observations = try await request.perform(on: image)
            return observations
        case .recognizeText:
            var request = RecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.automaticallyDetectsLanguage = true
            request.usesLanguageCorrection = true
            let observations = try await request.perform(on: image)
            return observations
        default:
            return []
        }
    }
    
    func performHorizonRequest(on image: CGImage) async throws -> HorizonObservation? {
        switch self {
        case .detectHorizon:
            let request = DetectHorizonRequest()
            let observation = try await request.perform(on: image)
            return observation
        default:
            return nil
        }
    }
    
    func performPoseRequest(on image: CGImage) async throws -> [HumanBodyPoseObservation] {
        switch self {
        case .detectHumanBodyPose:
            let request = DetectHumanBodyPoseRequest()
            let observations = try await request.perform(on: image)
            return observations
        default:
            return []
        }
    }
    
    func performAestheticScoresRequest(on image: CGImage) async throws -> ImageAestheticsScoresObservation? {
        switch self {
        case .calculateImageAestheticsScores:
            let request = CalculateImageAestheticsScoresRequest()
            let observation = try await request.perform(on: image)
            return observation
        default:
            return nil
        }
    }
    
    func performSaliencyRequest(on image: CGImage) async throws -> SaliencyImageObservation? {
        switch self {
        case .generateAttentionBasedSaliencyImage:
            let request = GenerateAttentionBasedSaliencyImageRequest()
            let observation = try await request.perform(on: image)
            return observation
        case .generateObjectnessBasedSaliencyImage:
            let request = GenerateObjectnessBasedSaliencyImageRequest()
            let observation = try await request.perform(on: image)
            return observation
        default:
            return nil
        }
    }
    
    func performClassificationRequest(on image: CGImage) async throws -> [ClassificationObservation] {
        switch self {
        case .classifyImage:
            let request = ClassifyImageRequest()
            let observations = try await request.perform(on: image)
            return observations
        default:
            return []
        }
    }
    
    func performSegmentationRequest(on image: CGImage) async throws -> PixelBufferObservation? {
        switch self {
        case .generatePersonSegmentation:
            let request = GeneratePersonSegmentationRequest()
            request.qualityLevel = .accurate
            
            let observation = try await request.perform(on: image)
            return observation
        default:
            return nil
        }
    }
    
    func performInstanceMaskRequest(on image: CGImage) async throws -> InstanceMaskObservation? {
        switch self {
        case .generatePersonInstanceMask:
            let request = GeneratePersonInstanceMaskRequest()            
            let observation = try await request.perform(on: image)
            return observation
        default:
            return nil
        }
    }
    
    func performHumanRectanglesRequest(on image: CGImage, upperBodyOnly: Bool) async throws -> [any BoundingBoxProviding & VisionObservation] {
        switch self {
        case .detectHumanRectangles:
            var request = DetectHumanRectanglesRequest()
            request.upperBodyOnly = upperBodyOnly
            let observations = try await request.perform(on: image)
            return observations
        default:
            return []
        }
    }
    
    func performContoursRequest(on image: CGImage) async throws -> ContoursObservation? {
        switch self {
        case .detectContours:
            let request = DetectContoursRequest()
            let observation = try await request.perform(on: image)
            return observation
        default:
            return nil
        }
    }
}

extension RequestType: Comparable {
    static func < (lhs: RequestType, rhs: RequestType) -> Bool {
        return lhs.title < rhs.title
    }
}
