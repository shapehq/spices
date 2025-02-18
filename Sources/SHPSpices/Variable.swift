import Combine
import Foundation

@MainActor
@propertyWrapper public struct Variable<Value> {
    @available(*, unavailable, message: "@Variable can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    public var projectedValue: AnyPublisher<Value, Never> {
        storage.publisher
    }

    let name: Name
    let storage: Storage<Value>
    let editorItem: EditorItem

    private let initialValue: Value

    public init(wrappedValue: Value, name rawName: String? = nil) where Value == Bool {
        self.initialValue = wrappedValue
        self.name = Name(rawName)
        self.storage = Storage(default: wrappedValue)
        self.editorItem = .toggle(.init(name: name, storage: storage))
    }

    public init(wrappedValue: Value, name rawName: String? = nil) where Value: RawRepresentable & CaseIterable {
        self.initialValue = wrappedValue
        self.name = Name(rawName)
        let storage = Storage(default: wrappedValue)
        self.storage = storage
        let options = Value.pickerOptions(persistingTo: storage)
        self.editorItem = .picker(.init(name: name, options: options) {
            String(describing: storage.value.optionId)
        })
    }

    static public subscript<T: VariableStore>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            instance.prepareIfNeeded()
            return instance[keyPath: storageKeyPath].storage.value
        }
        set {
            instance.prepareIfNeeded()
            instance[keyPath: storageKeyPath].storage.value = newValue
        }
    }
}

extension Variable: Preparable {
    func prepare(representingVariableNamed variableName: String, ownedBy variableStore: some VariableStore) {
        name.rawValue = variableName.camelCaseToNaturalText()
        storage.prepare(representingVariableNamed: variableName, ownedBy: variableStore)
    }
}

extension Variable: EditorItemProvider {}

private extension CaseIterable where Self: RawRepresentable {
    @MainActor
    static func pickerOptions(persistingTo storage: Storage<Self>) -> [EditorItem.PickerParameters.Option] {
        allCases.map { value in
            EditorItem.PickerParameters.Option(id: value.optionId, title: value.optionTitle) {
                storage.value = value
            }
        }
    }

    var optionId: String {
        String(describing: self)
    }

    private var optionTitle: String {
        if let titleProvider = self as? VariableTitleProvider {
            titleProvider.title
        } else {
            String(describing: self).camelCaseToNaturalText()
        }
    }
}
