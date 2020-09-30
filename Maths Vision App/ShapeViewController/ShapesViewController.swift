//
//  ShapesViewController.swift
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

class ShapesViewController: UIViewController, PKCanvasViewDelegate {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var resultView: UILabel!
    @IBOutlet weak var canvasView1: PKCanvasView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var predictedResult: UILabel!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var newResultText = "" {
         didSet {
             resultView.text = newResultText
         }
     }
    
    var predictions = "" {
         didSet {
            DispatchQueue.main.async {
                self.predictedResult.text = self.predictions
            }
         }
     }
    
    @IBAction func clearCanvas(_ sender: Any) {
        clearCanvasView()
    }
    
    @IBAction func checkAnswear(_ sender: Any) {
        reconizeDigit()
        clearCanvasView()
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
        canvasView1.backgroundColor = #colorLiteral(red: 0, green: 0.5013446212, blue: 1, alpha: 1)
        canvasView1.alpha = 1.0
        canvasView1.isOpaque = true
        canvasView1.tool = PKInkingTool(.pencil, color: .white, width: 40)
        canvasView1.delegate = self
        canvasView1.allowsFingerDrawing = true
        setupVision()
        showNextShape()
        self.newResultText = ""
    }
    
    func clearCanvasView() {
        canvasView1.drawing = PKDrawing()
    }
}
