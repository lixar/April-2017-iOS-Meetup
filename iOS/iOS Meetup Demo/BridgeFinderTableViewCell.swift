//
//  BridgeFinderTableViewCell.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-11.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit
import SwiftyHue

class BridgeFinderTableViewCell: UITableViewCell {
    @IBOutlet fileprivate var nameLabel: UILabel!
    @IBOutlet fileprivate var modelLabel: UILabel!

    class var reuseIdentifier: String {
        return "BridgeFinderTableViewCell"
    }

    class var nibName: String {
        return "BridgeFinderTableViewCell"
    }

    class var estimatedHeight: CGFloat {
        return 64.0
    }

    func update(_ bridge: HueBridge) {
        nameLabel.text = bridge.friendlyName
        modelLabel.text = bridge.modelName
    }
}
