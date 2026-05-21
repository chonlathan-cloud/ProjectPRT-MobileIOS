//
//  BaseResponse.swift
//  PRTApp_Workspace
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let error: String?

    enum CodingKeys: String, CodingKey {
        case success
        case data
        case error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        data = try container.decode(T.self, forKey: .data)
        error = try? container.decodeIfPresent(String.self, forKey: .error)
    }
}
