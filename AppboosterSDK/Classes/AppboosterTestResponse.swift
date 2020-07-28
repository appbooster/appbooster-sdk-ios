//
//  AppboosterTestResponse.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import Foundation

struct AppboosterTestResponse: Codable {
  let experiments: [AppboosterTest]
  let debug: Bool
}
