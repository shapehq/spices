import Foundation

extension String {
    func shp_camelCaseToReadable() -> String {
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
