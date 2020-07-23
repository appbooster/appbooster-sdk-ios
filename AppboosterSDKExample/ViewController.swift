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

    let ab = AppboosterAB(authToken: "<APITAPI_AUTH_TOKEN>",
                          deviceToken: "<DEVICE_TOKEN")
    ab.fetch(knownKeys: ["<TEST_1_KEY>", "<TEST_2_KEY>"],
             completion: { abError in
              guard abError == nil else { return }

              let test1Value: String? = ab.value("<TEST_1_KEY>")
              let test2Value: Int = ab.value("<TEST_2_KEY>", or: 3)

              print(test1Value ?? "", test2Value)
    })
  }

}
