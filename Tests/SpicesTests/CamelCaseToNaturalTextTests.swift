import Foundation
@testable import Spices
import Testing

@Suite
struct CamelCaseToNaturalTextTests {
    @Test
    func it_handles_simple_cases() async throws {
        #expect("simpleName".camelCaseToNaturalText() == "Simple Name")
        #expect("useLocalURL".camelCaseToNaturalText() == "Use Local URL")
        #expect("environment".camelCaseToNaturalText() == "Environment")
        #expect("enableLogging".camelCaseToNaturalText() == "Enable Logging")
        #expect("clearCache".camelCaseToNaturalText() == "Clear Cache")
        #expect("featureFlags".camelCaseToNaturalText() == "Feature Flags")
        #expect("notifications".camelCaseToNaturalText() == "Notifications")
        #expect("fastRefreshWidgets".camelCaseToNaturalText() == "Fast Refresh Widgets")
        #expect("ignoreNextHTTPRequest".camelCaseToNaturalText() == "Ignore Next HTTP Request")

        // Suboptimal, but heuristics for these would be annoying.
        #expect("httpVersion".camelCaseToNaturalText() == "Http Version")
        #expect("apiURL".camelCaseToNaturalText() == "Api URL")
    }
}
