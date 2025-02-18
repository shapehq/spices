@MainActor
protocol Preparable {
    func prepare(propertyName: String, ownedBy spiceStore: some SpiceStore)
}
