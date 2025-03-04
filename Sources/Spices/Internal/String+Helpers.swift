import Foundation

extension String {
    func removing(prefix: String) -> Self {
        guard hasPrefix(prefix) else {
            return self
        }
        return String(dropFirst(prefix.count))
    }

    /// Split into camel case words, preserving initialisms like URL and HTTP.
    func camelCaseToNaturalText() -> String {
        var pieces = [String]()
        var currentPiece = ""

        for (idx, character) in enumerated() {
            if idx == 0 {
                currentPiece += character.uppercased()
            } else if character.isUppercase {
                // Small check: recognize runs of multiple uppercase letters and
                // consider them part of the same word.
                if let previousChar = currentPiece.last, previousChar.isUppercase {
                    currentPiece.append(character)
                } else {
                    pieces.append(currentPiece)
                    currentPiece = character.uppercased()
                }
            } else {
                currentPiece.append(character)
            }
        }

        // Commit the last bit of the phrase
        if !currentPiece.isEmpty {
            pieces.append(currentPiece)
        }

        return pieces.joined(separator: " ")
    }
}
