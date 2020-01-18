//
//  HHMarker.swift
//  Testing3dModelInGoogleMaps
//
//  Created by Hilal Al Hakkani on 1/8/20.
//  Copyright © 2020 Hilal. All rights reserved.
//

import Foundation
import GoogleMaps
import SceneKit
import UIKit

class HHCarMarker:GMSMarker {
    private var car: CarName!
     var heading: Double = 0.0{
        didSet {
            updateIcon()
        }
    }

    var scale: Float = 1 {
        didSet {
            updateIcon()
        }
    }

    func updateIcon() {
        print(heading)
        let roundedHeading = Int(heading / ImageCache.step)
        print(roundedHeading)
        print("**********")
        self.icon = ImageCache.shared.getImage(car: car, roundedHeading: roundedHeading, scale: scale)
    }

    init(car: CarName){
        super.init()
        self.heading = 0.0
        self.car = car
        self.appearAnimation = .pop
        setupSceneKit(car: car)
    }

    func setupSceneKit(car: CarName) {
        self.groundAnchor = CGPoint.init(x: 0.5, y: 0.5)
        updateIcon()
    }
}

enum CarName: String {
    case teslaModelX = "Tesla+Model+X.dae"
}
