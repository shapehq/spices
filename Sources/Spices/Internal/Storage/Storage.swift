import Combine

protocol Storage: AnyObject, Preparable {
    associatedtype Value
    var value: Value { get set }
    var publisher: AnyPublisher<Value, Never> { get }
}
