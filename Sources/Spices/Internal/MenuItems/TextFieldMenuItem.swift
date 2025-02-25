//
//  TextFieldMenuItem.swift
//  Spices
//
//  Created by Harlan Haskins on 2/25/25.
//


import Combine
import Foundation

final class TextFieldMenuItem: MenuItem, ObservableObject {
    let id = UUID().uuidString
    let name: Name
    let requiresRestart: Bool
    @Published var value: String {
        didSet {
            if value != storage.value {
                storage.value = value
            }
        }
    }

    private let storage: AnyStorage<String>
    private var cancellables: Set<AnyCancellable> = []

    init(name: Name, requiresRestart: Bool, storage: AnyStorage<String>) {
        self.name = name
        self.requiresRestart = requiresRestart
        self.storage = storage
        self.value = storage.value
        storage.publisher.sink { [weak self] newValue in
            if newValue != self?.value {
                self?.value = newValue
            }
        }
        .store(in: &cancellables)
    }
}
