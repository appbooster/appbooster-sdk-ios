//
//  AppboosterExperiment.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import Foundation

struct AppboosterExperiment: Codable {
  let key: String
  let values: [AnyCodable]
}
