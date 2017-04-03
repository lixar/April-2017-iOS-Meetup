//
//  TemperatureColorConverterSpecs.swift
//  iOS Meetup Demo
//
//  Created by Noah McCann on 2017-04-19.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import Quick
import Nimble
@testable import iOS_Meetup_Demo

class TemperatureColorConverterSpecs: QuickSpec {
    override func spec() {
        let sut = TemperatureColorConverter()

        context("when given temperature in range") {
            it("returns color between min and max color") {
                let parameters = TemperatureColorParameters(min: 10, max: 30, coldColor: .blue, warmColor: .red)
                let expected = UIColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1)
                let actual = sut.from(20, parameters: parameters)
                expect(actual) == expected
            }
        }

        context("when given another temperature in range") {
            it("returns color between min and max color") {
                let parameters = TemperatureColorParameters(min: 10, max: 30, coldColor: .blue, warmColor: .red)
                let expected = UIColor(red: 0.25, green: 0.0, blue: 0.75, alpha: 1)
                let actual = sut.from(15, parameters: parameters)
                expect(actual) == expected
            }
        }

        context("when given temperature below range") {
            it("returns min color") {
                let parameters = TemperatureColorParameters(min: 20, max: 50, coldColor: .green, warmColor: .orange)
                let expected = UIColor.green
                let actual = sut.from(5, parameters: parameters)
                expect(actual) == expected
            }
        }

        context("when given temperature above range") {
            it("returns max color") {
                let parameters = TemperatureColorParameters(min: 20, max: 50, coldColor: .green, warmColor: .orange)
                let expected = UIColor.orange
                let actual = sut.from(100, parameters: parameters)
                expect(actual) == expected
            }
        }
    }
}
