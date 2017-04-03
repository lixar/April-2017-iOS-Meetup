//
//  UIColorExtension.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-12.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit

struct ColorComponents {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
}

extension ColorComponents: Equatable {
    static func == (left: ColorComponents, right: ColorComponents) -> Bool {
        let leftTuple = (left.red, left.green, left.blue, left.alpha)
        let rightTuple = (right.red, right.green, right.blue, right.alpha)
        return leftTuple == rightTuple
    }
}

extension UIColor {
    var components: ColorComponents {
        return getComponents()
    }

    var contrastingColor: UIColor {
        return getContrastingColor()
    }

    private func getComponents() -> ColorComponents {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return ColorComponents(red: red, green: green, blue: blue, alpha: alpha)
    }

    func getContrastingColor() -> UIColor {
        let comps = getComponents()

        // Calculating the relative luminance
        // https://en.wikipedia.org/wiki/Relative_luminance
        let relativeLuminance = (red: 212.6, green: 715.2, blue: 72.2)
        let relativeLuminanceSum = relativeLuminance.red + relativeLuminance.green + relativeLuminance.blue

        let red = relativeLuminance.red * Double(comps.red)
        let green = relativeLuminance.green * Double(comps.green)
        let blue = relativeLuminance.blue * Double(comps.blue)
        let luminance = 1.0 - (red + green + blue) / relativeLuminanceSum

        if luminance < 0.5 {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
}

extension UIColor {
    class var coldWhite: UIColor {
        return self.init(red: 231.0/255.0, green: 254.0/255.0, blue: 253.0/255.0, alpha: 1.0)
    }

    class var warmWhite: UIColor {
        return self.init(red: 254.0/255.0, green: 244.0/255.0, blue: 198.0/255.0, alpha: 1.0)
    }
}
