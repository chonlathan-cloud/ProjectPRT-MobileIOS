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

enum AppTab: Hashable {
    case dashboard
    case approvals
    case chatbot
}

extension Notification.Name {
    static let userUnauthorized = Notification.Name("ProjectPRT.userUnauthorized")
    static let fcmDeepLink = Notification.Name("fcmDeepLink")
}

@MainActor
@Observable
final class AppCoordinator {
    var path = NavigationPath()
    var isLoggedIn = false
    var selectedTab: AppTab = .dashboard
    var userRole = ""

    @ObservationIgnored
    private var unauthorizedObserver: NSObjectProtocol?

    @ObservationIgnored
    private var fcmDeepLinkObserver: NSObjectProtocol?

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

        fcmDeepLinkObserver = notificationCenter.addObserver(
            forName: .fcmDeepLink,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let caseId = notification.userInfo?["caseId"] as? String else { return }

            Task { @MainActor [weak self] in
                self?.handleDeepLink(caseId: caseId)
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

    func loginSuccess(role: String) {
        userRole = role
        isLoggedIn = true
        selectedTab = .dashboard
        popToRoot()
    }

    func logout() {
        KeychainManager.shared.deleteToken()
        userRole = ""
        isLoggedIn = false
        selectedTab = .dashboard
        popToRoot()
    }
}
