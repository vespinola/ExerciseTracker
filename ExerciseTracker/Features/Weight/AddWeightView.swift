//
//  AddWeightView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-13.
//

import SwiftUI

struct AddWeightView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedDate = Date()
    @State private var weigth: String = ""
    private var healthKitManager: HealthKitManaging

    init(healthKitManager: HealthKitManaging) {
        self.healthKitManager = healthKitManager
    }

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        DatePicker(
                            "Date",
                            selection: $selectedDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        DatePicker(
                            "Time",
                            selection: $selectedDate,
                            in: ...Date(),
                            displayedComponents: .hourAndMinute
                        )
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("kg")
                            TextField("0", text: $weigth)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(.plain)
                                .focused($isTextFieldFocused)
                                .onAppear {
                                    isTextFieldFocused = true
                                }

                        }
                    } header: {
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "figure.walk.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(.blue)
                                .frame(width: 60, height: 60)
                            Text("Weight")
                                .font(.largeTitle)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Save") {
                                    guard let convertedWeight = Double(weigth) else { return }
                                    healthKitManager.saveBodyMass(date: selectedDate, bodyBass: convertedWeight)
                                    NotificationCenter.default.post(name: .weightDidChange, object: nil)
                                    dismiss()
                                }
                            }
                        }
                        .textCase(.none)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    AddWeightView(healthKitManager: MockHealthKitManager())
}
