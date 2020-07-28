//
//  State.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import Foundation

struct State {

  static var tests: [AppboosterTest] {
    get { getTestsData(for: #function) }
    set(newValue) { setTestsData(newValue, for: #function) }
  }

  static var debugTests: [AppboosterTest] {
    get { getTestsData(for: #function) }
    set(newValue) { setTestsData(newValue, for: #function) }
  }

  static var defaultTests: [AppboosterTest] {
    get { getTestsData(for: #function) }
    set(newValue) { setTestsData(newValue, for: #function) }
  }

  static var experiments: [AppboosterExperiment] {
    get {
      if let data = UserDefaults.standard.object(forKey: #function) as? Data,
        let value = try? JSONDecoder().decode([AppboosterExperiment].self, from: data) {
        return value
      }

      return []
    }
    set(newValue) {
      if let data = try? JSONEncoder().encode(newValue) {
        UserDefaults.standard.set(data, forKey: #function)
      }
    }
  }

  // Service

  private static func getTestsData(for key: String) -> [AppboosterTest] {
    if let data = UserDefaults.standard.object(forKey: key) as? Data,
      let value = try? JSONDecoder().decode([AppboosterTest].self, from: data) {
      return value
    }

    return []
  }

  private static func setTestsData(_ data: [AppboosterTest], for key: String) {
    if let data = try? JSONEncoder().encode(data) {
      UserDefaults.standard.set(data, forKey: key)
    }
  }
}
