import Foundation

struct AsyncButtonMenuItem: MenuItem {
    let id = UUID().uuidString
    let name: Name
    let requiresRestart: Bool
    let storage: AnyStorage<Spice.AsyncButtonHandler>
}
