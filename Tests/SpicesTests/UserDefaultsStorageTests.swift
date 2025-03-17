import Combine
import Foundation
import Testing
@testable import Spices

@MainActor @Suite
final class UserDefaultsStorageTests {
    @Test
    func it_returns_default_value() async throws {
        let spiceStore = MockSpiceStore()
        spiceStore.userDefaults.removeAll()
        let sut = UserDefaultsStorage(default: "default", key: nil)
        sut.prepare(propertyName: "foo", ownedBy: spiceStore)
        #expect(sut.value == "default")
    }

    @Test
    func it_stores_value_under_property_name() async throws {
        let spiceStore = MockSpiceStore()
        spiceStore.userDefaults.removeAll()
        let sut = UserDefaultsStorage(default: "default", key: nil)
        sut.prepare(propertyName: "foo", ownedBy: spiceStore)
        sut.value = "Hello world!"
        #expect(spiceStore.userDefaults.string(forKey: "foo") == "Hello world!")
    }

    @Test
    func it_stores_value_under_provided_key() async throws {
        let spiceStore = MockSpiceStore()
        spiceStore.userDefaults.removeAll()
        let sut = UserDefaultsStorage(default: "default", key: "bar")
        sut.prepare(propertyName: "foo", ownedBy: spiceStore)
        sut.value = "Hello world!"
        #expect(spiceStore.userDefaults.string(forKey: "bar") == "Hello world!")
    }

    @Test
    func it_stores_raw_representable_values() async throws {
        func makeStorage<Value: RawRepresentable & CaseIterable>(
            default defaultValue: Value
        ) -> UserDefaultsStorage<Value> where Value.RawValue: Equatable {
            UserDefaultsStorage(default: defaultValue, key: nil)
        }
        let spiceStore = MockSpiceStore()
        spiceStore.userDefaults.removeAll()
        let sut = makeStorage(default: MockEnvironment.production)
        sut.prepare(propertyName: "foo", ownedBy: spiceStore)
        sut.value = MockEnvironment.staging
        #expect(spiceStore.userDefaults.string(forKey: "foo") == "staging")
    }

    @Test
    func it_publishes_initial_value() async throws {
        let spiceStore = MockSpiceStore()
        spiceStore.userDefaults.removeAll()
        spiceStore.userDefaults.set(true, forKey: "foo")
        let sut = UserDefaultsStorage(default: false, key: nil)
        sut.prepare(propertyName: "foo", ownedBy: spiceStore)
        var readValue: Bool?
        _ = sut.publisher.sink { value in
            readValue = value
        }
        #expect(readValue == true)
    }
}
