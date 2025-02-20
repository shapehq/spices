#if canImport(UIKit)
import SwiftUI
import UIKit

public final class SpiceEditorViewController: UIHostingController<SpiceEditor> {
    public init(editing spiceStore: any SpiceStore) {
        super.init(rootView: SpiceEditor(editing: spiceStore))
        sheetPresentationController?.detents = [.medium(), .large()]
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
