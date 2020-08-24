//
//  AppboosterShakeToDebugController.swift
//  AppboosterSDK
//
//  Created by Appbooster on 24.08.2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit

open class AppboosterShakeToDebugController: UIViewController {

  // MARK: - UIResponder

  override open var canBecomeFirstResponder: Bool {
    return true
  }

  override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if AppboosterDebugMode.isOn &&
      AppboosterDebugMode.usingShake
      && motion == .motionShake {
      AppboosterDebugMode.showMenu(from: self)
    }
  }

  // MARK: - UIViewController

  override open func viewDidLoad() {
    super.viewDidLoad()

    _ = becomeFirstResponder()
  }

}
