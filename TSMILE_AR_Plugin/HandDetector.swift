//
//  HandDetectot.swift
//  TSMILE_AR_Plugin
//
//  Created by 周子皓 on 2024/9/29.
//

import CoreML
import Vision

public class HandDetector {
    
    private lazy var predictionRequest: VNCoreMLRequest = {
        // 加载模型并创建Vision请求
        do {
            let model = try VNCoreMLModel(for: HandModel().model)
            let request = VNCoreMLRequest(model: model)
            
            // 不裁剪图片
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFill
            return request
        } catch {
            fatalError("can't load Vision ML model: (error)")
        }
    }()
    
    let visionQueue = DispatchQueue(label: "com.TSMILE.visionqueue")
    
    public func performDetection(inputBuffer: CVPixelBuffer,
                                 completion: @escaping (_ outputBuffer: CVPixelBuffer?,
                                                        _ error: Error?) -> Void) {
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: inputBuffer, orientation: .right)
        
        visionQueue.async {
            do {
                try requestHandler.perform([self.predictionRequest])
                guard let observation = self.predictionRequest.results?.first as? VNPixelBufferObservation
                else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
                }
                completion(observation.pixelBuffer, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
