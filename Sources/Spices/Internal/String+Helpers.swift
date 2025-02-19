import Foundation

extension String {
    func removing(prefix: String) -> Self {
        guard hasPrefix(prefix) else {
            return self
        }
        return String(dropFirst(prefix.count))
    }

    func camelCaseToNaturalText() -> String {
        var result = ""
        for (idx, scalar) in unicodeScalars.enumerated() {
            if idx == 0 {
                result += String(scalar).uppercased()
            } else if CharacterSet.uppercaseLetters.contains(scalar) {
                result += " \(String(scalar).uppercased())"
            } else {
                result += String(scalar)
            }
        }
        return result
    }
}
