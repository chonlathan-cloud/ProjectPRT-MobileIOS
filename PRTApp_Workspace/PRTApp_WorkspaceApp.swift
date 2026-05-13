//
//  PRTApp_WorkspaceApp.swift
//  PRTApp_Workspace
//
//  Created by Chonlathan Songsri on 11/5/2569 BE.
//

import SwiftData
import SwiftUI

@main
struct PRTApp_WorkspaceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            Group {
                if coordinator.isLoggedIn {
                    NavigationStack(path: $coordinator.path) {
                        MainTabView()
                            .navigationDestination(for: Route.self) { route in
                                destinationView(for: route)
                            }
                    }
                } else {
                    LoginView()
                }
            }
            .environment(coordinator)
        }
        .modelContainer(for: [DashboardCache.self, PendingCaseCache.self])
    }

    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .dashboard:
            DashboardView()
        case .approvalList:
            ApprovalListView()
        case .approvalDetail(let caseId):
            ApprovalDetailView(caseId: caseId)
        case .chatBot:
            ChatView()
        }
    }
}
