//
//  BridgeAuthenticatorPresenter.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-11.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit
import SwiftyHue

protocol BridgeAuthenticatorPresentable: class {
    func update(with state: BridgeAuthenticatorState)
}

enum BridgeAuthenticatorState {
    case success
    case failure(Error)
    case waiting
    case timeout
}

class BridgeAuthenticatorPresenter {
    fileprivate static let bridgeIdentifier = "iOS Meetup"
    fileprivate let bridge: HueBridge
    fileprivate let authenticator: BridgeAuthenticator
    fileprivate let configHelper: BridgeAccessConfigHelper

    weak var presentable: BridgeAuthenticatorPresentable?

    init(bridge: HueBridge,
         authenticator: BridgeAuthenticator?,
         configHelper: BridgeAccessConfigHelper = BridgeAccessConfigHelper.shared) {
        self.bridge = bridge
        self.configHelper = configHelper
        let identifier = BridgeAuthenticatorPresenter.bridgeIdentifier
        self.authenticator = authenticator ?? BridgeAuthenticator(bridge: bridge,
                                                                  uniqueIdentifier: identifier)
    }

    func shouldAuthenticate() {
        authenticate()
    }
}

private extension BridgeAuthenticatorPresenter {
    func authenticate() {
        authenticator.delegate = self
        authenticator.start()
    }
}

extension BridgeAuthenticatorPresenter: BridgeAuthenticatorDelegate {
    func bridgeAuthenticatorDidTimeout(_ authenticator: BridgeAuthenticator) {
        presentable?.update(with: .timeout)
    }

    func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFailWithError error: NSError) {
        presentable?.update(with: .failure(error))
    }

    func bridgeAuthenticatorRequiresLinkButtonPress(_ authenticator: BridgeAuthenticator, secondsLeft: TimeInterval) {
        presentable?.update(with: .waiting)
    }

    func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFinishAuthentication username: String) {
        let config = BridgeAccessConfig(bridgeId: BridgeAuthenticatorPresenter.bridgeIdentifier,
                                                    ipAddress: bridge.ip,
                                                    username: username)
        configHelper.save(config)

        presentable?.update(with: .success)
    }
}
