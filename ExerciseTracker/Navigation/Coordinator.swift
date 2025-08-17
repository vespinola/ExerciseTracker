//
//  Coordinator.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-02.
//

import SwiftUI

enum Page: Hashable, Identifiable {
    case home
    case detail(ChartDetailModel)
    case settings

    var id: String {
        switch self {
            case .home: "home"
            case .detail: "detail"
            case .settings: "settings"
        }
    }
}

enum Sheet: Identifiable {
    case addWeight

    var id: String {
        switch self {
            case .addWeight:
                return "addWeight"
        }
    }
}

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var sheet: Sheet?

    // MARK: DI
    private let healthKitManager: HealthKitManaging

    init(healthKitManager: HealthKitManaging) {
        self.healthKitManager = healthKitManager
    }

    func push(_ page: Page) {
        path.append(page)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func present(sheet: Sheet) {
        self.sheet = sheet
    }

    func dismissSheet() {
        self.sheet = nil
    }

    @MainActor @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
            case .home:
                HomeView(
                    viewModel: .init(
                        healthKitManager: healthKitManager,
                        onStepsCountTap: { [weak self] model in
                            guard let self else { return }
                            push(.detail(model))
                        },
                        onSettingsTap: { [weak self] in
                            guard let self else { return }
                            push(.settings)
                        }
                    )
                )
            case .detail(let model):
                ChartDetailView(
                    viewModel: .init(model: model, healthKitManager: self.healthKitManager)
                )
            case .settings:
                SettingsMainView()
                    .environmentObject(self)
        }
    }

    @ViewBuilder
    func build(sheet: Sheet) -> some View {
        switch sheet {
            case .addWeight:
                AddWeightView(healthKitManager: healthKitManager)
        }
    }
}

