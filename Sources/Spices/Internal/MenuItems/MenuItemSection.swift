struct MenuItemSection: Identifiable {
    let id: String
    let header: String?
    let footer: String?
    let menuItems: [MenuItem]

    init(section: SpiceSection, menuItems: [MenuItem]) {
        self.init(
            id: section.id,
            header: section.header,
            footer: section.footer,
            menuItems: menuItems
        )
    }

    private init(id: String, header: String?, footer: String?, menuItems: [MenuItem]) {
        self.id = id
        self.header = header
        self.footer = footer
        self.menuItems = menuItems
    }

    func appending(_ menuItem: MenuItem) -> Self {
        Self(
            id: id,
            header: header,
            footer: footer,
            menuItems: menuItems + [menuItem]
        )
    }
}
