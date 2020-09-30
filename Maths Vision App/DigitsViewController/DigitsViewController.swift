//
//  DigitsViewController.swift
//  Maths Vision App
//
//  Created by Leon Smith on 06/10/2019.
//  Copyright © 2019 Leon Smith. All rights reserved.
//

import Foundation
import UIKit
import Vision
import GameplayKit
import PencilKit

class DigitsViewController: UIViewController, PKCanvasViewDelegate {
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var resultView: UILabel!
    
    @IBOutlet weak var canvasView1: PKCanvasView!
    
    @IBOutlet var mainView: UIView!
    
    @IBAction func clearCanvas(_ sender: Any) {
        
    }
    
    @IBAction func checkAnswear(_ sender: Any) {
        checkAnswear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpCanvasView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    func setUpCanvasView() {
        canvasView1.backgroundColor = .black
        canvasView1.isOpaque = true
        canvasView1.tool = PKInkingTool(.pencil, color: .white, width: 30)
        canvasView1.delegate = self
        setupVision()
        randumNumverGenerator()
        canvasView1.allowsFingerDrawing = true
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        print("canvasViewDidBeginUsingTool")
        AppSettings.didChange = true
        AppSettings.canvasViewDidFinishRendering = true
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        print("canvasViewDidEndUsingTool")
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        print("canvasViewDrawingDidChange")
        if AppSettings.didChange == true && AppSettings.canvasViewDidFinishRendering == true {
            AppSettings.didChange = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.checkAnswear()
            }
        }
        
    }
    
    func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
        print("canvasViewDidFinishRendering")
        AppSettings.canvasViewDidFinishRendering = true

    }
    
    func checkAnswear() {
        AppSettings.predictionText = ""
        AppSettings.newResult = 0
        reconizeDigit()
    }
    
    @IBOutlet weak var predictedResult: UILabel!
    
    var newResultText = "" {
        didSet {
            resultView.text = newResultText
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // scales any UIImage to a desired target size
    func scaleImage (image:UIImage, toSize size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func reconizeDigit() {
            let image = UIImage(view: canvasView1) // get UIImage from CanvasView
            
            let scaledImage = scaleImage(image: image, toSize: CGSize(width: 299, height: 299)) // scale the image to the required size of 28x28 for better recognition results
            
            let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:]) // create a handler that should perform the vision request
            
            do {
                try imageRequestHandler.perform(AppSettings.requests)
            }catch{
                print(error)
            }
    }
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: DigitClassifier().model) else {fatalError("can not load Vision ML model")}
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        AppSettings.requests = [classificationRequest]
    }
    
    func handleClassification (request:VNRequest, error:Error?) {
        guard let observations = request.results else {print("no results"); return}
        
        // process the ovservations
        let classifications = observations
            .compactMap({$0 as? VNClassificationObservation}) // cast all elements to VNClassificationObservation objects
            .filter({$0.confidence > 0.8}) // only choose observations with a confidence of more than 80%
            .map({$0.identifier}) // only choose the identifier string to be placed into the classifications array
        guard let prediction = classifications.first else { return }
        self.predictedResult.text = "\(String(describing: prediction))"
        AppSettings.predictionText = "\(String(describing: prediction))"
        if AppSettings.predictionText != "" {
            calculate()
        } else {
            print("prediction: \(String(describing: prediction))")
        }
        canvasView1.drawing = PKDrawing()
    }
    
    func calculate() {
        if AppSettings.canvasViewDidFinishRendering == true {
            AppSettings.canvasViewDidFinishRendering = false
            print("Values \(String(AppSettings.answearNumber)) -- \(self.predictedResult.text!)")
            if String(AppSettings.answearNumber) == self.predictedResult.text {
                print("CORRECT \(String(AppSettings.answearNumber)) -- \(self.predictedResult.text!)")
                DispatchQueue.main.async {
                    self.newResultText = "CORRECT"
                }
                self.score += 5
                DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                    self.randumNumverGenerator()
                }
            } else {
                DispatchQueue.main.async {
                    self.newResultText = "WRONG"
                }
                AppSettings.answearNumber = 0
                self.score -= 3
                DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                    self.randumNumverGenerator()
                }
            }
        }
    }
    
    func addition(x: Int, y: Int) -> Int {
        return x + y
    }
    
    func randumNumverGenerator() {
        let randumNumber1 = [Int](1...5)
        
        let randumNumber1Shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: randumNumber1)
        
        let number1 = randumNumber1Shuffled[0] as! Int
        
        let number2 = randumNumber1Shuffled[1] as! Int
        
        AppSettings.answearNumber = addition(x: number1, y: number2)
        
        self.newResultText = "\(number1) + \(number2) ="
    }
    
}
