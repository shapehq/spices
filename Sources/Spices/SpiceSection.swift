/// A section within a spiced debug menu, used to group related settings.
///
/// `SpiceSection` is used in conjunction with the `@Spice` property wrapper and `SpiceStore`
/// to organize debug settings within an in-app debug menu. It allows for optional headers
/// and footers to provide context and instructions.
///
/// ## Example Usage
///
/// ```swift
/// private extension SpiceSection {
///     static var environment: Self {
///         SpiceSection("env")
///     }
///
///     static var debug: Self {
///         SpiceSection("debug", header: "Debugging")
///     }
///
///     static var featureFlags: Self {
///         SpiceSection("featureFlags")
///     }
/// }
///
/// final class AppSpiceStore: SpiceStore {
///     @Spice(requiresRestart: true, section: .environment)
///     var environment: ServiceEnvironment = .production
///     @Spice(name: "API URL", section: .environment)
///     var apiURL = "http://example.com"
///
///     @Spice(section: .debug)
///     var enableLogging = false
/// }
/// ```
public struct SpiceSection: Hashable {
    /// A unique identifier for the section.
    let id: String
    /// An optional header string for the section.
    let header: String?
    /// An optional footer string for the section.
    let footer: String?

    /// The default `SpiceSection`.
    public static var `default`: Self {
        Self("default")
    }

    /// Creates a new `SpiceSection` with the given identifier and no header or footer.
    ///
    /// - Parameter id: The unique identifier for the section.
    public init(_ id: String) {
        self.id = id
        self.header = nil
        self.footer = nil
    }

    /// Creates a new `SpiceSection` with the given identifier and header, but no footer.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the section.
    ///   - header: The header string for the section.
    public init(_ id: String, header: String) {
        self.id = id
        self.header = header
        self.footer = nil
    }

    /// Creates a new `SpiceSection` with the given identifier and footer, but no header.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the section.
    ///   - footer: The footer string for the section.
    public init(_ id: String, footer: String) {
        self.id = id
        self.header = nil
        self.footer = footer
    }

    /// Creates a new `SpiceSection` with the given identifier, header, and footer.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the section.
    ///   - header: The header string for the section.
    ///   - footer: The footer string for the section.
    public init(_ id: String, header: String, footer: String) {
        self.id = id
        self.header = header
        self.footer = footer
    }
}
