//
//  InsightsResponse.swift
//  PRTApp_Workspace
//

import Foundation

struct InsightsData: Decodable {
    let summary: InsightsSummary
    let transactions: [InsightTransaction]
}

struct InsightsSummary: Decodable {
    let normal_count: Int
    let normal_amount: Double
    let pending_count: Int
    let pending_amount: Double
    let approved_count: Int
    let approved_amount: Double
}

struct InsightTransaction: Decodable, Identifiable {
    let id: String
    let doc_no: String
    let date: String
    let creator_id: String
    let user_code: String
    let purpose: String
    let amount: Double
    let status: String
}
