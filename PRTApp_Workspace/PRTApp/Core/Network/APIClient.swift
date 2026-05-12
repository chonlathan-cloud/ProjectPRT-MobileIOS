//
//  APIClient.swift
//  PRTApp_Workspace
//

import Foundation

protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(endpoint: String, method: String, body: Data?) async throws -> T
}

final class APIClient: APIClientProtocol, @unchecked Sendable {
    static let shared = APIClient()

    private let baseURL: URL
    private let urlSession: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL? = URL(string: "https://api.projectprt.com/v1/"),
        urlSession: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        guard let baseURL else {
            preconditionFailure("Invalid API base URL.")
        }

        self.baseURL = baseURL
        self.urlSession = urlSession
        self.decoder = decoder
    }

    func request<T: Decodable>(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let token = KeychainManager.shared.getToken() else {
            throw NetworkError.unauthorized
        }

        guard let url = makeURL(for: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.timeoutInterval = 15.0
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
        let normalizedEndpoint = endpoint.hasPrefix("/") ? String(endpoint.dropFirst()) : endpoint
        return URL(string: normalizedEndpoint, relativeTo: baseURL)?.absoluteURL
    }
}
