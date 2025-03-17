import Combine
import Foundation
import Testing
@testable import Spices

@MainActor @Suite(.serialized)
final class UserDefaultsStorageTests {
    private var cancellables: Set<AnyCancellable> = []

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

    @Test
    func it_publishes_valuyes() async throws {
        let spiceStore = MockSpiceStore()
        spiceStore.userDefaults.removeAll()
        let sut = UserDefaultsStorage(default: "foo", key: nil)
        sut.prepare(propertyName: "foo", ownedBy: spiceStore)
        let _: Void = try await withCheckedThrowingContinuation { @MainActor continuation in
            let timeoutTask = Task {
                // Wait for a second and if that time passes, assume we will not get notified,
                // in which case the test succeeded.
                try await Task.sleep(nanoseconds: 1_000_000_000)
                continuation.resume()
            }
            sut.publisher.sink { value in
                if value == "bar" {
                    // We received the new value, so all is good.
                    timeoutTask.cancel()
                    continuation.resume()
                }
            }
            .store(in: &cancellables)
            // Setting the same value. This should not result in a value being published.
            sut.value = "bar"
        }
    }

    @Test
    func it_skips_publishing_same_value() async throws {
        let spiceStore = MockSpiceStore()
        spiceStore.userDefaults.removeAll()
        let sut = UserDefaultsStorage(default: "foo", key: nil)
        sut.prepare(propertyName: "foo", ownedBy: spiceStore)
        let _: Void = try await withCheckedThrowingContinuation { @MainActor continuation in
            let timeoutTask = Task {
                // Wait for a second and if that time passes, assume we will not get notified,
                // in which case the test succeeded.
                try await Task.sleep(nanoseconds: 1_000_000_000)
                continuation.resume()
            }
            var count = 0
            sut.publisher.sink { value in
                count += 1
                if count == 1 {
                    // This is the initial value received upon subscribing.
                } else if count == 2 {
                    // This is the second value. We did not expect this, so throw an error.
                    timeoutTask.cancel()
                    let error = NSError(domain: "dk.shape.Spices", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Received unexpected value: \(value)"
                    ])
                    continuation.resume(throwing: error)
                }
            }
            .store(in: &cancellables)
            // Setting the same value. This should not result in a value being published.
            sut.value = "foo"
        }
    }

    @Test
    func it_publishes_when_user_defaults_change() async throws {
        let spiceStore = MockSpiceStore()
        spiceStore.userDefaults.removeAll()
        let sut = UserDefaultsStorage(default: "foo", key: nil)
        sut.prepare(propertyName: "foo", ownedBy: spiceStore)
        let _: Void = try await withCheckedThrowingContinuation { @MainActor continuation in
            let timeoutTask = Task {
                // Wait for a second and if that time passes, assume we will not get notified,
                // in which case we throw an error as the test has failed.
                try await Task.sleep(nanoseconds: 1_000_000_000)
                let error = NSError(domain: "dk.shape.Spices", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Operation timed out"
                ])
                continuation.resume(throwing: error)
            }
            sut.publisher.sink { value in
                if value == "bar" {
                    // We received the new value, so all is good.
                    timeoutTask.cancel()
                    continuation.resume()
                }
            }
            .store(in: &cancellables)
            // Updating UserDefaults should cause a value to be published.
            spiceStore.userDefaults.set("bar", forKey: "foo")
        }
    }

    @Test
    func it_skips_publishing_when_user_defaults_is_updated_with_same_value() async throws {
        let spiceStore = MockSpiceStore()
        spiceStore.userDefaults.removeAll()
        let sut = UserDefaultsStorage(default: "foo", key: nil)
        sut.prepare(propertyName: "foo", ownedBy: spiceStore)
        let _: Void = try await withCheckedThrowingContinuation { @MainActor continuation in
            let timeoutTask = Task {
                // Wait for a second and if that time passes, assume we will not get notified,
                // in which case the test succeeded.
                try await Task.sleep(nanoseconds: 1_000_000_000)
                continuation.resume()
            }
            var count = 0
            sut.publisher.sink { value in
                count += 1
                if count == 1 {
                    // This is the initial value received upon subscribing.
                } else if count == 2 {
                    // This is the second value. We did not expect this, so throw an error.
                    timeoutTask.cancel()
                    let error = NSError(domain: "dk.shape.Spices", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Received unexpected value: \(value)"
                    ])
                    continuation.resume(throwing: error)
                }
            }
            .store(in: &cancellables)
            // Assign the same value as we currentl have in user defaults.
            spiceStore.userDefaults.set("foo", forKey: "foo")
        }
    }
}
