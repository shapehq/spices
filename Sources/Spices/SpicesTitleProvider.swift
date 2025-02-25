/// A protocol for providing custom titles for enum values used with a ``Spice`` property wrapper.
///
/// By default, Spices generates titles from the enum's cases. Conforming to `SpicesTitleProvider` allows you to override these default titles
/// to provide more descriptive, user-friendly, or localized names in the debug menu.
///
/// ## Example usage
///
/// ```swift
/// class AppSpiceStore: SpiceStore {
///     @Spice var environment: ServiceEnvironment =.production
/// }
/// 
/// enum ServiceEnvironment: String, CaseIterable, SpicesTitleProvider {
///     case production
///     case staging
///
///     var spicesTitle: String {
///         switch self {
///         case .production:
///             "🚀 Production"
///         case .staging:
///             "🧪 Staging"
///         }
///     }
/// }
/// ```
public protocol SpicesTitleProvider {
    /// The title to be displayed in the in-app debug menu.
    var spicesTitle: String { get }
}
