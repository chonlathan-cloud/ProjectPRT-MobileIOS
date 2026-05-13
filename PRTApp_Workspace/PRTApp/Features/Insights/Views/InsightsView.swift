//
//  InsightsView.swift
//  PRTApp_Workspace
//

import SwiftUI

struct InsightsView: View {
    @State private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    kpiCardsSection
                    transactionListSection
                }
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Insights")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Open filters")
                }
            }
            .sheet(isPresented: $viewModel.showFilterSheet) {
                FilterSheet(viewModel: viewModel)
                    .presentationDetents([.height(300), .medium])
            }
        }
    }

    private var kpiCardsSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                KPICardView(
                    title: "รายการปกติ",
                    count: viewModel.totalCount,
                    amount: viewModel.totalAmount,
                    isPrimary: false
                )

                KPICardView(
                    title: "รอดำเนินการ",
                    count: viewModel.pendingCount,
                    amount: viewModel.pendingAmount,
                    isPrimary: false
                )

                KPICardView(
                    title: "อนุมัติแล้ว",
                    count: viewModel.approvedCount,
                    amount: viewModel.approvedAmount,
                    isPrimary: true
                )
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }

    private var transactionListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("รายการทั้งหมด")
                .font(.headline)
                .padding(.horizontal, 20)

            LazyVStack(spacing: 10) {
                ForEach(viewModel.transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct KPICardView: View {
    let title: String
    let count: Int
    let amount: Double
    let isPrimary: Bool

    private var backgroundColor: Color {
        isPrimary ? .blue : Color(.secondarySystemGroupedBackground)
    }

    private var titleColor: Color {
        isPrimary ? .white.opacity(0.86) : .secondary
    }

    private var countColor: Color {
        isPrimary ? .white : .blue
    }

    private var amountColor: Color {
        isPrimary ? .white : .primary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(titleColor)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(count)")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(countColor)

                Text("รายการ")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(titleColor)
            }

            Text(amount, format: .currency(code: "THB"))
                .font(.title3.weight(.semibold))
                .foregroundStyle(amountColor)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(18)
        .frame(width: 210, height: 154, alignment: .topLeading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(isPrimary ? Color.clear : Color.black.opacity(0.06), lineWidth: 1)
        }
    }
}

private struct TransactionRowView: View {
    let transaction: InsightTransaction

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(transaction.docNo)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.blue)
                    .lineLimit(1)

                Spacer(minLength: 12)

                Text(transaction.amount, format: .currency(code: "THB"))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(transaction.date, format: .dateTime.day().month().year())
                    Text("•")
                    Text(transaction.requesterName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Text(transaction.purpose)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        }
    }
}

private struct FilterSheet: View {
    @Bindable var viewModel: InsightsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Period") {
                    Picker("Month", selection: $viewModel.selectedMonth) {
                        ForEach(viewModel.months, id: \.self) { month in
                            Text(monthName(for: month)).tag(month)
                        }
                    }

                    Picker("Year", selection: $viewModel.selectedYear) {
                        ForEach(Array(viewModel.years), id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showFilterSheet = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        viewModel.applyFilters()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        return formatter.monthSymbols[max(0, min(month - 1, 11))]
    }
}

#Preview {
    InsightsView()
}
