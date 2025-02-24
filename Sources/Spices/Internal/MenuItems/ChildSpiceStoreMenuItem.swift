import Foundation

struct ChildSpiceStoreMenuItem: MenuItem {
    let id = UUID().uuidString
    let name: Name
    let spiceStore: any SpiceStore
}
