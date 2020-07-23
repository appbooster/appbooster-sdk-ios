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
    get {
      if let data = UserDefaults.standard.object(forKey: #function) as? Data,
        let value = try? JSONDecoder().decode([AppboosterTest].self, from: data) {
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

  static var debugTests: [AppboosterTest] {
    get {
      if let data = UserDefaults.standard.object(forKey: #function) as? Data,
        let value = try? JSONDecoder().decode([AppboosterTest].self, from: data) {
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

}
