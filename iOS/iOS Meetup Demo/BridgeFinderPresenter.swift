//
//  BridgeFinderPresenter.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-11.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit
import SwiftyHue

protocol BridgeFinderPresentable: class {
    func update(with state: BridgeFinderState)
}

enum BridgeFinderState {
    case success([HueBridge])
    case loading
    case empty
}

class BridgeFinderPresenter {
    fileprivate let finder: BridgeFinder

    weak var presentable: BridgeFinderPresentable? {
        didSet {
            find()
        }
    }

    init(finder: BridgeFinder = BridgeFinder()) {
        self.finder = finder
    }
}

private extension BridgeFinderPresenter {
    func find() {
        presentable?.update(with: .loading)
        finder.delegate = self
        finder.start()
    }
}

extension BridgeFinderPresenter: BridgeFinderDelegate {
    func bridgeFinder(_ finder: BridgeFinder, didFinishWithResult bridges: [HueBridge]) {
        if bridges.isEmpty {
            presentable?.update(with: .empty)
        } else {
            presentable?.update(with: .success(bridges))
        }
    }
}
