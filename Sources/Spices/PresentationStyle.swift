/// A type that represents different styles for presenting a view within Spices settings.
public protocol PresentationStyle {}

/// A presentation style that displays the view modally on top of the Spices settings.
public struct ModalPresentationStyle: PresentationStyle {
    fileprivate init() {}
}

/// A presentation style that pushes the view onto the navigation stack.
public struct PushPresentationStyle: PresentationStyle {
    fileprivate init() {}
}

/// A presentation style that inlines the view within the settings list.
public struct InlinePresentationStyle: PresentationStyle {
    fileprivate init() {}
}

public extension PresentationStyle {
    /// The modal presentation style, which presents the view modally.
    ///
    /// ```swift
    /// @Spice(presentation: .modal) var helloWorld = VStack {
    ///     Image(systemName: "globe")
    ///         .imageScale(.large)
    ///         .foregroundStyle(.tint)
    ///     Text("Hello, world!")
    /// }
    /// .padding()
    /// ```
    static var modal: ModalPresentationStyle {
        ModalPresentationStyle()
    }

    /// The push presentation style, which pushes the view onto the navigation stack.
    ///
    /// ```swift
    /// @Spice(presentation: .push) var helloWorld = VStack {
    ///     Image(systemName: "globe")
    ///         .imageScale(.large)
    ///         .foregroundStyle(.tint)
    ///     Text("Hello, world!")
    /// }
    /// .padding()
    /// ```
    static var push: PushPresentationStyle {
        PushPresentationStyle()
    }

    /// The inline presentation style, which inlines the view within the settings list.
    ///
    /// ```swift
    /// @Spice var version = LabeledContent("Version", value: "1.0 (1)")
    /// ```
    static var inline: InlinePresentationStyle {
        InlinePresentationStyle()
    }
}
