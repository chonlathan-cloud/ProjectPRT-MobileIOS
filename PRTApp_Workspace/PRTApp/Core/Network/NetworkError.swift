//
//  NetworkError.swift
//  PRTApp_Workspace
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case timeout
    case serverError(statusCode: Int)
    case decodingFailed
}
