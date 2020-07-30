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

  static var usingShake: Bool = true

  public static var isOn: Bool = false

  public static func showMenu(from controller: UIViewController) {
    let navigationController = UINavigationController(rootViewController: ExperimentsController())
    controller.present(navigationController, animated: true)
  }
}
