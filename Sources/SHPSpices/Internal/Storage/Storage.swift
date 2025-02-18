import Combine

@MainActor
protocol Storage: AnyObject {
    associatedtype Value
    var value: Value { get set }
    var publisher: AnyPublisher<Value, Never> { get }
}
