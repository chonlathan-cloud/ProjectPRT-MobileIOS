//
//  LoginViewModel.swift
//  PRTApp_Workspace
//

import Foundation
import Observation

@MainActor
@Observable
final class LoginViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored
    private let apiClient: any APIClientProtocol

    init(apiClient: (any APIClientProtocol)? = nil) {
        self.apiClient = apiClient ?? APIClient.shared
    }

    func login(coordinator: AppCoordinator) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let loginRequest = LoginRequest(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )

        do {
            let response: LoginResponse = try await apiClient.request(
                endpoint: "/auth/login",
                method: "POST",
                body: loginRequest,
                requiresAuth: false
            )

            try KeychainManager.shared.saveToken(response.accessToken)

            let payload = JWTDecoder.decode(jwtToken: response.accessToken)
            let role = payload?["role"] as? String ?? ""

            guard role != "requester" else {
                KeychainManager.shared.deleteToken()
                errorMessage = "Access Denied: Requesters must use the web platform."
                return
            }

            coordinator.loginSuccess(role: role)
        } catch let networkError as NetworkError {
            errorMessage = message(for: networkError)
        } catch {
            errorMessage = "Unable to login. Please try again."
        }
    }

    func loginWithGoogle(coordinator: AppCoordinator) async {
        print("Google sign-in reserved for future ASWebAuthenticationSession implementation.")
    }

    private func message(for error: NetworkError) -> String {
        switch error {
        case .unauthorized:
            return "Invalid email or password."
        case .timeout:
            return "The login request timed out. Please try again."
        case .serverError(let statusCode):
            if statusCode == 400 || statusCode == 401 || statusCode == 403 {
                return "Invalid email or password."
            }

            return "Login service is unavailable. Please try again later."
        case .decodingFailed:
            return "Unable to read login response. Please try again."
        case .invalidURL:
            return "Login service URL is invalid."
        }
    }
}
