//
//  ImageCache.swift
//  Testing3dModelInGoogleMaps
//
//  Created by Hilal Al Hakkani on 1/8/20.
//  Copyright © 2020 Hilal. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

final class ImageCache {
    static let shared = ImageCache()
    private var cache: [CarName: [ [UIImage] ] ] = [:]

    // # Number of animation patterns
    // Adjusting this changes the smoothness of the rotation animation.
    // Larger is smoother but consumes more resources.
    //
    // Set a multiple of 2. (Recommended numbers: 30, 60, 120...)
    static let divCount = 120

    // # Number of scaling patterns
    // Adjusting this changes the smoothness of the scaling animation.
    // Larger is smoother but consumes more resources.
    //
    // Recommended numbers: 6
    static let scaleCount = 12

    static let step = 360.0 / Double(divCount)

    private let scales: [Float]

    private init() {
        let scaleStep = 1.0 / Float(ImageCache.scaleCount)
        self.scales = (0..<ImageCache.scaleCount).map { 1.0 - (scaleStep * Float($0)) }
        load(car: .teslaModelX)
    }

    private func isCached(car: CarName) -> Bool {
        return cache[car] != nil
    }

    func getImage(car: CarName, roundedHeading: Int, scale: Float = 1.0) -> UIImage? {
        var scaleIndex = scales.count - 1
        for (i, s) in scales.enumerated() {
            if (s - 0.01) < scale {
                scaleIndex = i
                break
            }
        }
        return cache[car]?[scaleIndex][roundedHeading]
    }

    func load(car: CarName) {
        guard !isCached(car: car) else {
            return
        }
        let scene = SCNScene(named:"Assets.scnassets/\(car.rawValue)")!
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3.init(7, 8, 0.0)
        cameraNode.eulerAngles = SCNVector3(x: Float(deg2rad(3)), y: Float(Double.pi/2), z: Float(deg2rad(40)))
        scene.rootNode.addChildNode(cameraNode)

        let carNode = scene.rootNode.childNode(withName: "parent", recursively: true)!

        // Generate 2d images
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
        renderer.scene = scene
        renderer.autoenablesDefaultLighting = true
        let size = CGSize(width: 250, height: 250)

        // Generate 2d images from 3D model
        var originalImages: [UIImage] = []
        for i in 0..<ImageCache.divCount {
            carNode.eulerAngles = SCNVector3(x:0, y: -Float(deg2rad(ImageCache.step * Double(i))) - Float(Double.pi/2) , z: 0.0)
            let image = renderer.snapshot(atTime: 0, with: size, antialiasingMode: .multisampling2X)
                .resizableImage(withCapInsets: .zero, resizingMode: .stretch)
            let retinaImage = UIImage(cgImage: image.cgImage!, scale: 2.0, orientation: .up)
            originalImages.append(retinaImage)
        }

        // Generate a scaled image
            var imageContainer: [[UIImage]] = []
            for (i, scale) in self.scales.enumerated() {
                var images: [UIImage] = []
                for image in originalImages {
                    if i == 0 {
                        images.append(image)
                    } else {
                        let size = image.size.applying(CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale)))
                        images.append(image.scaleToSize(aSize: size)!)
                    }
                }
                imageContainer.append(images)
            }

            self.cache[car] = imageContainer
        }

    
}


