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

        for (idx, character) in zip(indices, self) {
            if idx == startIndex {
                currentPiece += character.uppercased()
            } else if character.isUppercase {
                // Small check: recognize runs of multiple uppercase letters and
                // consider them part of the same word until the start of the next word.
                let previousIndex = index(before: idx)
                let nextIndex = index(after: idx)
                let previous = self[previousIndex]
                let next = nextIndex < endIndex ? self[nextIndex] : nil
                if previous.isUppercase && next?.isLowercase == true {
                    // Previous word was an initialism, and this uppercase letter starts a new word
                    // containing the next character.
                    pieces.append(currentPiece)
                    currentPiece = String(character)
                } else if previous.isUppercase {
                    // Continue the initialism.
                    currentPiece.append(character)
                } else {
                    // Previous word was not an initialism, start a new word.
                    pieces.append(currentPiece)
                    currentPiece = character.uppercased()
                }
            } else {
                currentPiece.append(character)
            }
        }

        // Commit the last bit of the phrase.
        if !currentPiece.isEmpty {
            pieces.append(currentPiece)
        }

        return pieces.joined(separator: " ")
    }
}
