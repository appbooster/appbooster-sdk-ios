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
  private let serverUrl: String = "https://new.apitapi.com"
  private let authToken: String
  private let deviceToken: String
  private let appId: String
  private let knownKeys: [String]

  public var debugMode: Bool = false

  public init(
    authToken: String,
    appId: String,
    deviceToken: String? = nil,
    defaults: [String: Any]
  ) {
    self.authToken = authToken
    self.appId = appId
    self.knownKeys = Array(defaults.keys)

    defaultTests = defaults.compactMap { key, value in
      AppboosterTest(key: key, value: value as? AnyCodable ?? "")
    }

    if let deviceToken = deviceToken {
      self.deviceToken = deviceToken
    } else {
      self.deviceToken = AppboosterKeychain.getDeviceToken() ?? AppboosterKeychain.setNewDeviceToken()
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
    let urlPath = [serverUrl, API.modifier, "\(API.versionModifier)\(API.version)", API.path]
      .joined(separator: "/")

    var urlComponents = URLComponents(string: urlPath)
    urlComponents?.queryItems = knownKeys.map({ URLQueryItem(name: "knownKeys[]", value: $0) })

    guard let url = urlComponents?.url else {
      let abError = AppboosterABError(error: "Invalid url",
                                   code: 0)

      debugAndLog("[AppboosterAB] Error – \(abError.error), error code: \(abError.code)")

      completion(abError)

      return
    }

    let headers = [
      "Content-Type": "application/json",
      "Authorization": authToken,
      "DeviceToken": deviceToken,
      "AppId": appId,
      "AppVersion": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    ]

    let startDate = Date()

    API.get(url,
            headers: headers,
            timeoutInterval: timeoutInterval,
            completion: { [weak self] data, abError in
              guard let self = self else { return }

              self.lastOperationDuration = Date().timeIntervalSince(startDate)

              if let abError = abError {
                self.debugAndLog("[AppboosterAB] Error – \(abError.error), error code: \(abError.code)")

                completion(abError)
              } else if let data = data {
                do {
                  let tests = try JSONDecoder().decode([AppboosterTest].self, from: data)

                  self.tests = tests
//                  self.debugMode =

                  completion(nil)
                }
                catch {
                  let abError = AppboosterABError(error: "Tests decoding error: \(error.localizedDescription)",
                    code: 0)

                  self.debugAndLog("[AppboosterAB] Error – \(abError.error), error code: \(abError.code)")

                  completion(abError)
                }
              }
    })
  }

  // MARK: Getters

  public func value<T>(_ key: String) -> T? {
    if debugMode {
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
