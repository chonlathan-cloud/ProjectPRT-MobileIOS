//
//  AppCoordinator.swift
//  PRTApp_Workspace
//

import Observation
import SwiftUI
enum Route: Hashable {
    case dashboard
    case approvalList
    case approvalDetail(caseId: String)
    case chatBot
}

extension Notification.Name {
    static let userUnauthorized = Notification.Name("ProjectPRT.userUnauthorized")
}

@MainActor
@Observable
final class AppCoordinator {
    var path = NavigationPath()
    var isLoggedIn = false

    @ObservationIgnored
    private var unauthorizedObserver: NSObjectProtocol?

    init(notificationCenter: NotificationCenter = .default) {
        unauthorizedObserver = notificationCenter.addObserver(
            forName: .userUnauthorized,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.logout()
            }
        }
    }

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard path.count > 0 else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func handleDeepLink(caseId: String) {
        popToRoot()
        push(.approvalDetail(caseId: caseId))
    }

    func loginSuccess() {
        isLoggedIn = true
        popToRoot()
    }

    func logout() {
        KeychainManager.shared.deleteToken()
        isLoggedIn = false
        popToRoot()
    }
}

