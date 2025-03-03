// A type that represents different styles for presenting a view within Spices settings.
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
    /// ## Example Usage
    ///
    /// Use the presentation style to present a nested spice store modally.
    ///
    /// ```swift
    /// @Spice(presentation: .modal) var featureFlags = FeatureFlagsSpiceStore()
    /// ```
    static var modal: ModalPresentationStyle {
        ModalPresentationStyle()
    }

    /// The push presentation style, which pushes the view onto the navigation stack.
    ///
    /// ## Example Usage
    ///
    /// Use the presentation style to push a nested spice store onto the navigation stack.
    ///
    /// ```swift
    /// @Spice(presentation: .push) var featureFlags = FeatureFlagsSpiceStore()
    /// ```
    static var push: PushPresentationStyle {
        PushPresentationStyle()
    }

    /// The inline presentation style, which inlines the view within the settings list.
    ///
    /// ## Example Usage
    ///
    /// Use the presentation style to inline a nested spice store within the current list.
    ///
    /// ```swift
    /// @Spice(presentation: .inline) var featureFlags = FeatureFlagsSpiceStore()
    /// ```
    static var inline: InlinePresentationStyle {
        InlinePresentationStyle()
    }
}
