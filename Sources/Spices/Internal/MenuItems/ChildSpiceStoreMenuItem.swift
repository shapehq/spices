import Foundation

struct ChildSpiceStoreMenuItem: MenuItem {
    enum PresentationStyle {
        case modal
        case push
        case inline(header: String?, footer: String?)
    }

    let id = UUID().uuidString
    let name: Name
    let presentationStyle: PresentationStyle
    let spiceStore: any SpiceStore
}
