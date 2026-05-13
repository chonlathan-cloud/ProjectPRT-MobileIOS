//
//  MainTabView.swift
//  PRTApp_Workspace
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        TabView(selection: selectedTabBinding) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
                .tag(AppTab.dashboard)

            if coordinator.userRole == "admin" {
                ApprovalListView()
                    .tabItem {
                        Label("Approvals", systemImage: "checkmark.seal.fill")
                    }
                    .tag(AppTab.approvals)
            }

            ChatView()
                .tabItem {
                    Label("FinBot", systemImage: "message.fill")
                }
                .tag(AppTab.chatbot)
        }
    }

    private var selectedTabBinding: Binding<AppTab> {
        Binding(
            get: { coordinator.selectedTab },
            set: { newValue in
                coordinator.selectedTab = newValue
            }
        )
    }
}

#Preview {
    MainTabView()
        .environment(AppCoordinator())
}
