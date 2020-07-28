//
//  ViewController.swift
//  AppboosterSDKExample
//
//  Created by Appbooster on 22.07.2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let ab = AppboosterAB(
      authToken: "<APITAPI_AUTH_TOKEN>",
      appId: "<APP_ID>",
      deviceToken: "<DEVICE_TOKEN>",
      defaults: ["<TEST_1_KEY>": "<TEST_1_DEFAULT_VALUE>"]
    )

    ab.fetch() { abError in
      guard abError == nil else { return }

      let test1Value: String? = ab.value("<TEST_1_KEY>")

      print(test1Value ?? "")
    }
  }

}
