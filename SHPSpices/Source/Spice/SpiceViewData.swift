import Foundation

enum SpiceViewData {
    case enumeration(
        currentValue: Any,
        currentTitle: String,
        values: [Any],
        titles: [String],
        validTitles: [String],
        setValue: (Any) -> Void,
        hasButtonBehaviour: Bool,
        didSelect: ((Any, @escaping (Swift.Error?) -> Void) -> Void)?
    )

    case bool(
        currentValue: Bool,
        setValue: (Bool) -> Void
    )

    case button(
        didSelect: ((@escaping (Swift.Error?) -> Void) -> Void)?
    )
}
