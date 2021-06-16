//
//  AppboosterAB.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit
import AdSupport

public final class AppboosterSDK: NSObject {

  private let serverUrl: String = "https://api.appbooster.com"
  private let sdkToken: String
  private let appId: String
  private let deviceId: String
  private let deviceProperties: [String: Any]
  private let appsFlyerId: String?
  private let amplitudeId: String?
  private let knownKeys: [String]
  private var fetchAllExperimentsObserver: NSObjectProtocol?
  private var cachedTimeoutInterval: TimeInterval = 3.0

  public init(
    sdkToken: String,
    appId: String,
    deviceId: String? = nil,
    deviceProperties: [String: Any] = [:],
    appsFlyerId: String? = nil,
    amplitudeUserId: String? = nil,
    usingShake: Bool = true,
    defaults: [String: Any]
  ) {
    self.sdkToken = sdkToken
    self.appId = appId
    self.appsFlyerId = appsFlyerId
    self.amplitudeId = amplitudeUserId
    self.knownKeys = Array(defaults.keys)

    defaultExperimentsValues = defaults.compactMap { key, value in
      AppboosterExperimentValue(key: key, value: value as? AnyCodable ?? "", optionId: nil)
    }

    self.deviceId = deviceId
      ?? AppboosterKeychain.getDeviceId()
      ?? AppboosterKeychain.setNewDeviceId()
    self.deviceProperties = deviceProperties

    AppboosterDebugMode.usingShake = usingShake

    super.init()

    fetchAllExperimentsObserver = NotificationCenter.default.addObserver(
      forName: Notification.Name("FetchAllExperiments"),
      object: nil,
      queue: .main) { [weak self] _ in
      guard let self = self else { return }

      self.fetchAllExperiments(timeoutInterval: self.cachedTimeoutInterval)
    }
  }

  private var experimentsValues: [AppboosterExperimentValue] = State.experimentsValues {
    didSet {
      State.experimentsValues = experimentsValues
    }
  }
  private var defaultExperimentsValues: [AppboosterExperimentValue] = State.defaultExperimentsValues {
    didSet {
      State.defaultExperimentsValues = experimentsValues
    }
  }
  private var debugExperimentsValues: [AppboosterExperimentValue] {
    return State.debugExperimentsValues
  }

  public var showDebug: Bool = false
  public var log: ((String) -> Void)?

  public var lastOperationDuration: TimeInterval = 0.0

  public func fetch(timeoutInterval: TimeInterval = 3.0,
                    completion: @escaping (_ abError: AppboosterABError?) -> Void) {
    guard let url = createUrl(path: API.path) else {
      let abError = AppboosterABError(error: "Invalid url", code: 0)

      debugAndLog("[AppboosterSDK] Error – \(abError.error), error code: \(abError.code)")

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
                self.debugAndLog("[AppboosterSDK] Error – \(abError.error), error code: \(abError.code)")

                completion(abError)
              } else if let data = data {
                do {
                  let experimentsValuesResponse = try JSONDecoder().decode(AppboosterExperimentsValuesResponse.self, from: data)

                  self.experimentsValues = experimentsValuesResponse.experiments
                  AppboosterDebugMode.isOn = experimentsValuesResponse.meta.debug

                  completion(nil)
                }
                catch {
                  let abError = AppboosterABError(error: "Experiments values decoding error: \(error.localizedDescription)",
                    code: 0)

                  self.debugAndLog("[AppboosterSDK] Error – \(abError.error), error code: \(abError.code)")

                  completion(abError)
                }
              }
    }
  }

  private func createUrl(path: String) -> URL? {
    let urlPath = [serverUrl, API.modifier, API.type, path]
      .joined(separator: "/")

    var urlComponents = URLComponents(string: urlPath)
    urlComponents?.queryItems = knownKeys.map({ URLQueryItem(name: "knownKeys[]", value: $0) })

    return urlComponents?.url
  }

  private func createHeaders() -> [String: String] {
    let token = JWTToken.generate(deviceId: deviceId, deviceProperties: deviceProperties, appsFlyerId: appsFlyerId, amplitudeId: amplitudeId, sdkToken: sdkToken) ?? ""
    let headers = [
      "Content-Type": "application/json",
      "Authorization": "Bearer \(token)",
      "SDK-App-ID": appId,
      "AppVersion": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    ]

    return headers
  }

  private func fetchAllExperiments(timeoutInterval: TimeInterval,
                                   completion: ((_ abError: AppboosterABError?) -> Void)? = nil) {
    guard let url = createUrl(path: API.optionsPath) else {
      let abError = AppboosterABError(error: "Invalid url", code: 0)

      debugAndLog("[AppboosterSDK] Fetch all experiments error – \(abError.error), error code: \(abError.code)")

      completion?(abError)

      return
    }

    let headers = createHeaders()

    API.get(url,
            headers: headers,
            timeoutInterval: timeoutInterval) { [weak self] data, abError in
              guard let self = self else { return }

              if let abError = abError {
                self.debugAndLog("[AppboosterSDK] Fetch all experiments error – \(abError.error), error code: \(abError.code)")

                completion?(abError)
              } else if let data = data {
                do {
                  let experimentsResponse = try JSONDecoder().decode(AppboosterExperimentsResponse.self, from: data)

                  State.experiments.removeAll()
                  experimentsResponse.experiments.forEach { experiment in
                    if experiment.status == .finished {
                      if let experimentValue = State.defaultExperimentsValues.first(where: { $0.key == experiment.key }),
                        let defaultOption = experiment.options.first(where: { $0.value == experimentValue.value }) {
                        let finishedExperiment = AppboosterExperiment(
                          name: experiment.name,
                          key: experiment.key,
                          status: .finished,
                          options: [defaultOption]
                        )
                        State.experiments.append(finishedExperiment)
                      }
                    } else {
                      State.experiments.append(experiment)
                    }
                  }

                  if let observer = self.fetchAllExperimentsObserver {
                    NotificationCenter.default.removeObserver(observer)
                  }

                  NotificationCenter.default.post(name: Notification.Name("AllExperimentsReceived"), object: nil)

                  completion?(nil)
                }
                catch {
                  let abError = AppboosterABError(error: "All experiments decoding error: \(error.localizedDescription)",
                    code: 0)

                  self.debugAndLog("[AppboosterSDK] Error – \(abError.error), error code: \(abError.code)")

                  completion?(abError)
                }
              }
    }
  }

  // MARK: Getters

  public func value<T>(_ key: String) -> T? {
    let value = AppboosterDebugMode.isOn
      ? debugExperimentsValues.first(where: { $0.key == key })?.value.value as? T
      : nil

    return value
      ?? experimentsValues.first(where: { $0.key == key })?.value.value as? T
      ?? defaultExperimentsValues.first(where: { $0.key == key })?.value.value as? T
  }

  public subscript<T>(key: String) -> T? {
    return value(key)
  }

  public func experiments() -> [String: Any] {
    let experiments = Dictionary(uniqueKeysWithValues: experimentsValues.map {
      ($0.key, $0.value.value)
    })

    guard AppboosterDebugMode.isOn else { return experiments }

    let debugExperiments = Dictionary(uniqueKeysWithValues: debugExperimentsValues.map {
      ($0.key, $0.value.value)
    })

    return experiments.merging(debugExperiments) { $1 }
  }

  public func experimentsWithDetails() -> [String: Any] {
    var dict = [String: Any]()
    experimentsValues.forEach { experiment in dict.merge(experiment.details) { (v1, v2) in v1 } }

    return dict
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
