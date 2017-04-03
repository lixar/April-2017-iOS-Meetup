//
//  HomeViewController.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-13.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet var temperatureValueLabel: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var labels: [UILabel]!

    fileprivate let animationDuration = 0.4
    fileprivate let brightnessDeltaMultiplier = 0.01

    fileprivate let huePresenter = HuePresenter()
    fileprivate let particlePresenter = ParticleCloudPresenter()

    fileprivate var hasBridgeAccess = false

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSubviews()
        huePresenter.presentable = self
        particlePresenter.presentable = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        huePresenter.shouldRequestBridgeAccess()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if hasBridgeAccess == false {
            findBridge()
        }
    }

    @IBAction func didSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        huePresenter.shouldUseNextPalette()
    }

    @IBAction func didSwipeRight(_ sender: UISwipeGestureRecognizer) {
        huePresenter.shouldUsePreviousPalette()
    }

    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.changed || sender.state == UIGestureRecognizerState.ended {
            let velocity: CGPoint = sender.velocity(in: view)
            let delta = round(Double(-velocity.y) * brightnessDeltaMultiplier)
            huePresenter.shouldUpdateBrightness(Int(delta))
        }
    }
}

private extension HomeViewController {
    func configureSubviews() {
        showHomeView(false, animated: false)
        temperatureValueLabel.text = "-"
    }

    func showHomeView(_ show: Bool, animated: Bool) {
        let duration = animated ? animationDuration : 0.0
        let alpha: CGFloat = show ? 1.0 : 0.0

        UIView.animate(withDuration: duration) { [weak self] in
            self?.contentView.alpha = alpha
        }
    }

    func updateSubviews(color: UIColor) {
        view.backgroundColor = color

        let contrastingColor = color.contrastingColor
        updateStatusBar(for: contrastingColor)

        labels.forEach { (label) in
            label.textColor = contrastingColor
        }
    }

    func updateStatusBar(for color: UIColor) {
        if color == UIColor.black {
            UIApplication.shared.statusBarStyle = .`default`
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }

    func findBridge() {
        let bridgeFinderViewController = BridgeFinderViewController()
        let navigationController = UINavigationController(rootViewController: bridgeFinderViewController)
        present(navigationController, animated: true, completion: nil)
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
}

extension HomeViewController: HuePresentable {
    func requestBridgeAccess() {
        hasBridgeAccess = false
    }

    func configuredBridgeAccess() {
        hasBridgeAccess = true
        showHomeView(true, animated: true)
    }

    func updatedLights(color: UIColor) {
        updateSubviews(color: color)
    }
}

extension HomeViewController: ParticleCloudPresentable {
    func showLoading(_ loading: Bool) {
        loadingView.isHidden = !loading
    }

    func showError(_ error: Error) {
        showAlert(title: NSLocalizedString("Error", comment: ""),
                  message: error.localizedDescription) {[weak self] _ in
                    self?.particlePresenter.startListeningForTemperatureUpdates()
        }
    }

    func updateWith(temperature: TemperatureInC) {
        huePresenter.shouldUpdateLightColor(temperature: temperature)

        let temperatureString = String(format: "%.1f", temperature)
        temperatureValueLabel.text = temperatureString
    }
}

extension HomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: view)
            return fabs(velocity.y) > fabs(velocity.x)
        }

        return true
    }
}
