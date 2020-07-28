//
//  AppboosterAB.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit
import AdSupport

public final class AppboosterAB: NSObject {

  // TODO: replace serverUrl
  private let serverUrl: String = "https://api.appbooster.com"
  private let sdkToken: String
  private let appId: String
  private let deviceId: String
  private let knownKeys: [String]

  public init(
    sdkToken: String,
    appId: String,
    deviceId: String? = nil,
    defaults: [String: Any]
  ) {
    self.sdkToken = sdkToken
    self.appId = appId
    self.knownKeys = Array(defaults.keys)

    defaultTests = defaults.compactMap { key, value in
      AppboosterTest(key: key, value: value as? AnyCodable ?? "")
    }

    if let deviceId = deviceId {
      self.deviceId = deviceId
    } else {
      self.deviceId = AppboosterKeychain.getDeviceId() ?? AppboosterKeychain.setNewDeviceId()
    }

    super.init()
  }

  private var tests: [AppboosterTest] = State.tests {
    didSet {
      State.tests = tests
    }
  }
  private var defaultTests: [AppboosterTest] = State.defaultTests {
    didSet {
      State.defaultTests = tests
    }
  }
  private var debugTests: [AppboosterTest] {
    return State.debugTests
  }

  public var showDebug: Bool = false
  public var log: ((String) -> Void)?

  public var lastOperationDuration: TimeInterval = 0.0

  public func fetch(timeoutInterval: TimeInterval = 3.0,
                    completion: @escaping (_ abError: AppboosterABError?) -> Void) {
    fetchTests(timeoutInterval: timeoutInterval, completion: completion)
    fetchAllExperiments(timeoutInterval: timeoutInterval)
  }

  private func createUrl(path: String) -> URL? {
    let urlPath = [serverUrl, API.modifier, API.type, path]
      .joined(separator: "/")

    var urlComponents = URLComponents(string: urlPath)
    urlComponents?.queryItems = knownKeys.map({ URLQueryItem(name: "knownKeys[]", value: $0) })

    return urlComponents?.url
  }

  private func createHeaders() -> [String: String] {
    let token = JWTToken.generate(deviceId: deviceId, sdkToken: sdkToken) ?? ""
    let headers = [
      "Content-Type": "application/json",
      "Authorization": "Bearer \(token)",
      "SDK-App-ID": appId,
      "AppVersion": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    ]

    return headers
  }

  private func fetchTests(timeoutInterval: TimeInterval,
                          completion: @escaping (_ abError: AppboosterABError?) -> Void) {
    guard let url = createUrl(path: API.path) else {
      let abError = AppboosterABError(error: "Invalid url", code: 0)

      debugAndLog("[AppboosterAB] Error – \(abError.error), error code: \(abError.code)")

      completion(abError)

      return
    }

    let headers = createHeaders()
    let startDate = Date()

    API.get(url,
            headers: headers,
            timeoutInterval: timeoutInterval) { [weak self] data, abError in
              guard let self = self else { return }

              self.lastOperationDuration = Date().timeIntervalSince(startDate)

              if let abError = abError {
                self.debugAndLog("[AppboosterAB] Error – \(abError.error), error code: \(abError.code)")

                completion(abError)
              } else if let data = data {
                do {
                  let testsResponse = try JSONDecoder().decode(AppboosterTestResponse.self, from: data)

                  self.tests = testsResponse.experiments
                  AppboosterDebugMode.isOn = testsResponse.debug

                  completion(nil)
                }
                catch {
                  let abError = AppboosterABError(error: "Tests decoding error: \(error.localizedDescription)",
                    code: 0)

                  self.debugAndLog("[AppboosterAB] Error – \(abError.error), error code: \(abError.code)")

                  completion(abError)
                }
              }
    }
  }

  private func fetchAllExperiments(timeoutInterval: TimeInterval) {
    guard let url = createUrl(path: API.optionsPath) else {
      let abError = AppboosterABError(error: "Invalid url", code: 0)

      debugAndLog("[AppboosterAB] Fetch all experiments error – \(abError.error), error code: \(abError.code)")

      return
    }

    let headers = createHeaders()

    API.get(url,
            headers: headers,
            timeoutInterval: timeoutInterval) { [weak self] data, abError in
              guard let self = self else { return }

              if let abError = abError {
                self.debugAndLog("[AppboosterAB] Fetch all experiments error – \(abError.error), error code: \(abError.code)")
              } else if let data = data {
                do {
                  let experiments = try JSONDecoder().decode([AppboosterExperiment].self, from: data)

                  State.experiments = experiments
                }
                catch {
                  let abError = AppboosterABError(error: "Tests decoding error: \(error.localizedDescription)",
                    code: 0)

                  self.debugAndLog("[AppboosterAB] Fetch all experiments error – \(abError.error), error code: \(abError.code)")
                }
              }
    }
  }

  // MARK: Getters

  public func value<T>(_ key: String) -> T? {
    if AppboosterDebugMode.isOn {
      return debugTests.filter({ $0.key == key }).first?.value.value as? T
        ?? tests.filter({ $0.key == key }).first?.value.value as? T
        ?? defaultTests.filter({ $0.key == key }).first?.value.value as? T
    } else {
      return tests.filter({ $0.key == key }).first?.value.value as? T
        ?? defaultTests.filter({ $0.key == key }).first?.value.value as? T
    }
  }

  public var userProperties: [String: Any] {
    var userProperties: [String: Any] = [:]

    for test in tests {
      userProperties[test.key] = test.value.value
    }

    return userProperties
  }

  // MARK: Service

  private func debugAndLog(_ text: String) {
    if showDebug {
      #if DEBUG
      print(text)
      #endif
    }

    log?(text)
  }

}
