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

    func login(coordinator: AppCoordinator) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        try? await Task.sleep(for: .seconds(1.5))

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedEmail.localizedCaseInsensitiveContains("requester") else {
            errorMessage = "Access Denied: Requesters must use the web platform."
            return
        }

        do {
            try KeychainManager.shared.saveToken("mock_jwt_token_123")
            coordinator.loginSuccess()
        } catch {
            errorMessage = "Unable to save session securely. Please try again."
        }
    }

    func loginWithGoogle(coordinator: AppCoordinator) async {
        print("Google sign-in reserved for future ASWebAuthenticationSession implementation.")
    }
}
