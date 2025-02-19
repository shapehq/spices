import Combine
import Foundation
import Testing
@testable import Spices

@MainActor @Suite
final class SpiceTests {
    private var cancellables: Set<AnyCancellable> = []

    @Test func it_reads_default_bool_value() {
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        #expect(sut.boolValue == false)
    }

    @Test func it_stores_bool_value_in_user_defaults() {
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        #expect(sut.userDefaults.object(forKey: "boolValue") == nil)
        sut.boolValue = true
        #expect(sut.userDefaults.bool(forKey: "boolValue") == true)
    }

    @Test func it_reads_default_enum_Value() {
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        #expect(sut.enumValue == .production)
    }

    @Test func it_stores_enum_value_in_user_defaults() {
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        #expect(sut.userDefaults.object(forKey: "enumValue") == nil)
        sut.enumValue = .staging
        #expect(sut.userDefaults.string(forKey: "enumValue")  == MockEnvironment.staging.rawValue)
    }

    @Test func it_stores_button_closure() throws {
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        MockSpiceStore.buttonClosureCalled = false
        try sut.buttonValue()
        #expect(MockSpiceStore.buttonClosureCalled == true)
    }

    @Test func it_stores_async_button_closure() async throws {
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        MockSpiceStore.asynButtonClosureCalled = false
        try await sut.asyncButtonValue()
        #expect(MockSpiceStore.asynButtonClosureCalled == true)
    }

    @Test func it_sink_receives_initial_value() async throws {
        var initialValue: Bool?
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        sut.$boolValue.sink { newValue in
            initialValue = newValue
        }
        .store(in: &cancellables)
        #expect(initialValue == false)
    }

    @Test func it_publishes_values() async throws {
        var publishedValue: Bool?
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        sut.$boolValue.sink { newValue in
            publishedValue = newValue
        }
        .store(in: &cancellables)
        #expect(sut.boolValue == false)
        sut.boolValue = true
        #expect(publishedValue == true)
    }
}
