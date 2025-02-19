import Foundation

extension UserDefaults {
    func removeAll() {
        let domain = Bundle.main.bundleIdentifier!
        removePersistentDomain(forName: domain)
    }
}
