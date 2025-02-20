/// A protocol for providing custom titles for enum values used with a ``Spice`` property wrapper.
///
/// By default, Spices generates titles from the enum's cases. Conforming to `SpiceTitleProvider` allows you to override these default titles
/// to provide more descriptive, user-friendly, or localized names in the debug menu.
///
/// ## Example usage
///
/// ```swift
/// class AppSpiceStore: SpiceStore {
///     @Spice var environment: ServiceEnvironment =.production
/// }
/// 
/// enum ServiceEnvironment: String, CaseIterable, SpiceTitleProvider {
///     case production
///     case staging
///
///     var spiceTitle: String {
///         switch self {
///         case.production:
///             "🚀 Production"
///         case.staging:
///             "🧪 Staging"
///         }
///     }
/// }
/// ```
public protocol SpiceTitleProvider {
    /// The title to be displayed in the in-app debug menu.
    var spiceTitle: String { get }
}
