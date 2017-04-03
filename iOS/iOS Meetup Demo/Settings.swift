//
//  Settings.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-13.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import Foundation

enum Setting: String {
    case minTemperature
    case maxTemperature
    case paletteId
    case brightness
    case bridgeAccessConfig
}

class Settings {
    static let shared = Settings()
    fileprivate let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    subscript(_ index: Setting) -> Any? {
        get {
            return userDefaults.object(forKey: index.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: index.rawValue)
        }
    }

    func remove(_ index: Setting) {
        userDefaults.removeObject(forKey: index.rawValue)
    }
}
