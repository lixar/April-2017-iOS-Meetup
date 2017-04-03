//
//  BridgeAuthenticatorViewController.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-11.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit

class BridgeAuthenticatorViewController: UIViewController {
    @IBOutlet fileprivate var descriptionLabel: UILabel!
    @IBOutlet fileprivate var loadingIndicator: UIActivityIndicatorView!

    fileprivate var presenter: BridgeAuthenticatorPresenter!

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private init() {
        super.init(nibName: BridgeAuthenticatorViewController.nibName, bundle: nil)
    }

    convenience init(presenter: BridgeAuthenticatorPresenter) {
        self.init()
        self.presenter = presenter
        self.presenter.presentable = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.shouldAuthenticate()
    }
}

private extension BridgeAuthenticatorViewController {
    class var nibName: String? {
        return "BridgeAuthenticatorViewController"
    }

    func configureSubviews() {
        showLoading(false)
    }

    func showAlert(title: String?, message: String?, retryHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cancel)

        if let handler = retryHandler {
            let retry = UIAlertAction(title: NSLocalizedString("Retry", comment: ""),
                                      style: .`default`,
                                      handler: handler)
            alert.addAction(retry)
        }

        present(alert, animated: true, completion: nil)
    }

    func authenticationSuccessful() {
        showLoading(false)
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func waitForAuthentication() {
        showLoading(true)
        let text = NSLocalizedString("Press the push-link button on the Hue bridge you want to connect to.",
                                     comment: "")
        descriptionLabel.text = text
    }

    func showError(_ error: Error) {
        showLoading(false)
        showAlert(title: NSLocalizedString("Error", comment: ""),
                  message: error.localizedDescription) {[weak self] _ in
                    self?.presenter.shouldAuthenticate()
        }
    }

    func showTimeout() {
        showLoading(false)
        showAlert(title: nil, message: NSLocalizedString("Authentication Timeout", comment: "")) {[weak self] _ in
            self?.presenter.shouldAuthenticate()
        }
    }

    func showLoading(_ loading: Bool) {
        loadingIndicator.isHidden = !loading
    }
}

extension BridgeAuthenticatorViewController: BridgeAuthenticatorPresentable {
    func update(with state: BridgeAuthenticatorState) {
        switch state {
        case .success:
            authenticationSuccessful()
        case .failure(let error):
            showError(error)
        case .waiting:
            waitForAuthentication()
        case .timeout:
            showTimeout()
        }
    }
}
