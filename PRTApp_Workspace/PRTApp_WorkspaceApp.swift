//
//  PRTApp_WorkspaceApp.swift
//  PRTApp_Workspace
//
//  Created by Chonlathan Songsri on 11/5/2569 BE.
//

import SwiftUI

@main
struct PRTApp_WorkspaceApp: App {
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            Group {
                if coordinator.isLoggedIn {
                    NavigationStack(path: $coordinator.path) {
                        Text("Dashboard Placeholder")
                            .navigationDestination(for: Route.self) { route in
                                destinationView(for: route)
                            }
                    }
                } else {
                    Text("Login View Placeholder")
                }
            }
            .environment(coordinator)
        }
    }

    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .dashboard:
            Text("Dashboard Placeholder")
        case .approvalList:
            Text("Approval List Placeholder")
        case .approvalDetail(let caseId):
            Text("Approval Detail Placeholder: \(caseId)")
        case .chatBot:
            Text("ChatBot Placeholder")
        }
    }
}
