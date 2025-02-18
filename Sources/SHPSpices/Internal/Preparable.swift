@MainActor
protocol Preparable {
    func prepare(variableName variableName: String, ownedBy spiceStore: some SpiceStore)
}
