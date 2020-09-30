//
//  Constants.swift
//  Maths Vision App
//
//  Created by Leon Smith on 21/09/2020.
//  Copyright © 2020 Leon Smith. All rights reserved.
//


import Foundation
import UIKit
import Vision
import GameplayKit
import PencilKit

struct AppSettings {
    
    // ShapeViewCntroller
    static var requests = [VNRequest]()
    static var percentage = Int()
    static var newResult = 0
    static var answearNumber = 0
    static var shapeName = ""
    
    // DigitsViewCntroller
    static var didChange = false
    static var predictionText = ""
    static var canvasViewDidFinishRendering = false
    
    static var shapeImagesNames = ["Circle",
                            "Square",
                            "Heart",
                            "Triangle",
                            "Diamond",
                            "Bow Tie",
                            "Flower",
                            "Kite",
                            "Star" ,
                            "Pentagon"
    ]
}
