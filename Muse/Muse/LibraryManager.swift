import Foundation
import SwiftUI
import Combine

// Gestione della libreria (salvataggio, aggiungere o rimuovere dalla libreria)

class LibraryManager: ObservableObject {
    @Published var myBooks: [Book] = [] {
        didSet { save() }
    }
    
    private let saveKey = "SavedLibraryBooks"

    init() { load() }

    func addToLibrary(book: Book) {
        if !myBooks.contains(where: { $0.id == book.id }) {
            myBooks.append(book)
        }
    }

    func removeFromLibrary(book: Book) {
        myBooks.removeAll(where: { $0.id == book.id })
    }

    private func save() {
        if let data = try? JSONEncoder().encode(myBooks) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
            myBooks = decoded
        }
    }
}
