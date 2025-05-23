import Combine
import Foundation
@testable import Spices
import Testing

@MainActor @Suite(.serialized)
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
        #expect(sut.userDefaults.string(forKey: "enumValue") == MockEnvironment.staging.rawValue)
    }

    @Test func it_stores_string_value_in_user_defaults() {
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        #expect(sut.userDefaults.object(forKey: "textValue") == nil)
        sut.textValue = "Test value"
        #expect(sut.userDefaults.string(forKey: "textValue") == "Test value")
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
        var initialValue: MockEnvironment?
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        sut.prepareIfNeeded()
        sut.$enumValue.sink { newValue in
            initialValue = newValue
        }
        .store(in: &cancellables)
        #expect(initialValue == .production)
    }

    @Test func it_sink_receives_initial_value_if_it_has_been_changed() async throws {
        var initialValue: MockEnvironment?
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        sut.userDefaults.set(MockEnvironment.staging.rawValue, forKey: "enumValue")
        sut.prepareIfNeeded()
        sut.$enumValue.sink { newValue in
            initialValue = newValue
        }
        .store(in: &cancellables)
        #expect(initialValue == .staging)
    }

    @Test func it_publishes_values() async throws {
        var publishedValue: MockEnvironment?
        let sut = MockSpiceStore()
        sut.userDefaults.removeAll()
        sut.prepareIfNeeded()
        sut.$enumValue.sink { newValue in
            publishedValue = newValue
        }
        .store(in: &cancellables)
        #expect(sut.enumValue == .production)
        sut.enumValue = .staging
        #expect(publishedValue == .staging)
    }
}
