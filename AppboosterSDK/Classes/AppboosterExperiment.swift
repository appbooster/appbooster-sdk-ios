//
//  AppboosterExperiment.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import Foundation

struct AppboosterExperiment: Codable {
  let name: String
  let key: String
  let status: AppboosterExperimentStatus
  let options: [AppboosterExperimentOption]

  enum CodingKeys: String, CodingKey {
    case name
    case key
    case status
    case options
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(key, forKey: .key)
    try container.encode(status.rawValue, forKey: .status)
    try container.encode(options, forKey: .options)
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    key = try container.decode(String.self, forKey: .key)
    let stringStatus = try container.decode(String.self, forKey: .status)
    status = AppboosterExperimentStatus(rawValue: stringStatus) ?? .running
    options = try container.decode([AppboosterExperimentOption].self, forKey: .options)
  }

  init(
    name: String,
    key: String,
    status: AppboosterExperimentStatus,
    options: [AppboosterExperimentOption]
  ) {
    self.name = name
    self.key = key
    self.status = status
    self.options = options
  }
}
