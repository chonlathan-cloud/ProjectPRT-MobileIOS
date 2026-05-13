//
//  ApprovalListView.swift
//  PRTApp_Workspace
//

import SwiftUI

struct ApprovalListView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            Button {
                coordinator.push(.approvalDetail(caseId: "CAS-12345"))
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text("PV-2605-0001")
                        .font(.headline)
                        .foregroundStyle(.blue)

                    Text("ค่าอุปกรณ์ไอที")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Pending Approvals")
    }
}

#Preview {
    NavigationStack {
        ApprovalListView()
            .environment(AppCoordinator())
    }
}
