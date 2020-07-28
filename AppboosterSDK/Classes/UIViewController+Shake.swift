//
//  UIViewController+Shake.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit

extension UIViewController {

  open override func becomeFirstResponder() -> Bool {
    return true
  }

  override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if abDebugMode && motion == .motionShake {
      let controller = UINavigationController(rootViewController: ExperimentsController())
      present(controller, animated: true)
    }
  }

}
