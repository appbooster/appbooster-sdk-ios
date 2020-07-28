//
//  AppboosterKeychain.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit
import Security

struct AppboosterKeychain {

  private static let userAccount: NSString = "AppboosterUser"
  private static let deviceIdKey: NSString = "AppboosterDeviceID"

  private static let kSecClassValue: NSString = NSString(format: kSecClass)
  private static let kSecAttrAccountValue: NSString = NSString(format: kSecAttrAccount)
  private static let kSecValueDataValue: NSString = NSString(format: kSecValueData)
  private static let kSecClassGenericPasswordValue: NSString = NSString(format: kSecClassGenericPassword)
  private static let kSecAttrServiceValue: NSString = NSString(format: kSecAttrService)
  private static let kSecMatchLimitValue: NSString = NSString(format: kSecMatchLimit)
  private static let kSecReturnDataValue: NSString = NSString(format: kSecReturnData)
  private static let kSecMatchLimitOneValue: NSString = NSString(format: kSecMatchLimitOne)
  private static let kSecAttrAccessibleValue: NSString = NSString(format: kSecAttrAccessible)
  private static let kSecAttrAccessibleAfterFirstUnlockValue: NSString = NSString(format: kSecAttrAccessibleAfterFirstUnlock)

  static func getDeviceId() -> String? {
    let keychainQuery: NSMutableDictionary = NSMutableDictionary(
      objects: [kSecClassGenericPasswordValue, deviceIdKey, userAccount, kCFBooleanTrue!, kSecMatchLimitOneValue],
      forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue]
    )

    var dataTypeRef: AnyObject?

    let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
    var contentsOfKeychain: String?

    if status == errSecSuccess,
      let retrievedData = dataTypeRef as? Data {
      contentsOfKeychain = String(data: retrievedData, encoding: .utf8)
    }

    return contentsOfKeychain
  }

  static func setNewDeviceId() -> String {
    let deviceId: String = UUID().uuidString

    if let dataFromString = deviceId.data(using: .utf8, allowLossyConversion: false) {
      let keychainQuery: NSMutableDictionary = [
        kSecClassValue: kSecClassGenericPasswordValue,
        kSecAttrServiceValue: deviceIdKey,
        kSecAttrAccountValue: userAccount,
        kSecValueDataValue: dataFromString,
        kSecAttrAccessibleValue: kSecAttrAccessibleAfterFirstUnlockValue
      ]

      SecItemDelete(keychainQuery as CFDictionary)
      SecItemAdd(keychainQuery as CFDictionary, nil)
    }

    return deviceId
  }
}
