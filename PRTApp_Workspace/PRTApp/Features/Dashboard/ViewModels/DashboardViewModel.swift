//
//  DashboardViewModel.swift
//  PRTApp_Workspace
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class DashboardViewModel {
    var isLoading = false
    var errorMessage: String?
    var isOfflineMode = false

    func fetchDashboard(year: Int, context: ModelContext) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await fetchRemoteDashboard(year: year)
            isOfflineMode = false
            try upsertDashboardCache(from: response, year: year, context: context)
        } catch {
            isOfflineMode = true
            errorMessage = "Unable to refresh dashboard. Showing cached data."
        }
    }

    private func fetchRemoteDashboard(year: Int) async throws -> DashboardResponse {
        try await Task.sleep(for: .milliseconds(650))

        let revenue = Double(year) * 98_450.0
        let expense = Double(year) * 61_280.0
        let json = """
        {
            "summary": {
                "total_revenue": \(revenue),
                "total_expense": \(expense),
                "balance": \(revenue - expense)
            }
        }
        """

        let data = Data(json.utf8)
        return try JSONDecoder().decode(DashboardResponse.self, from: data)
    }

    private func upsertDashboardCache(
        from response: DashboardResponse,
        year: Int,
        context: ModelContext
    ) throws {
        var descriptor = FetchDescriptor<DashboardCache>(
            predicate: #Predicate { cache in
                cache.year == year
            }
        )
        descriptor.fetchLimit = 1

        if let cache = try context.fetch(descriptor).first {
            cache.totalRevenue = response.summary.totalRevenue
            cache.totalExpense = response.summary.totalExpense
            cache.balance = response.summary.balance
            cache.lastUpdated = Date()
        } else {
            let cache = DashboardCache(
                year: year,
                revenue: response.summary.totalRevenue,
                expense: response.summary.totalExpense,
                balance: response.summary.balance
            )
            context.insert(cache)
        }

        try context.save()
    }
}
