protocol Preparable {
    func prepare(propertyName: String, ownedBy spiceStore: any SpiceStore)
}
