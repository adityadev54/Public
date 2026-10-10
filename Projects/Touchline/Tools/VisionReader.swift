import Foundation
import Vision
import AppKit

// Native image operations only; C# owns HTTP, lifecycle, and experiment orchestration.
struct Reading: Codable {
    let text: String
    let confidence: Float
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}
struct Person: Codable {
    let id: Int
    let confidence: Float
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let readings: [Reading]
}
struct Evidence: Codable {
    let readings: [Reading]
    let people: [Person]
}
func readText(_ image: CGImage) throws -> [Reading] {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false
    request.minimumTextHeight = 0.01
    try VNImageRequestHandler(cgImage: image).perform([request])
    return (request.results ?? []).compactMap { observation -> Reading? in
        guard let candidate = observation.topCandidates(1).first else { return nil }
        let box = observation.boundingBox
        return Reading(text: candidate.string, confidence: candidate.confidence,
            x: box.minX, y: 1 - box.maxY, width: box.width, height: box.height)
    }
}
func enlarged(_ image: CGImage) -> CGImage {
    // Upscaling exposes small digits to OCR; it does not manufacture missing detail.
    let scale = min(6.0, max(1.0, 400.0 / Double(image.width)))
    guard let context = CGContext(data: nil, width: Int(Double(image.width) * scale),
        height: Int(Double(image.height) * scale), bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return image }
    context.interpolationQuality = .high
    context.draw(image, in: CGRect(x: 0, y: 0, width: context.width, height: context.height))
    return context.makeImage() ?? image
}
do {
    let data = FileHandle.standardInput.readDataToEndOfFile()
    guard let image = NSImage(data: data),
          let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        throw NSError(domain: "Touchline", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
    }
    // Small players disappear when the detector downsizes a complete 4K frame.
    // Overlapping tiles preserve their apparent size; merge duplicate detections below.
    var detected: [(box: CGRect, confidence: Float)] = []
    let tileSize = 768, stride = 576
    for top in Swift.stride(from: 0, to: cgImage.height, by: stride) {
        for left in Swift.stride(from: 0, to: cgImage.width, by: stride) {
            let rect = CGRect(x: left, y: top, width: min(tileSize, cgImage.width - left),
                height: min(tileSize, cgImage.height - top))
            guard let tile = cgImage.cropping(to: rect) else { continue }
            let request = VNDetectHumanRectanglesRequest()
            request.upperBodyOnly = false
            try VNImageRequestHandler(cgImage: tile).perform([request])
            for result in request.results ?? [] where result.confidence >= 0.35 {
                let local = result.boundingBox
                let box = CGRect(x: (rect.minX + local.minX * rect.width) / Double(cgImage.width),
                    y: (rect.minY + (1 - local.maxY) * rect.height) / Double(cgImage.height),
                    width: local.width * rect.width / Double(cgImage.width),
                    height: local.height * rect.height / Double(cgImage.height))
                detected.append((box, result.confidence))
            }
        }
    }
    var observations: [(box: CGRect, confidence: Float)] = []
    for detection in detected.sorted(by: { $0.confidence > $1.confidence }) {
        let duplicate = observations.contains { existing in
            let intersection = existing.box.intersection(detection.box)
            let area = intersection.isNull ? 0 : intersection.width * intersection.height
            let union = existing.box.width * existing.box.height + detection.box.width * detection.box.height - area
            return union > 0 && area / union > 0.35
        }
        if !duplicate { observations.append(detection) }
    }
    observations = Array(observations.sorted { $0.box.minX < $1.box.minX }.prefix(40))
    var people: [Person] = []
    for (index, observation) in observations.enumerated() {
        let box = observation.box
        let x = box.minX, y = box.minY
        // Crop the upper body, excluding most shorts and socks that create false digits.
        let cropRect = CGRect(x: x * Double(cgImage.width), y: y * Double(cgImage.height),
            width: box.width * Double(cgImage.width), height: box.height * Double(cgImage.height) * 0.65)
        let crop = cgImage.cropping(to: cropRect.integral)
        let readings = try crop.map { try readText(enlarged($0)) } ?? []
        people.append(Person(id: index + 1, confidence: observation.confidence,
            x: x, y: y, width: box.width, height: box.height, readings: readings))
    }
    let evidence = Evidence(readings: try readText(cgImage), people: people)
    FileHandle.standardOutput.write(try JSONEncoder().encode(evidence))
} catch {
    FileHandle.standardError.write(Data(error.localizedDescription.utf8))
    exit(1)
}
