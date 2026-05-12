//
//  ApprovalDetailView.swift
//  PRTApp_Workspace
//

import PDFKit
import SwiftUI

struct ApprovalDetailView: View {
    let caseId: String

    @State private var viewModel = ApprovalViewModel()
    @State private var isRejectSheetPresented = false
    @State private var rejectReason = ""
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 0) {
            documentSection
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Approval Detail")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            actionBar
        }
        .sheet(isPresented: $isRejectSheetPresented) {
            RejectReasonSheet(
                reason: $rejectReason,
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.errorMessage,
                onCancel: {
                    isRejectSheetPresented = false
                    rejectReason = ""
                },
                onReject: {
                    Task {
                        await viewModel.rejectCase(
                            caseId: caseId,
                            reason: rejectReason,
                            coordinator: coordinator
                        )

                        if viewModel.errorMessage == nil {
                            isRejectSheetPresented = false
                            rejectReason = ""
                        }
                    }
                }
            )
            .presentationDetents([.height(260), .medium])
        }
        .task {
            await viewModel.fetchPDF(for: caseId)
        }
    }

    @ViewBuilder
    private var documentSection: some View {
        if let url = viewModel.pdfURL {
            PDFKitView(url: url)
                .ignoresSafeArea(edges: .bottom)
        } else {
            VStack(spacing: 14) {
                ProgressView()
                Text("Loading document")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var actionBar: some View {
        VStack(spacing: 10) {
            if let errorMessage = viewModel.errorMessage, !isRejectSheetPresented {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                Button(role: .destructive) {
                    isRejectSheetPresented = true
                } label: {
                    Label("Reject", systemImage: "xmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(viewModel.isLoading)

                Button {
                    Task {
                        await viewModel.approveCase(caseId: caseId, coordinator: coordinator)
                    }
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isLoading {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        }

                        Label("Approve", systemImage: "checkmark.circle.fill")
                            .labelStyle(.titleAndIcon)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(viewModel.isLoading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.regularMaterial)
    }
}

private struct RejectReasonSheet: View {
    @Binding var reason: String
    let isLoading: Bool
    let errorMessage: String?
    let onCancel: () -> Void
    let onReject: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Reject reason", text: $reason, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isLoading)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Spacer(minLength: 0)
            }
            .padding(20)
            .navigationTitle("Reject Case")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .disabled(isLoading)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Reject", role: .destructive, action: onReject)
                        .disabled(isLoading || reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ApprovalDetailView(caseId: "CASE-001")
            .environment(AppCoordinator())
    }
}
