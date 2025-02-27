public protocol PresentationStyle {}

public struct ModalPresentationStyle: PresentationStyle {
    fileprivate init() {}
}

public struct PushPresentationStyle: PresentationStyle {
    fileprivate init() {}
}

public struct InlinePresentationStyle: PresentationStyle {
    fileprivate init() {}
}

public extension PresentationStyle {
    static var modal: ModalPresentationStyle {
        ModalPresentationStyle()
    }

    static var push: PushPresentationStyle {
        PushPresentationStyle()
    }

    static var inline: InlinePresentationStyle {
        InlinePresentationStyle()
    }
}
