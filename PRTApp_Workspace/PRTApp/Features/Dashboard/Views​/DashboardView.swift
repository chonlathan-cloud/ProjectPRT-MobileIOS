//
//  DashboardView.swift
//  PRTApp_Workspace
//

import Charts
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DashboardCache.year, order: .reverse) private var caches: [DashboardCache]
    @State private var viewModel = DashboardViewModel()

    private var latestCache: DashboardCache? {
        caches.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView

                if viewModel.isOfflineMode {
                    offlineBanner
                }

                if let cache = latestCache {
                    summarySection(for: cache)
                    chartSection(for: cache)
                } else {
                    emptyStateView
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Dashboard")
        .task {
            await refreshDashboard()
        }
        .refreshable {
            await refreshDashboard()
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Executive Dashboard")
                .font(.title2.weight(.semibold))

            Text("Financial summary for the current fiscal year")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var offlineBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text("⚠️ Offline Mode: Showing cached data")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func summarySection(for cache: DashboardCache) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Summary")
                    .font(.headline)

                Spacer()

                Text("Updated \(cache.lastUpdated, format: .dateTime.day().month().hour().minute())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                SummaryMetricCard(
                    title: "Revenue",
                    value: cache.totalRevenue,
                    systemImage: "arrow.up.right",
                    tint: .green
                )

                SummaryMetricCard(
                    title: "Expense",
                    value: cache.totalExpense,
                    systemImage: "arrow.down.right",
                    tint: .red
                )

                SummaryMetricCard(
                    title: "Balance",
                    value: cache.balance,
                    systemImage: "equal.circle",
                    tint: cache.balance >= 0 ? .blue : .orange
                )
            }
        }
    }

    private func chartSection(for cache: DashboardCache) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Income vs Expense")
                .font(.headline)

            Chart(chartItems(for: cache)) { item in
                BarMark(
                    x: .value("Category", item.title),
                    y: .value("Amount", item.value)
                )
                .foregroundStyle(item.color)
                .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 240)
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.regular)
            }

            Text(viewModel.isLoading ? "Loading dashboard" : "No cached dashboard data")
                .font(.headline)

            Text("Pull to refresh when a network connection is available.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func refreshDashboard() async {
        let year = Calendar.current.component(.year, from: Date())
        await viewModel.fetchDashboard(year: year, context: modelContext)
    }

    private func chartItems(for cache: DashboardCache) -> [DashboardChartItem] {
        [
            DashboardChartItem(title: "Revenue", value: cache.totalRevenue, color: .green),
            DashboardChartItem(title: "Expense", value: cache.totalExpense, color: .red)
        ]
    }
}

private struct SummaryMetricCard: View {
    let title: String
    let value: Double
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(tint)
            }

            Text(value, format: .currency(code: "THB"))
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .padding(16)
        .frame(minHeight: 112, alignment: .topLeading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct DashboardChartItem: Identifiable {
    let title: String
    let value: Double
    let color: Color

    var id: String { title }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: DashboardCache.self, inMemory: true)
}
