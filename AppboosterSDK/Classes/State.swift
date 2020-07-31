//
//  State.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import Foundation

struct State {

  static var experimentsValues: [AppboosterExperimentValue] {
    get { getExperimentsValues(for: #function) }
    set(newValue) { setExperimentsValues(newValue, for: #function) }
  }

  static var debugExperimentsValues: [AppboosterExperimentValue] {
    get { getExperimentsValues(for: #function) }
    set(newValue) { setExperimentsValues(newValue, for: #function) }
  }

  static var defaultExperimentsValues: [AppboosterExperimentValue] {
    get { getExperimentsValues(for: #function) }
    set(newValue) { setExperimentsValues(newValue, for: #function) }
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

  // MARK: Service

  private static func getExperimentsValues(for key: String) -> [AppboosterExperimentValue] {
    if let data = UserDefaults.standard.object(forKey: key) as? Data,
      let value = try? JSONDecoder().decode([AppboosterExperimentValue].self, from: data) {
      return value
    }

    return []
  }

  private static func setExperimentsValues(_ data: [AppboosterExperimentValue], for key: String) {
    if let data = try? JSONEncoder().encode(data) {
      UserDefaults.standard.set(data, forKey: key)
    }
  }
}
