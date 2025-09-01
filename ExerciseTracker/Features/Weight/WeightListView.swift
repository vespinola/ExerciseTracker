//
//  WeightListView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-18.
//

import SwiftUI

struct WeightListView: View {
    private var healthKitManager: HealthKitManaging
    @State private var list: [MetricDetailModel] = []

    init(healthKitManager: HealthKitManaging) {
        self.healthKitManager = healthKitManager
    }

    var body: some View {
        List {
            ForEach(list) {
                detailRow(metricDetailModel: $0)
            }
            .onDelete(perform: deleteItems)
        }
        .task {
            let weightList = try? await healthKitManager
                .fetchBodyMassData(unit: .gramUnit(with: .kilo), formatter: { String(format: "%.1f Kg", $0) }, startDate: .distantPast, endDate: .now)
            list = weightList?.details.reversed() ?? []
        }
        .navigationTitle("Your progress 🙌")
    }

    @ViewBuilder
    private func detailRow(metricDetailModel: MetricDetailModel) -> some View {
        HStack {
            Text(String(format: "%.1f Kg", metricDetailModel.value))
                .font(.headline)
            Spacer()
            Text(metricDetailModel.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        list.remove(atOffsets: offsets) // Remove items from the source array
    }
}

#Preview {
    WeightListView(healthKitManager: MockHealthKitManager())
}
