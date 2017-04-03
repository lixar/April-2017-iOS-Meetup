//
//  Palette.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-18.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit

struct Palette {
    let id: Int
    let coldColor: UIColor
    let warmColor: UIColor
}

extension Palette: Equatable {
    static func == (left: Palette, right: Palette) -> Bool {
        let leftTuple = (left.id, left.coldColor, left.warmColor)
        let rightTuple = (right.id, right.coldColor, right.warmColor)
        return leftTuple == rightTuple
    }
}
