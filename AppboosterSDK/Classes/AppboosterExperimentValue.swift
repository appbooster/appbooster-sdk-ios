//
//  AppboosterExperimentValue.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import Foundation

struct AppboosterExperimentValue: Codable {
  let key: String
  let value: AnyCodable
  let optionId: Int?

  var details: [String: Any] {
    ["[Appbooster] \(key)": value.value,
     "[Appbooster] [internal] \(key)": optionId ?? "null"]
  }
}
