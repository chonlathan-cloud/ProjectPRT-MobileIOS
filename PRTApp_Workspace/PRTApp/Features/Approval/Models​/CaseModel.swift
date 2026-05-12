//
//  CaseModel.swift
//  PRTApp_Workspace
//

import Foundation

struct PendingCase: Decodable, Identifiable {
    let caseId: String
    let docNo: String
    let docType: String
    let amount: Double
    let purpose: String

    var id: String { caseId }

    enum CodingKeys: String, CodingKey {
        case caseId = "case_id"
        case docNo = "doc_no"
        case docType = "doc_type"
        case amount
        case purpose
    }
}

struct ApprovalRequestBody: Codable {
    let rejectReason: String?

    enum CodingKeys: String, CodingKey {
        case rejectReason = "reject_reason"
    }
}
