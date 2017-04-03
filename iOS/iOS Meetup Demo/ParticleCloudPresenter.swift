//
//  ParticleCloudPresenter.swift
//  iOS Meetup Demo
//
//  Created by Alex Kalinichenko on 4/12/17.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import Foundation
import Particle_SDK
import Keys

protocol ParticleCloudPresentable: class {
    func showLoading(_ loading: Bool)
    func showError(_ error: Error)
    func updateWith(temperature: TemperatureInC)
}

class ParticleCloudPresenter {
    fileprivate let particleCloud: ParticleCloud
    fileprivate var photonDevice: ParticleDevice?

    weak var presentable: ParticleCloudPresentable? {
        didSet {
            startListeningForTemperatureUpdates()
        }
    }

    init(particleCloud: ParticleCloud = ParticleCloud.sharedInstance()) {
        self.particleCloud = particleCloud
    }

    func startListeningForTemperatureUpdates() {
        self.presentable?.showLoading(true)
        self.login()
    }

    func stopListeningForTemperatureUpdates() {
        self.unsubscribeFromTemperatureChanges()
        self.presentable?.showLoading(false)
    }
}

private extension ParticleCloudPresenter {
    static let photonDeviceName = "photon_meetup"
    static let temperatureChangeEventID = "temperature_changed"

    func login() {
        let keys = IOSMeetupDemoKeys()

        self.particleCloud.login(withUser: keys.particleUsername,
                                 password: keys.particlePassword) {[weak self] (error: Error?) -> Void in
                                    if let error = error {
                                        self?.fail(with: error, message: "Failed to login")
                                        return
                                    }

                                    self?.getDevices()
        }
    }

    func getDevices() {
        guard self.particleCloud.isAuthenticated else {
            fatalError()
        }

        self.particleCloud.getDevices { [weak self] (devices: [ParticleDevice]?, error: Error?) -> Void in
            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                let message = NSLocalizedString("Failed to get devices", comment: "")
                strongSelf.fail(with: error ?? strongSelf.defaultError(), message: message)
                return
            }

            strongSelf.photonDevice = strongSelf.findPhotonDevice(with: devices)
            strongSelf.subscribeForTemperatureChanges()
        }
    }

    func subscribeForTemperatureChanges() {
        guard let device = self.photonDevice else {
            fatalError()
        }

        self.presentable?.showLoading(false)

        let eventID = ParticleCloudPresenter.temperatureChangeEventID
        device.subscribeToEvents(withPrefix: eventID) { [weak self] (event: ParticleEvent?, error: Error?) in
            guard let strongSelf = self else {
                return
            }

            guard let event = event, error == nil else {
                let message = NSLocalizedString("Failed to subscribe for temperature changes event", comment: "")
                strongSelf.fail(with: error ?? strongSelf.defaultError(), message: message)
                return
            }

            let temperature: String = event.data ?? "0.0"
            strongSelf.log(message: "Temperature = \(temperature)")

            guard let parsed = TemperatureInC(temperature) else {
                let message = NSLocalizedString("Failed to parse for temperature change event", comment: "")
                strongSelf.fail(with: strongSelf.defaultError(), message: message)
                return
            }

            DispatchQueue.main.async {
                strongSelf.presentable?.updateWith(temperature: parsed)
            }
        }
    }

    func unsubscribeFromTemperatureChanges() {
        guard let device = self.photonDevice else {
            return
        }

        device.unsubscribeFromEvent(withID: ParticleCloudPresenter.temperatureChangeEventID)
    }

    func findPhotonDevice(with devices: [ParticleDevice]?) -> ParticleDevice? {
        guard let particleDevices = devices else {
            return nil
        }

        return particleDevices.first(where: { $0.name == ParticleCloudPresenter.photonDeviceName })
    }

    func fail(with error: Error, message: String) {
        self.log(message: "\(message), error: \(error.localizedDescription)")
        self.presentable?.showError(error)
        self.presentable?.showLoading(false)
    }

    func log(message: String) {
        print("Particle Cloud: \(message)")
    }

    func defaultError() -> NSError {
        return NSError(domain: "Generic",
                       code: 0,
                       userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Unknown Error", comment: "")])
    }
}
