//
//  JWTToken.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import Foundation
import CommonCrypto

public struct JWTToken {

  public static func generate(
    deviceId: String,
    deviceProperties: [String: Any],
    appsFlyerId: String?,
    amplitudeId: String?,
    sdkToken: String
  ) -> String? {
    let header: [String: Any] = [
      "alg": "HS256",
      "typ": "JWT"
    ]
    let payload: [String: Any] = [
      "deviceId": deviceId,
      "deviceProperties": deviceProperties,
      "appsFlyerId": appsFlyerId ?? "",
      "amplitudeId": amplitudeId ?? ""
    ]

    guard let jsonHeader = try? JSONSerialization.data(withJSONObject: header, options: []),
      let jsonPayload = try? JSONSerialization.data(withJSONObject: payload, options: [])
      else { return nil }

    let encodedHeader = base64encodeURISafe(jsonHeader)
    let encodedPayload = base64encodeURISafe(jsonPayload)

    let signatureInput = "\(encodedHeader).\(encodedPayload)"

    guard let signature = getSignature(sdkToken, input: signatureInput) else { return nil }

    return String(
      format: "%@.%@",
      stringURISafe(signatureInput),
      stringURISafe(signature)
    )
  }

  private static func getSignature(_ secret: String, input: String) -> String? {
    guard let inputData = input.data(using: .utf8, allowLossyConversion: false),
      let secretData = secret.data(using: .utf8, allowLossyConversion: false)
      else { return nil }

    let hmacData = hmac(secretData: secretData, inputData: inputData)

    return hmacData.base64EncodedString()
  }

  private static func hmac(secretData: Data, inputData: Data) -> Data {
    var hmacOutData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

    // Force unwrapping is ok, since input count is checked and key and algorithm are assumed not to be empty.
    // From the docs: If the baseAddress of this buffer is nil, the count is zero.
    hmacOutData.withUnsafeMutableBytes { hmacOutBytes in
      secretData.withUnsafeBytes { keyBytes in
        inputData.withUnsafeBytes { inputBytes in
          CCHmac(
            CCHmacAlgorithm(kCCHmacAlgSHA256),
            keyBytes.baseAddress!, secretData.count,
            inputBytes.baseAddress!, inputData.count,
            hmacOutBytes.baseAddress!
          )
        }
      }
    }

    return hmacOutData
  }

  private static func stringURISafe(_ input: String) -> String {
    return input
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }

  private static func base64encodeURISafe(_ input: Data) -> String {
    if let string = String(data: input.base64EncodedData(), encoding: .utf8) {
      return string
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    }

    return ""
  }

}
