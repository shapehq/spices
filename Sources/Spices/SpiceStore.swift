import Combine
import Foundation
import ObjectiveC

nonisolated(unsafe) private var idKey: UInt8 = 0
nonisolated(unsafe) private var nameKey: UInt8 = 0
nonisolated(unsafe) private var propertyNameKey: UInt8 = 0
nonisolated(unsafe) private var isPreparedKey: UInt8 = 0
nonisolated(unsafe) private var parentKey: UInt8 = 0

/// A protocol for classes that manage a collection of settings exposed in an in-app debug menu.
///
/// `SpiceStore` objects own and manage ``Spice`` property wrappers, providing a central point for accessing and observing settings.
///
/// ## Example Usage
///
/// ```swift
/// class AppSpiceStore: SpiceStore {
///     @Spice(requiresRestart: true) var environment: ServiceEnvironment = .production
///     @Spice var enableLogging = false
///     @Spice var clearCache = {
///         try await Task.sleep(for: .seconds(1))
///         URLCache.shared.removeAllCachedResponses()
///     }
///
///     let featureFlags = FeatureFlagsSpiceStore()
/// }
/// ```
public protocol SpiceStore: AnyObject, ObservableObject {
    /// The `UserDefaults` instance used for persisting settings.
    ///
    /// You can use this property to share settings among apps, or when developing an app extension, to share preferences or other data between the extension and its containing app.
    ///
    /// The default implementation returns `UserDefaults.standard`.
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

    var propertyName: String {
        get {
            objc_getAssociatedObject(self, &propertyNameKey) as? String ?? "<name unavailable>"
        }
        set {
            objc_setAssociatedObject(self, &propertyNameKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
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
            return parent.path + [propertyName]
        } else {
            return []
        }
    }

    var menuItems: [MenuItem] {
        prepareIfNeeded()
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap { _, value in
            if let spice = value as? MenuItemProvider {
                return spice.menuItem
            } else if let spiceStore = value as? any SpiceStore {
                return ChildSpiceStoreMenuItem(spiceStore: spiceStore)
            } else {
                return nil
            }
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
                spiceStore.propertyName = name
                spiceStore.name = name.camelCaseToNaturalText()
                spiceStore.prepareIfNeeded()
            }
        }
    }
}
