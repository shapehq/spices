//
//  ToggleMenuItemView 2.swift
//  Spices
//
//  Created by Harlan Haskins on 2/25/25.
//


import SwiftUI

struct TextFieldMenuItemView: View {
    @ObservedObject var menuItem: TextFieldMenuItem

    @State private var editingValue: String = ""
    @State private var restartApp = false

    var body: some View {
        GeometryReader { proxy in
            HStack {
                Text(menuItem.name.rawValue)
                Spacer()
                TextField("Value", text: $editingValue)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .frame(minWidth: proxy.size.width / 2)
            }
            .frame(height: proxy.size.height, alignment: .center)
        }
        .onSubmit {
            menuItem.value = editingValue
            restartApp = menuItem.requiresRestart
        }
        .restartApp($restartApp)
        .onAppear {
            editingValue = menuItem.value
        }
    }
}
