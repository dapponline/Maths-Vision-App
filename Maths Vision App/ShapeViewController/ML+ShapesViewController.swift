
//  ML+ShapesViewController.swift
//  Maths Vision App
//
//  Created by Leon Smith on 12/10/2019.
//  Copyright © 2019 Leon Smith. All rights reserved.

import Foundation
import UIKit
import Vision

extension ShapesViewController {

    // scales any UIImage to a desired target size
    func scaleImage (image:UIImage, toSize size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func reconizeDigit() {
      let image = UIImage(view: canvasView1)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 299, height: 299)) // scale the image to the required size of 28x28 for better recognition results
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:]) // create a handler that should perform the vision request
        
        do {
            try imageRequestHandler.perform(AppSettings.requests)
        }catch{
            print(error)
        }
    }
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: ShapeImageClassifier().model) else {fatalError("can not load Vision ML model")}
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        AppSettings.requests = [classificationRequest] // assigns the classificationRequest to the global requests array
    }
    
    func textViewsRight() {
        DispatchQueue.main.async {
            self.newResultText = "CORRECT"
            self.score += 5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNextShape()
       
        }
    }
    
    func textViewsWrong() {
        DispatchQueue.main.async {
            self.newResultText = "WRONG"
            self.score -= 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showNextShape()
        }
    }
    
    func textViewsUnknown() {
        DispatchQueue.main.async {
            self.newResultText = "UNKNOWN"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNextShape()
        }
    }
    
    func handleClassification (request:VNRequest, error:Error?) {
        guard let observations = request.results else {print("no results"); return}
        
        // process the ovservations
        let classifications = observations
            .compactMap({$0 as? VNClassificationObservation}) // cast all elements to VNClassificationObservation objects
            .filter({$0.confidence > 0.8}) // only choose observations with a confidence of more than 80%
            .map({$0.identifier}) // only choose the identifier string to be placed into the classifications array
        
        let percent = Int((observations[0] as AnyObject).confidence * 100)
        print("percent: \(percent)%")
        self.predictions = "\(String(describing: "percent: \(percent)%"))"
        
        AppSettings.percentage = percent
        
        guard let prediction = classifications.first else {
            print("no results")
            predictions = "NO MATCH TRY AGAIN, \(AppSettings.percentage)%"
            self.newResultText = "UNKNOWN"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showNextShape()
                self.newResultText = ""
            }
            return
        }
        
        DispatchQueue.main.async {
            self.predictions = " \(prediction), Percentage: \(AppSettings.percentage)%"
            print("predictions: \(self.predictions)")
            if AppSettings.shapeName == prediction {
                self.textViewsRight()
            } else {
                self.textViewsWrong()
            }
        }
    }
    
}
