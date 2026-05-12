//
//  DashboardCache.swift
//  PRTApp_Workspace
//

import Foundation
import SwiftData

@Model
final class DashboardCache {
    @Attribute(.unique) var year: Int
    var totalRevenue: Double
    var totalExpense: Double
    var balance: Double
    var lastUpdated: Date

    init(year: Int, revenue: Double, expense: Double, balance: Double) {
        self.year = year
        self.totalRevenue = revenue
        self.totalExpense = expense
        self.balance = balance
        self.lastUpdated = Date()
    }
}
