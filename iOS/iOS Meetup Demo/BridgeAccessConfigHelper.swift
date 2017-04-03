//
//  BridgeAccessConfigHelper.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-12.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit
import SwiftyHue
import Gloss

class BridgeAccessConfigHelper {
    static let shared = BridgeAccessConfigHelper()
    fileprivate let settings: Settings

    init(settings: Settings = Settings()) {
        self.settings = settings
    }

    func get() -> BridgeAccessConfig? {
        guard let configJSON = settings[.bridgeAccessConfig] as? JSON,
            let config = BridgeAccessConfig(json: configJSON) else {
                return nil
        }

        return config
    }

    func save(_ config: BridgeAccessConfig) {
        settings[.bridgeAccessConfig] = config.toJSON()
    }

    func remove() {
        settings.remove(.bridgeAccessConfig)
    }
}
