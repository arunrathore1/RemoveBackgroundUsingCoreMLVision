//
//  RemoveBackground.swift
//  CoreMLBackgroundChangeSwiftUI
//
//  Created by Arun Rathore on 26/12/23.
//

import SwiftUI
import Vision
import CoreML

class RemoveBackground: ObservableObject {
    
    @Published var outputImage : UIImage = UIImage(named: "unsplash")!
    @Published var inputImage : UIImage = UIImage(named: "unsplash")!
    
    func runVisionRequest() {
        guard let model = try? VNCoreMLModel(for: DeepLabV3(configuration: .init()).model)
        else { return }
        
        let request = VNCoreMLRequest(model: model, completionHandler: visionRequestDidComplete)
        request.imageCropAndScaleOption = .scaleFill
        DispatchQueue.global().async {
            
            let handler = VNImageRequestHandler(cgImage: self.inputImage.cgImage!, options: [:])
            
            do {
                try handler.perform([request])
            }catch {
                print(error)
            }
        }
    }
    
    func maskInputImage(){
        let bgImage = UIImage.imageFromColor(color: .orange, size: self.inputImage.size, scale: self.inputImage.scale)!
        
        let beginImage = CIImage(cgImage: inputImage.cgImage!)
        let background = CIImage(cgImage: bgImage.cgImage!)
        let mask = CIImage(cgImage: self.outputImage.cgImage!)
        
        if let compositeImage = CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: beginImage,
            kCIInputBackgroundImageKey:background,
            kCIInputMaskImageKey:mask])?.outputImage
        {
            let ciContext = CIContext(options: nil)
            let filteredImageRef = ciContext.createCGImage(compositeImage, from: compositeImage.extent)
            self.inputImage = UIImage(cgImage: filteredImageRef!)
        }
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
               let segmentationmap = observations.first?.featureValue.multiArrayValue {
                
                let segmentationMask = segmentationmap.image(min: 0, max: 1)
                
                self.outputImage = segmentationMask!.resizedImage(for: self.inputImage.size)!
                
                self.maskInputImage()
                
            }
        }
    }
}
