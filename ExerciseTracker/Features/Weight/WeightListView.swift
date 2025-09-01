//
//  WeightListView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-18.
//

import SwiftUI

struct WeightListView: View {
    private var healthKitManager: HealthKitManaging
    @State private var pendingDelete: IndexSet? = nil
    @State private var showDeleteAlert = false
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
        .alert("Are you sure you want to delete this entry?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let offsets = pendingDelete {
                    for index in offsets {
                        if let sample = list[index].sample {
                            healthKitManager.deleteSample(sample: sample)
                        }
                    }
                    list.remove(atOffsets: offsets)
                }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("This action cannot be undone and will remove the data from Health app.")
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
        pendingDelete = offsets
        showDeleteAlert = true
    }
}

#Preview {
    WeightListView(healthKitManager: MockHealthKitManager())
}
