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
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            Group {
                if coordinator.isLoggedIn {
                    NavigationStack(path: $coordinator.path) {
                        DashboardView()
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
            Text("Approval List Placeholder")
        case .approvalDetail(let caseId):
            ApprovalDetailView(caseId: caseId)
        case .chatBot:
            Text("ChatBot Placeholder")
        }
    }
}
