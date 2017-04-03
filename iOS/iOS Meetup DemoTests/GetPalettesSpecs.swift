//
//  GetPalettesSpecs.swift
//  iOS Meetup Demo
//
//  Created by Noah McCann on 2017-04-19.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import Quick
import Nimble
@testable import iOS_Meetup_Demo

class GetPalettesSpecs: QuickSpec {
    override func spec() {
        var sut: GetPalettes!
        var factory: PaletteFactoryMock!

        beforeEach {
            factory = PaletteFactoryMock()
            sut = GetPalettes(factory: factory)
        }

        describe("get") {
            it("calls factory") {
                _ = sut.get()

                expect(factory.test.get.called) == 1
            }

            it("returns palettes") {
                let expected = [Palette(id: 0, coldColor: .blue, warmColor: .red)]
                factory.test.get.return = expected
                let actual = sut.get()

                expect(actual) == expected
            }
        }
    }
}

private class PaletteFactoryMock: PaletteFactory {
    struct Test {
        var get: (called: Int, return: [Palette]) = (called: 0, return: [])
    }

    var test = Test()

    override func get() -> [Palette] {
        test.get.called += 1
        return test.get.return
    }
}
