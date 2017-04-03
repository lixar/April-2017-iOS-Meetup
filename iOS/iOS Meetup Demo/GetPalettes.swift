//
//  GetPalettes.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-18.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit

class GetPalettes {
    fileprivate let factory: PaletteFactory

    init(factory: PaletteFactory = PaletteFactory()) {
        self.factory = factory
    }

    func get() -> [Palette] {
        return factory.get()
    }
}

class PaletteFactory {
    func get() -> [Palette] {
        return [
            Palette(id: 1, coldColor: UIColor.blue, warmColor: UIColor.red),
            Palette(id: 2, coldColor: UIColor.purple, warmColor: UIColor.orange),
            Palette(id: 3, coldColor: UIColor.magenta, warmColor: UIColor.green),
            Palette(id: 4, coldColor: UIColor.green, warmColor: UIColor.red),
            Palette(id: 5, coldColor: UIColor.coldWhite, warmColor: UIColor.warmWhite)
        ]
    }
}
