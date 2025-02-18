import Combine
import Foundation
import ObjectiveC

@MainActor private var idKey: UInt8 = 0
@MainActor private var nameKey: UInt8 = 0
@MainActor private var isPreparedKey: UInt8 = 0
@MainActor private var parentKey: UInt8 = 0

@MainActor
public protocol VariableStore: AnyObject, ObservableObject {
    var userDefaults: UserDefaults { get }
}

public extension VariableStore {
    var userDefaults: UserDefaults {
        .standard
    }
}

extension VariableStore {
    var keyPrefix: String {
        "__" + String(reflecting: self)
    }

    var id: String {
        if let value = objc_getAssociatedObject(self, &idKey) as? String {
            return value
        } else {
            let value = UUID().uuidString
            objc_setAssociatedObject(self, &idKey, value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            return value
        }
    }

    var name: String {
        get {
            objc_getAssociatedObject(self, &nameKey) as? String ?? "<name unavailable>"
        }
        set {
            objc_setAssociatedObject(self, &nameKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    private var isPrepared: Bool {
        get {
            (objc_getAssociatedObject(self, &isPreparedKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &isPreparedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    private var parent: (any VariableStore)? {
        get {
            objc_getAssociatedObject(self, &parentKey) as? any VariableStore
        }
        set {
            objc_setAssociatedObject(self, &parentKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    func prepareIfNeeded() {
        guard !isPrepared else {
            return
        }
        isPrepared = true
        prepare()
    }

    func key(fromVariableNamed variableName: String) -> String {
        keyPrefix + "." + variableName
            .camelCaseToNaturalText()
            .replacingOccurrences(of: " ", with: "")
    }

    func publishObjectWillChange() {
        let publisher = objectWillChange as? ObservableObjectPublisher
        publisher?.send()
        parent?.publishObjectWillChange()
    }
}

private extension VariableStore {
    private func prepare() {
        let mirror = Mirror(reflecting: self)
        for (name, value) in mirror.children {
            guard let name else {
                continue
            }
            if let variable = value as? Preparable {
                let variableName = name.removing(prefix: "_")
                variable.prepare(representingVariableNamed: variableName, ownedBy: self)
            } else if let variableStore = value as? (any VariableStore) {
                if variableStore.parent != nil {
                    fatalError("A child variable store can only be referenced from one parent.")
                }
                variableStore.parent = self
                variableStore.name = name.camelCaseToNaturalText()
                variableStore.prepareIfNeeded()
            }
        }
    }
}
