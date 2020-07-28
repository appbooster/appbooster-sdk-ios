//
//  AppboosterDebugMode.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import Foundation
import UIKit

public struct AppboosterDebugMode {

  static var isOn: Bool = false

  public static var usingShake: Bool = true

  public static func showDebugMenu(from viewController: UIViewController) {
    let controller = UINavigationController(rootViewController: ExperimentsController())
    viewController.present(controller, animated: true)
  }
}
