//
//  TemperatureColorConverter.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-12.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit

typealias TemperatureInC = Double

struct TemperatureColorParameters {
    let min: TemperatureInC
    let max: TemperatureInC
    let coldColor: UIColor
    let warmColor: UIColor
}

extension TemperatureColorParameters: Equatable {
    static func == (left: TemperatureColorParameters, right: TemperatureColorParameters) -> Bool {
        let leftTuple = (left.min, left.max, left.coldColor, left.warmColor)
        let rightTuple = (right.min, right.max, right.coldColor, right.warmColor)
        return leftTuple == rightTuple
    }
}

struct TemperatureColorConverter {
    func from(_ temperature: TemperatureInC, parameters: TemperatureColorParameters) -> UIColor {
        let min = parameters.min
        let max = parameters.max
        let cold = parameters.coldColor
        let warm = parameters.warmColor

        let normalizedTemperature = temperature.normalize(min: min, max: max)
        return color(from: normalizedTemperature, cold: cold.components, warm: warm.components)
    }
}

private extension TemperatureColorConverter {
    func color(from temperature: TemperatureInC, cold: ColorComponents, warm: ColorComponents) -> UIColor {
        let convertedTemperature = CGFloat(temperature)
        let invertedTemperature = 1.0 - convertedTemperature

        let red = invertedTemperature * cold.red + convertedTemperature * warm.red
        let green = invertedTemperature * cold.green + convertedTemperature * warm.green
        let blue = invertedTemperature * cold.blue + convertedTemperature * warm.blue
        let alpha = invertedTemperature * cold.alpha + convertedTemperature * warm.alpha

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

private extension Double {
  func normalize(min minimum: Double, max maximum: Double) -> Double {
    let clampedValue = min(max(self, minimum), maximum)
    return (clampedValue - minimum) / (maximum - minimum)
  }
}
