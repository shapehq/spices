import Combine
import Foundation
@testable import Spices
import Testing

@Suite
final class AnyStorageTests {
    private var cancellables: Set<AnyCancellable> = []

    @Test
    func it_reads_value() async throws {
        let storage = MockStorage(default: "Hello world!")
        let sut = AnyStorage(storage)
        #expect(sut.value == "Hello world!")
    }

    @Test
    func it_writes_value() async throws {
        let storage = MockStorage(default: "Hello world!")
        let sut = AnyStorage(storage)
        sut.value = "Foo"
        #expect(storage.value == "Foo")
    }

    @Test
    func it_notifies_observer_of_changes() async throws {
        let storage = MockStorage(default: "Hello world!")
        let sut = AnyStorage(storage)
        var didReceiveChange = false
        sut.objectWillChange.sink {
            didReceiveChange = true
        }
        .store(in: &cancellables)
        sut.value = "Foo"
        #expect(didReceiveChange == true)
    }

    @Test
    func it_updates_prepared_state() async throws {
        let storage = MockStorage(default: "Hello world!")
        let sut = AnyStorage(storage)
        #expect(sut.isPrepared == false)
        sut.prepare(propertyName: "foo", ownedBy: MockSpiceStore())
        #expect(sut.isPrepared == true)
    }
}
