import Combine
import Foundation
import ObjectiveC

@MainActor private var idKey: UInt8 = 0
@MainActor private var nameKey: UInt8 = 0
@MainActor private var isPreparedKey: UInt8 = 0
@MainActor private var parentKey: UInt8 = 0

@MainActor
public protocol SpiceStore: AnyObject, ObservableObject {
    var userDefaults: UserDefaults { get }
}

public extension SpiceStore {
    var userDefaults: UserDefaults {
        .standard
    }
}

extension SpiceStore {
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

    private var parent: (any SpiceStore)? {
        get {
            objc_getAssociatedObject(self, &parentKey) as? any SpiceStore
        }
        set {
            objc_setAssociatedObject(self, &parentKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    private var path: [String] {
        if let parent {
            return parent.path + [name]
        } else {
            return []
        }
    }

    func key(fromPropertyNamed propertyName: String) -> String {
        (path + [propertyName]).joined(separator: ".")
    }

    func publishObjectWillChange() {
        let publisher = objectWillChange as? ObservableObjectPublisher
        publisher?.send()
        parent?.publishObjectWillChange()
    }

    func prepareIfNeeded() {
        guard !isPrepared else {
            return
        }
        isPrepared = true
        prepare()
    }

    private func prepare() {
        let mirror = Mirror(reflecting: self)
        for (name, value) in mirror.children {
            guard let name else {
                continue
            }
            if let spice = value as? Preparable {
                let propertyName = name.removing(prefix: "_")
                spice.prepare(propertyName: propertyName, ownedBy: self)
            } else if let spiceStore = value as? (any SpiceStore) {
                if spiceStore.parent != nil {
                    fatalError("A child spice store can only be referenced from one parent.")
                }
                spiceStore.parent = self
                spiceStore.name = name.camelCaseToNaturalText()
                spiceStore.prepareIfNeeded()
            }
        }
    }
}
