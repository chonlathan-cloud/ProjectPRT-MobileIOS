//
//  ApprovalViewModel.swift
//  PRTApp_Workspace
//

import Foundation
import Observation

@MainActor
@Observable
final class ApprovalViewModel {
    var isLoading = false
    var errorMessage: String?
    var pdfURL: URL?

    func fetchPDF(for caseId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        try? await Task.sleep(for: .milliseconds(700))

        guard let url = URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf") else {
            errorMessage = "Unable to load document."
            return
        }

        pdfURL = url
    }

    func approveCase(caseId: String, coordinator: AppCoordinator) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        try? await Task.sleep(for: .seconds(1))
        print("Approved case: \(caseId)")
        coordinator.pop()
    }

    func rejectCase(caseId: String, reason: String, coordinator: AppCoordinator) async {
        let trimmedReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedReason.isEmpty else {
            errorMessage = "Reject reason is required."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        try? await Task.sleep(for: .seconds(1))
        print("Rejected case: \(caseId), reason: \(trimmedReason)")
        coordinator.pop()
    }
}
