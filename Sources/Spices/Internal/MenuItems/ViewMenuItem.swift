import Foundation
import SwiftUI

final class ViewMenuItem: MenuItem {
    enum PresentationStyle {
        case modal
        case push
        case inline
    }

    let id = UUID().uuidString
    let name: Name
    let presentationStyle: PresentationStyle
    let content: AnyView

    init(name: Name, presentationStyle: PresentationStyle, content: AnyView) {
        self.name = name
        self.presentationStyle = presentationStyle
        self.content = content
    }
}
