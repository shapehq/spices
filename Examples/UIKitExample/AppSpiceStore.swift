import Foundation
import Spices
import SwiftUI

enum ServiceEnvironment: String, CaseIterable {
    case production
    case staging
}

final class AppSpiceStore: SpiceStore {
    @MainActor
    static let shared = AppSpiceStore()

    @Spice(requiresRestart: true) var environment: ServiceEnvironment = .production
    @Spice(name: "API URL") var apiURL = "http://example.com"

    @Spice(presentation: .inline) var debugging = DebuggingSpiceStore()

    @Spice var featureFlags = FeatureFlagsSpiceStore()
    @Spice(presentation: .push) var helloWorld = VStack {
        Image(systemName: "globe")
            .imageScale(.large)
            .foregroundStyle(.tint)
        Text("Hello, world!")
    }
    .padding()
    @Spice var version = LabeledContent("Version", value: "1.0 (1)")
    @Spice var userId: String = "Not loaded"

    private init() {}

    func onAppear() {
        userId = "\(Int.random(in: 0...100))"
    }
}

final class DebuggingSpiceStore: SpiceStore {
    @Spice var enableLogging = false
    @Spice var clearCache = {
        try await Task.sleep(for: .seconds(1))
        URLCache.shared.removeAllCachedResponses()
    }

    fileprivate init() {}
}

final class FeatureFlagsSpiceStore: SpiceStore {
    @Spice var notifications = false
    @Spice var fastRefreshWidgets = false

    fileprivate init() {}
}
