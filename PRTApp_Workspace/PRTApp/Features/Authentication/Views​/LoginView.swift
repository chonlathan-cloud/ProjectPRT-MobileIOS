//
//  LoginView.swift
//  PRTApp_Workspace
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    headerView

                    VStack(spacing: 16) {
                        inputFields
                        errorView
                        loginButton
                        googleButton
                    }
                    .padding(24)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
                }
                .frame(maxWidth: 420)
                .padding(.horizontal, 24)
                .padding(.vertical, 48)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor)
                    .frame(width: 64, height: 64)

                Text("PRT")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text("ProjectPRT Executive")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("Executive & Approver Workspace")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var inputFields: some View {
        VStack(spacing: 12) {
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.isLoading)

            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .submitLabel(.go)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.isLoading)
                .onSubmit {
                    Task { await viewModel.login(coordinator: coordinator) }
                }
        }
    }

    @ViewBuilder
    private var errorView: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("loginErrorMessage")
        }
    }

    private var loginButton: some View {
        Button {
            Task { await viewModel.login(coordinator: coordinator) }
        } label: {
            HStack(spacing: 10) {
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                }

                Text(viewModel.isLoading ? "Signing In" : "Login")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isLoading)
    }

    private var googleButton: some View {
        Button {
            Task { await viewModel.loginWithGoogle(coordinator: coordinator) }
        } label: {
            Text("Sign in with Google")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.isLoading)
    }
}

#Preview {
    LoginView()
        .environment(AppCoordinator())
}
