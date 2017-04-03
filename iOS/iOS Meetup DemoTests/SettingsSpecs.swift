//
//  SettingsSpecs.swift
//  iOS Meetup Demo
//
//  Created by Noah McCann on 2017-04-19.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import Quick
import Nimble
@testable import iOS_Meetup_Demo

class SettingsSpecs: QuickSpec {
    override func spec() {
        var sut: Settings!
        var userDefaults: UserDefaultsMock!

        beforeEach {
            userDefaults = UserDefaultsMock()
            sut = Settings(userDefaults: userDefaults)
        }

        describe("get") {
            it("uses expected key") {
                _ = sut[.brightness]
                let expected = Setting.brightness.rawValue
                let actual = userDefaults.test.object.key
                expect(actual) == expected
            }

            it("calls method") {
                _ = sut[.maxTemperature]
                expect(userDefaults.test.object.called) == 1
            }

            context("and value exists", {
                beforeEach {
                    userDefaults.test.object.return = "value"
                }

                it("returns value") {
                    let expected = "value"
                    let actual = sut[.minTemperature] as? String
                    expect(actual) == expected
                }
            })

            context("and value does not exist") {
                beforeEach {
                    userDefaults.test.object.return = nil
                }

                it("returns nil") {
                    let actual = sut[.minTemperature] as? String
                    expect(actual).to(beNil())
                }
            }
        }

        describe("set") {
            it("uses expected key") {
                sut[.maxTemperature] = "new_value"

                let expected = Setting.maxTemperature.rawValue
                let actual = userDefaults.test.set.key
                expect(actual) == expected
            }

            it("calls method") {
                sut[.maxTemperature] = "new_value"
                expect(userDefaults.test.set.called) == 1
            }

            it("sets value") {
                let expected = "some value"
                sut[.minTemperature] = expected
                let actual = userDefaults.test.set.value as? String
                expect(actual) == expected
            }
        }

        describe("remove") {
            it("uses expected key") {
                sut.remove(.maxTemperature)

                let expected = Setting.maxTemperature.rawValue
                let actual = userDefaults.test.remove.key
                expect(actual) == expected
            }

            it("calls method") {
                sut.remove(.maxTemperature)
                expect(userDefaults.test.remove.called) == 1
            }
        }
    }
}

private class UserDefaultsMock: UserDefaults {
    struct Test {
        var object: (called: Int, key: String?, return: Any?) = (called: 0, key: nil, return: nil)
        var set: (called: Int, key: String?, value: Any?) = (called: 0, key: nil, value: nil)
        var remove: (called: Int, key: String?) = (called: 0, key: nil)
    }

    var test = Test()

    override func object(forKey defaultName: String) -> Any? {
        test.object.called += 1
        test.object.key = defaultName
        return test.object.return
    }

    override func set(_ value: Any?, forKey defaultName: String) {
        test.set.called += 1
        test.set.key = defaultName
        test.set.value = value
    }

    override func removeObject(forKey defaultName: String) {
        test.remove.called += 1
        test.remove.key = defaultName
    }
}
