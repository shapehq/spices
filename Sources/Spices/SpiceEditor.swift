import SwiftUI

/// A SwiftUI view that presents an in-app debug menu for editing settings managed by a ``SpiceStore``.
///
/// `SpiceEditor` displays a list of menu items corresponding to the ``Spice`` properties defined in a ``SpiceStore``.
///
/// ## Example Usage
///
/// ```swift
/// struct ContentView: View {
///     @EnvironmentObject private var spiceStore: AppSpiceStore
///     @State private var isSpiceEditorPresented = false
///
///     var body: some View {
///         VStack {
///             Button("Open Debug Menu") {
///                 isSpiceEditorPresented = true
///             }
///         }
///         .sheet(isPresented: $isSpiceEditorPresented) {
///             SpiceEditor(editing: spiceStore)
///         }
///     }
/// }
/// ```
///
/// The `SpiceEditor` can also be presented when the device is shaken using the `presentSpiceEditorOnShake(_:)` view modifier.
///
/// ```swift
/// struct ContentView: View {
///     @EnvironmentObject private var spiceStore: AppSpiceStore
///
///     var body: some View {
///         NavigationStack {
///             // ...
///         }
///         #if DEBUG
///         .presentSpiceEditorOnShake(editing: spiceStore)
///         #endif
///     }
/// }
/// ```
public struct SpiceEditor: View {
    private let title: String
    private let spiceStore: any SpiceStore
    @Environment(\.dismiss) private var dismiss

    /// Initializes a `SpiceEditor` with a ``SpiceStore``.
    ///
    /// - Parameter spiceStore: The ``SpiceStore`` containing the settings to be edited.
    public init(editing spiceStore: any SpiceStore) {
        self.spiceStore = spiceStore
        self.title = "Debug Menu"
    }

    /// Initializes a `SpiceEditor` with a ``SpiceStore``.
    ///
    /// - Parameter spiceStore: The ``SpiceStore`` containing the settings to be edited.
    /// - Parameter title: The title displayed in the navigation bar.
    public init(editing spiceStore: any SpiceStore, title: String) {
        self.spiceStore = spiceStore
        self.title = title
    }

    /// The content of the view.
    public var body: some View {
        NavigationView {
            MenuItemListView(items: spiceStore.menuItems, title: title) {
                dismiss()
            }
        }
        .configureSheetPresentation()
        .environmentObject(UserInteraction())
    }
}
