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
    
    /// Call when the store appear on the screen
    func onAppear()
}

public extension SpiceStore {
    var userDefaults: UserDefaults {
        .standard
    }
    
    func onAppear() {
    }
}

public extension SpiceStore {
    /// Ensures that the `SpiceStore` is prepared before accessing its projected values.
    ///
    /// This method checks whether the `SpiceStore` has already been prepared. If not, it marks it as prepared
    /// and invokes the `prepare()` method.
    ///
    /// You typically do not need to call this method manually, as preparation happens automatically. However,
    /// if ``Spice/projectedValue`` is accessed before the corresponding property has been read or written,
    /// you must explicitly call `prepareIfNeeded()` to avoid accessing an unprepared state.
    ///
    /// - Important: If the `SpiceStore` is not prepared, accessing a projected value will trigger an assertion failure.
    ///
    func prepareIfNeeded() {
        guard !isPrepared else {
            return
        }
        isPrepared = true
        prepare()
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

    var propertyName: String {
        get {
            objc_getAssociatedObject(self, &propertyNameKey) as? String ?? "<name unavailable>"
        }
        set {
            objc_setAssociatedObject(self, &propertyNameKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    var parent: (any SpiceStore)? {
        get {
            objc_getAssociatedObject(self, &parentKey) as? any SpiceStore
        }
        set {
            objc_setAssociatedObject(self, &parentKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
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
            guard let spice = value as? MenuItemProvider else {
                return nil
            }
            return spice.menuItem
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

    private func prepare() {
        let mirror = Mirror(reflecting: self)
        for (name, value) in mirror.children {
            guard let name, let spice = value as? Preparable else {
                continue
            }
            let propertyName = name.removing(prefix: "_")
            spice.prepare(propertyName: propertyName, ownedBy: self)
        }
    }
}
