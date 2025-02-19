@MainActor
final class Name {
    var rawValue: String {
        get {
            explicitValue ?? _value ?? "<name unavailable>"
        }
        set {
            _value = newValue
        }
    }

    private let explicitValue: String?
    private var _value: String?

    init(_ value: String? = nil) {
        explicitValue = value
    }
}
