@MainActor
protocol Preparable {
    func prepare(
        representingSpiceNamed spiceName: String,
        ownedBy spiceStore: some SpiceStore
    )
}
