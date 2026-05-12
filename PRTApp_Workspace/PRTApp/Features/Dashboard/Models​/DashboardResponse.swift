//
//  DashboardResponse.swift
//  PRTApp_Workspace
//

import Foundation

struct DashboardResponse: Decodable {
    let summary: Summary

    struct Summary: Decodable {
        let totalRevenue: Double
        let totalExpense: Double
        let balance: Double

        enum CodingKeys: String, CodingKey {
            case totalRevenue = "total_revenue"
            case totalExpense = "total_expense"
            case balance
        }
    }
}
