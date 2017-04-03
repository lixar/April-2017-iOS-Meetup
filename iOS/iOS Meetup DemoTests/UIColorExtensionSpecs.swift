//
//  UIColorExtensionSpecs.swift
//  iOS Meetup Demo
//
//  Created by Noah McCann on 2017-04-19.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import Quick
import Nimble
@testable import iOS_Meetup_Demo

class UIColorExtensionSpecs: QuickSpec {
    override func spec() {
        describe("constrasting") {
            context("when bright") {
                it("returns black") {
                    let sut = UIColor.green
                    let expected = UIColor.black
                    let actual = sut.contrastingColor
                    expect(actual) == expected
                }
            }

            context("when dark") {
                it("returns white") {
                    let sut = UIColor.gray
                    let expected = UIColor.white
                    let actual = sut.contrastingColor
                    expect(actual) == expected
                }
            }
        }

        describe("components") {
            context("with no transparency") {
                it("returns components") {
                    let sut = UIColor.cyan
                    let expected = ColorComponents(red: 0, green: 1, blue: 1, alpha: 1)
                    let actual = sut.components
                    expect(actual) == expected
                }
            }

            context("with some transparency") {
                it("returns components") {
                    let sut = UIColor.brown.withAlphaComponent(0.75)
                    let expected = ColorComponents(red: 0.6, green: 0.4, blue: 0.2, alpha: 0.75)
                    let actual = sut.components
                    expect(actual) == expected
                }
            }

        }
    }
}
