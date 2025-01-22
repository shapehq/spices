import UIKit

enum SpiceDispenserProperty {
    case spiceDispenser(String, SpiceDispenser)
    case spice(String, SpiceType)
}

public protocol SpiceDispenser: AnyObject {
    @MainActor var store: UserDefaults { get }
    var title: String? { get }
}

public extension SpiceDispenser {
    var title: String? {
        return nil
    }
}

public extension SpiceDispenser {
    var store: UserDefaults {
        return .standard
    }

    @MainActor
    func prepare(with application: UIApplication? = nil) {
        recursivePrepare(with: application, rootSpiceDispenser: self, path: [])
        validateValues()
    }

    @MainActor
    internal func recursivePrepare(
        with application: UIApplication?,
        rootSpiceDispenser: SpiceDispenser,
        path: [String]
    ) {
        properties().forEach { property in
            switch property {
            case .spiceDispenser(let name, let spiceDispenser):
                spiceDispenser.recursivePrepare(
                    with: application,
                    rootSpiceDispenser: rootSpiceDispenser,
                    path: path + [name]
                )
            case .spice(let name, var spice):
                spice.application = application
                spice.rootSpiceDispenser = rootSpiceDispenser
                spice.key = key(from: path + [name])
                spice.store = store
            }
        }
    }

    internal func validateValues() {
        properties().forEach { property in
            switch property {
            case .spiceDispenser(_, let spiceDispenser):
                return spiceDispenser.validateValues()
            case .spice(_, let spice):
                spice.validateCurrentValue()
            }
        }
    }

    internal func properties() -> [SpiceDispenserProperty] {
        let spicyMirror = Mirror(reflecting: self)
        return spicyMirror.children.compactMap { name, value in
            guard let name = name else { return nil }
            if let spiceDispenser = value as? SpiceDispenser {
                return .spiceDispenser(spiceDispenser.title ?? name.shp_camelCaseToReadable(), spiceDispenser)
            } else if let spice = value as? SpiceType {
                return .spice(name, spice)
            } else {
                return nil
            }
        }
    }

    private func key(from path: [String]) -> String {
        path.joined(separator: ".")
    }
}
