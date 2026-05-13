//
//  JWTDecoder.swift
//  PRTApp_Workspace
//

import Foundation

struct JWTDecoder {
    static func decode(jwtToken: String) -> [String: Any]? {
        let segments = jwtToken.split(separator: ".")
        guard segments.count >= 2 else { return nil }

        var payload = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddingLength = 4 - (payload.count % 4)
        if paddingLength < 4 {
            payload += String(repeating: "=", count: paddingLength)
        }

        guard let data = Data(base64Encoded: payload),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let payloadDictionary = jsonObject as? [String: Any] else {
            return nil
        }

        return payloadDictionary
    }
}
