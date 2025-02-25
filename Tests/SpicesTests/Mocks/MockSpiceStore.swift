import Spices

final class MockSpiceStore: SpiceStore {
    nonisolated(unsafe) static var buttonClosureCalled = false
    nonisolated(unsafe) static var asynButtonClosureCalled = false

    @Spice var boolValue = false
    @Spice var textValue = "Hello"
    @Spice var enumValue: MockEnvironment = .production
    @Spice var buttonValue = {
        MockSpiceStore.buttonClosureCalled = true
    }
    @Spice var asyncButtonValue: () async throws -> Void = {
        MockSpiceStore.asynButtonClosureCalled = true
    }

    @Spice(name: "Hello World!") var namedValue = false
}
