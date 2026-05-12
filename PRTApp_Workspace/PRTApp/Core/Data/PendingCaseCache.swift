//
//  PendingCaseCache.swift
//  PRTApp_Workspace
//

import Foundation
import SwiftData

@Model
final class PendingCaseCache {
    @Attribute(.unique) var caseId: String
    var docNo: String
    var docType: String
    var amount: Double
    var purpose: String
    var status: String

    init(
        caseId: String,
        docNo: String,
        docType: String,
        amount: Double,
        purpose: String,
        status: String
    ) {
        self.caseId = caseId
        self.docNo = docNo
        self.docType = docType
        self.amount = amount
        self.purpose = purpose
        self.status = status
    }
}
