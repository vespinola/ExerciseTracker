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

    var id: String {
        switch self {
        case .home: "home"
        case .detail: "detail"
        }
    }
}

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()

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

    @MainActor @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .home:
            HomeView(
                viewModel: .init(
                    healthKitManager: healthKitManager,
                    onStepsCountTap: { [weak self] model in
                        self?.push(.detail(model))
                    }
                )
            )
        case .detail(let model):
            ChartDetailView(
                viewModel: .init(model: model, healthKitManager: self.healthKitManager)
            )
        }
    }

}
