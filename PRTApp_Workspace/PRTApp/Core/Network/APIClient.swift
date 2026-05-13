//
//  APIClient.swift
//  PRTApp_Workspace
//

import Foundation

protocol APIClientProtocol: Sendable {
    func request<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String,
        body: U?,
        requiresAuth: Bool
    ) async throws -> T
}

extension APIClientProtocol {
    func request<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String,
        body: U?,
        requiresAuth: Bool = true
    ) async throws -> T {
        try await request(endpoint: endpoint, method: method, body: body, requiresAuth: requiresAuth)
    }

    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        requiresAuth: Bool = true
    ) async throws -> T {
        let emptyBody: EmptyRequestBody? = nil
        return try await request(
            endpoint: endpoint,
            method: method,
            body: emptyBody,
            requiresAuth: requiresAuth
        )
    }
}

private struct EmptyRequestBody: Encodable {}

final class APIClient: APIClientProtocol, @unchecked Sendable {
    static let shared = APIClient()

    private let baseURL: URL
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        baseURL: URL = URL(string: "https://backend-api-886029565568.asia-southeast1.run.app/api/v1")!,
        urlSession: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.decoder = decoder
        self.encoder = encoder
    }

    func request<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String = "GET",
        body: U? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = makeURL(for: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 15.0
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token = KeychainManager.shared.getToken() else {
                throw NetworkError.unauthorized
            }

            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch let urlError as URLError where urlError.code == .timedOut {
            throw NetworkError.timeout
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(statusCode: -1)
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed
            }
        case 401:
            await MainActor.run {
                NotificationCenter.default.post(name: .userUnauthorized, object: nil)
            }
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    private func makeURL(for endpoint: String) -> URL? {
        let base = baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedEndpoint = endpoint.hasPrefix("/") ? endpoint : "/\(endpoint)"
        return URL(string: base + normalizedEndpoint)
    }
}
