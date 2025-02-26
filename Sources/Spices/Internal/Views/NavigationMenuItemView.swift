import SwiftUI

struct NavigationMenuItemView: View {
    let menuItem: NavigationMenuItem

    var body: some View {
        NavigationLink(menuItem.name.rawValue) {
            menuItem.content
        }
    }
}
