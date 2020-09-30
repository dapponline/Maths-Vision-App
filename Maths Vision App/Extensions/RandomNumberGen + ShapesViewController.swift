//
//  RandomNumberGen + ShapesViewController.swift
//  ML SHAPE GAME
//
//  Created by Leon Smith on 12/10/2019.
//  Copyright © 2019 Leon Smith. All rights reserved.
//

import Foundation
import GameplayKit
import Vision

extension ShapesViewController {
    
    func ranDumGen() {
        let fixedLotteryBalls = [Int](0...9)
        let fixedShuffledBalls = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: fixedLotteryBalls)
        let index = fixedShuffledBalls[0] as! Int
        imageView2.image = UIImage(named: AppSettings.shapeImagesNames[index])
        AppSettings.shapeName = AppSettings.shapeImagesNames[index]
        DispatchQueue.main.async {
            self.resultView.text = AppSettings.shapeName
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
//            self.showNextShape()
        }
    }
    
    func showNextShape() {
        self.ranDumGen()
    }
    
}
