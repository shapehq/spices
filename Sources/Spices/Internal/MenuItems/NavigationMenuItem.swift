import Foundation
import SwiftUI

final class NavigationMenuItem: MenuItem {
    let id = UUID().uuidString
    let name: Name
    let content: AnyView

    init(name: Name, content: AnyView) {
        self.name = name
        self.content = content
    }
}
