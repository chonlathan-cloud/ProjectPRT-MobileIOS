//
//  InsightsViewModel.swift
//  PRTApp_Workspace
//

import Foundation
import Observation

struct InsightTransaction: Identifiable {
    let id = UUID()
    let docNo: String
    let date: Date
    let requesterName: String
    let amount: Double
    let purpose: String
}

@Observable
final class InsightsViewModel {
    var totalCount = 7
    var totalAmount = 53_280.0
    var pendingCount = 3
    var pendingAmount = 18_450.0
    var approvedCount = 4
    var approvedAmount = 34_830.0
    var transactions: [InsightTransaction] = InsightsViewModel.mockTransactions
    var showFilterSheet = false
    var selectedMonth = Calendar.current.component(.month, from: Date())
    var selectedYear = Calendar.current.component(.year, from: Date())

    let months = Array(1...12)
    let years = Array(2023...2026).reversed()

    func applyFilters() {
        showFilterSheet = false
    }

    private static var mockTransactions: [InsightTransaction] {
        [
            InsightTransaction(
                docNo: "PRT-2026-0007",
                date: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 13)) ?? Date(),
                requesterName: "Nattapong S.",
                amount: 12_800,
                purpose: "ค่าเดินทางพบลูกค้าองค์กร"
            ),
            InsightTransaction(
                docNo: "PRT-2026-0006",
                date: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 12)) ?? Date(),
                requesterName: "Sudarat K.",
                amount: 6_250,
                purpose: "ค่าอุปกรณ์สำนักงาน"
            ),
            InsightTransaction(
                docNo: "PRT-2026-0005",
                date: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 10)) ?? Date(),
                requesterName: "Krit P.",
                amount: 9_730,
                purpose: "ค่าอบรมทีมการเงิน"
            ),
            InsightTransaction(
                docNo: "PRT-2026-0004",
                date: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 8)) ?? Date(),
                requesterName: "Maneerat T.",
                amount: 3_900,
                purpose: "ค่าเอกสารและจัดส่ง"
            ),
            InsightTransaction(
                docNo: "PRT-2026-0003",
                date: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 6)) ?? Date(),
                requesterName: "Apichat W.",
                amount: 20_600,
                purpose: "ค่าที่ปรึกษาโครงการ"
            )
        ]
    }
}
