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

                // If the previous letter was uppercase, continue the initialism. However,
                // if the next character is lowercase, it's the start of the next camel-case word,
                // so don't include it in the run.
                if previous.isUppercase && next?.isLowercase == true {
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
