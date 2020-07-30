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

    let ab = AppboosterSDK(
      sdkToken: "<YOUR_SDK_TOKEN>",
      appId: "<YOUR_APP_ID>",
      defaults: [
        "<TEST_1_KEY>": "<TEST_1_DEFAULT_VALUE>",
        "<TEST_2_KEY>": "<TEST_2_DEFAULT_VALUE>"
      ]
    )

    ab.fetch() { abError in
      guard abError == nil else { return }

      let test1Value: String? = ab.value("<TEST_1_KEY>")
      let test2Value: String? = ab["<TEST_2_KEY>"]

      print(test1Value ?? "")
      print(test2Value ?? "")
    }
  }

}
