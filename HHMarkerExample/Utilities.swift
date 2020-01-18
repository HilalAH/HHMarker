//
//  Utilities.swift
//  Testing3dModelInGoogleMaps
//
//  Created by Hilal Al Hakkani on 1/8/20.
//  Copyright © 2020 Hilal. All rights reserved.
//

import Foundation
import UIKit

 extension UIImage {
    func scaleToSize(aSize :CGSize) -> UIImage? {
        if (self.size.equalTo(aSize)) {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(aSize, false, 0.0)
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: aSize.width, height: aSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let img = image else {
            return nil
        }
        return UIImage(cgImage: img.cgImage!, scale: 2.0, orientation: .up)
    }
}

func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}
