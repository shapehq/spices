import Foundation

struct ChildSpiceStoreMenuItem: MenuItem {
    let id = UUID().uuidString
    let spiceStore: any SpiceStore
}
