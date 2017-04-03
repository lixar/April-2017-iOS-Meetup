//
//  HuePresenter.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-13.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit
import SwiftyHue

protocol HuePresentable: class {
    func requestBridgeAccess()
    func configuredBridgeAccess()
    func updatedLights(color: UIColor)
    func showError(_ error: Error)
}

class HuePresenter {
    let heartbeatInterval = 10.0
    let defaultMinTemp: TemperatureInC = 10.0
    let defaultMaxTemp: TemperatureInC = 30.0
    let defaultPaletteId = 1
    let minBrightness = 0
    let maxBrightness = 254

    weak var presentable: HuePresentable? {
        didSet {
            configurePalettes()
        }
    }

    fileprivate var lights: [String: Light] = [:]
    fileprivate var palettes: [Palette] = []
    fileprivate let hue: SwiftyHue
    fileprivate let converter: TemperatureColorConverter
    fileprivate let getPalettes: GetPalettes
    fileprivate let settings: Settings
    fileprivate let configHelper: BridgeAccessConfigHelper

    init(hue: SwiftyHue = SwiftyHue(),
         converter: TemperatureColorConverter = TemperatureColorConverter(),
         getPalettes: GetPalettes = GetPalettes(),
         settings: Settings = Settings.shared,
         configHelper: BridgeAccessConfigHelper = BridgeAccessConfigHelper.shared) {
        self.hue = hue
        self.converter = converter
        self.getPalettes = getPalettes
        self.settings = settings
        self.configHelper = configHelper
    }

    func shouldRequestBridgeAccess() {
        configure()
    }

    func shouldUpdateLightColor(temperature: TemperatureInC) {
        updateColor(for: temperature)
    }

    func shouldUseNextPalette() {
        useNextPalette()
    }

    func shouldUsePreviousPalette() {
        usePreviousPalette()
    }

    func shouldUpdateBrightness(_ brightness: Int) {
        updateBrightness(brightness)
    }
}

private extension HuePresenter {
    func configure() {
        if let config = configHelper.get() {
            configureHeartbeat(config: config)
            presentable?.configuredBridgeAccess()
        } else {
            presentable?.requestBridgeAccess()
        }
    }

    func configureHeartbeat(config: BridgeAccessConfig) {
        hue.stopHeartbeat()

        hue.setBridgeAccessConfig(config, resourceCacheHeartbeatProcessorDelegate: self)
        hue.setLocalHeartbeatInterval(heartbeatInterval, forResourceType: .lights)
        hue.startHeartbeat()
    }

    func configurePalettes() {
        palettes = getPalettes.get().sorted(by: { first, second in
            return first.id < second.id
        })
    }

    func getCurrentPaletteIndex() -> Int? {
        let paletteId = settings[.paletteId] as? Int ?? defaultPaletteId
        return palettes.index(where: { palette in
            return palette.id == paletteId
        })
    }

    func getCurrentPalette() -> Palette? {
        let paletteId = settings[.paletteId] as? Int ?? defaultPaletteId
        return palettes.first(where: { palette in
            return palette.id == paletteId
        })
    }

    func useNextPalette() {
        guard let currentIndex = getCurrentPaletteIndex() else {
            settings[.paletteId] = nil
            return
        }

        let newIndex = getPaletteIndex(after: currentIndex)
        settings[.paletteId] = palettes[newIndex].id
    }

    func usePreviousPalette() {
        guard let currentIndex = getCurrentPaletteIndex() else {
            settings[.paletteId] = nil
            return
        }

        let newIndex = getPaletteIndex(before: currentIndex)
        settings[.paletteId] = palettes[newIndex].id
    }

    func updateBrightness(_ brightness: Int) {
        let currentBrightness = settings[.brightness] as? Int ?? maxBrightness

        var newBrightness = currentBrightness + brightness
        newBrightness = min(max(newBrightness, minBrightness), maxBrightness)

        settings[.brightness] = newBrightness
    }

    func updateColor(for temperature: TemperatureInC) {
        let parameters = getTemperatureColorParameters()
        let color = converter.from(temperature, parameters: parameters)
        setLightColor(color)
    }

    func getPaletteIndex(after index: Int) -> Int {
        let nextIndex = (index + 1) % palettes.count
        return nextIndex
    }

    func getPaletteIndex(before index: Int) -> Int {
        let previousIndex = index - 1
        return previousIndex < 0 ? palettes.count - 1 : previousIndex
    }

    func getTemperatureColorParameters() -> TemperatureColorParameters {
        guard let palette = getCurrentPalette() else {
            fatalError()
        }

        let min = settings[.minTemperature] as? TemperatureInC ?? defaultMinTemp
        let max = settings[.maxTemperature] as? TemperatureInC ?? defaultMaxTemp

        return TemperatureColorParameters(min: min,
                                          max: max,
                                          coldColor: palette.coldColor,
                                          warmColor: palette.warmColor)
    }

    func setLightColor(_ color: UIColor) {
        guard !lights.isEmpty else {
            return
        }

        var lightState = LightState()
        lightState.brightness = settings[.brightness] as? Int

        for (id, light) in lights {
            let xy = HueUtilities.calculateXY(color, forModel: light.modelId)
            lightState.xy = [Float(xy.x), Float(xy.y)]

            hue.bridgeSendAPI.updateLightStateForId(id,
                                                    withLightState: lightState,
                                                    completionHandler: {[weak self] (errors) in
                                                        if let error = errors?.first {
                                                            self?.presentable?.showError(error)
                                                        } else {
                                                            self?.presentable?.updatedLights(color: color)
                                                        }
            })
        }
    }
}

extension HuePresenter: ResourceCacheHeartbeatProcessorDelegate {
    func resourceCacheUpdated(_ resourceCache: BridgeResourcesCache) {
        lights = resourceCache.lights
    }
}
