@MainActor
protocol Preparable {
    func prepare(
        representingVariableNamed variableName: String,
        ownedBy variableStore: some VariableStore
    )
}
