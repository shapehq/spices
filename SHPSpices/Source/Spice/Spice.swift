//
//  Spice.swift
//  Spices
//
//  Created by Simon Støvring on 20/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation

protocol SpiceType {
    weak var application: UIApplication? { get set }
    weak var rootSpiceDispenser: SpiceDispenser? { get set }    
    var key: String { get set }
    var name: String { get }
    var requiresRestart: Bool { get }
    var store: UserDefaults { get set }
    var viewData: SpiceViewData { get }
    func validateCurrentValue()
}

public class Spice<T>: SpiceType {
    weak var application: UIApplication?
    weak var rootSpiceDispenser: SpiceDispenser?
    
    public var value: T {
        return _value ?? defaultValue
    }
    
    internal var key: String = "" {
        didSet {
            if key != oldValue {
                if specifiedName == nil {
                    let components = key.components(separatedBy: ".")
                    let lastComponent = components[components.count - 1]
                    name = lastComponent.shp_camelCaseToReadable()
                }
                _value = valueLoader?()
            }
        }
    }
    internal private(set) var name: String = ""
    internal let requiresRestart: Bool
    internal var store: UserDefaults = .standard {
        didSet {
            _value = valueLoader?()
        }
    }
    internal var viewData: SpiceViewData {
        guard let viewData = viewDataProvider?() else {
            fatalError("viewDataProvider did not return a view data.")
        }
        return viewData
    }
    
    private let defaultValue: T
    private var _value: T?
    private let specifiedName: String?
    private let valueValidator: ((T) -> T)?
    private var viewDataProvider: (() -> SpiceViewData?)?
    private var valueLoader: (() -> T?)? {
        didSet {
            _value = valueLoader?()
        }
    }
    // Used for storing values when validating a current value.
    private var valuePersister: ((T) -> Void)?
    private var haveLoadedValue = false
    // The spice can choose to call this when a value is selected
    // in order to send a callback to the creator of the spice.
    private var didSelect: ((T, @escaping (Swift.Error?) -> Void) -> Void)?
    // Used for enumerations.
    private(set) var hasButtonBehaviour = false
    
    private init(defaultValue: T, name: String?, requiresRestart: Bool, valueValidator: ((T) -> T)? = nil) {
        self.defaultValue = defaultValue
        self.specifiedName = name
        self.requiresRestart = requiresRestart
        self.valueValidator = valueValidator
        if let name = name {
            self.name = name
        }
    }
    
    internal func validateCurrentValue() {
        guard let valueValidator = valueValidator else { return }
        valuePersister?(valueValidator(value))
    }
    
    static private func convert(_ value: Any) -> T {
        guard let convertedValue = value as? T else {
            fatalError("Cannot convert value to expected type '\(T.self)'.")
        }
        return convertedValue
    }
}

extension Spice where T: SpiceEnum, T: RawRepresentable {
    public convenience init(_ defaultValue: T, name: String? = nil, requiresRestart: Bool = false) {
        self.init(
            defaultValue: defaultValue,
            name: name,
            requiresRestart: requiresRestart,
            valueValidator: T.validate)
        valueLoader = { [weak self] in self?.loadStoredValue() }
        valuePersister = { [weak self] in self?.storeValue($0) }
        viewDataProvider = { [weak self] in self?.createViewData() }
    }
    
    public convenience init(name: String? = nil, requiresRestart: Bool = false, didSelect: @escaping (T, @escaping (Swift.Error?) -> Void) -> Void) {
        self.init(
            defaultValue: T.shp_allCases()[0],
            name: name,
            requiresRestart: requiresRestart,
            valueValidator: T.validate)
        valueLoader = { [weak self] in self?.loadStoredValue() }
        valuePersister = { [weak self] in self?.storeValue($0) }
        viewDataProvider = { [weak self] in self?.createViewData() }
        self.didSelect = didSelect
        hasButtonBehaviour = true
    }
    
    public func setValue(_ value: T) {
        storeValue(value)
        rootSpiceDispenser?.validateValues()
    }
    
    private func storeValue(_ value: T) {
        _value = value
        store.setValue(value.rawValue, forKey: key)
        store.synchronize()
    }
    
    private func loadStoredValue() -> T? {
        if let rawValue = store.value(forKey: key) as? T.RawValue {
            return T(rawValue: rawValue)
        } else {
            return nil
        }
    }
    
    private func createViewData() -> SpiceViewData {
        func title(for _case: T) -> String {
            return _case.title ?? String(describing: _case).shp_camelCaseToReadable()
        }
        return .enumeration(
            currentValue: value,
            currentTitle: title(for: value),
            values: T.shp_allCases(),
            titles: T.shp_allCases().map(title),
            validTitles: T.validCases().map(title),
            setValue: { [weak self] newValue in
                self?.storeValue(Spice.convert(newValue))
            },
            hasButtonBehaviour: hasButtonBehaviour,
            didSelect: { [weak self] newValue, completion in
                self?.didSelect?(Spice.convert(newValue), completion)
        })
    }
}

extension Spice where T == Bool {
    public convenience init(_ defaultValue: T, name: String? = nil, requiresRestart: Bool = false, valueValidator: ((T) -> T)? = nil) {
        self.init(
            defaultValue: defaultValue,
            name: name,
            requiresRestart: requiresRestart,
            valueValidator: valueValidator)
        valueLoader = { [weak self] in self?.loadStoredValue() }
        valuePersister = { [weak self] in self?.storeValue($0) }
        viewDataProvider = { [weak self] in self?.createViewData() }
    }
    
    public func setValue(_ value: T) {
        storeValue(value)
        rootSpiceDispenser?.validateValues()
    }
    
    private func storeValue(_ value: T) {
        _value = value
        store.setValue(value, forKey: key)
        store.synchronize()
    }
    
    private func loadStoredValue() -> T? {
        return store.bool(forKey: key)
    }
    
    private func createViewData() -> SpiceViewData {
        return .bool(currentValue: value, setValue: { [weak self] newValue in
            self?.storeValue(newValue)
        })
    }
}

extension Spice where T == ButtonSpice {
    public convenience init(name: String? = nil, requiresRestart: Bool = false, didSelect: @escaping (@escaping (Swift.Error?) -> Void) -> Void) {
        self.init(
            defaultValue: ButtonSpice(),
            name: name,
            requiresRestart: requiresRestart,
            valueValidator: nil)
        self.didSelect = { _, completion in didSelect(completion) }
        viewDataProvider = { [weak self] in self?.createViewData() }
        hasButtonBehaviour = true
    }
    
    private func createViewData() -> SpiceViewData {
        return .button(didSelect: { [weak self] completion in self?.didSelect?(ButtonSpice(), completion) })
    }
}
