//
//  GenreDetailView.swift
//  Muse
//
//  Created by Riccardo on 18/02/26.
//

import SwiftUI

struct GenreDetailView: View {
    // Recuperiamo il manager dall'ambiente per avere accesso al dataset
    @EnvironmentObject var dataManager: DatabaseManager
    let selectedGenre: String
    
    var filteredBooks: [Book] {
            dataManager.books.filter { book in
                // Pulizia di entrambe le stringhe: togliamo spazi e rendiamo minuscolo
                let bookGenre = book.genere.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let targetGenre = selectedGenre.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                
                return bookGenre == targetGenre
            }
        }
    
    var body: some View {
        // Anzichè usare List usiamo ZStack e ScrollView
        ZStack {
            Color(red: 0.918, green: 0.894, blue: 0.863).ignoresSafeArea() // Il colore dello sfondo
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredBooks) { book in
                        // NavigationLink che porta alla vista di dettaglio
                        NavigationLink(destination: BookDetailView(book: book)) {
                            BookRow(book: book)
                        }
                        .buttonStyle(.plain) // Evita il flash blu del pulsante standard
                    }
                }
                .padding()
            }
        }
        .navigationTitle(selectedGenre.capitalized)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct BookRow: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 15) {
            // Riusiamo il componente CoverImageView per uniformità, leggermente scalato
            CoverImageView(imageUrl: book.copertina)
                .frame(width: 60, height: 90) // Proporzioni classiche da libro
                .scaleEffect(0.8)
                .frame(width: 60, height: 90) // Mantiene lo spazio
            
            VStack(alignment: .leading, spacing: 6) {
                Text(book.titolo)
                    .font(.system(.headline, design: .serif)) // Font editoriale per i titoli
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text("Find out the details")
                    .font(.caption)
                    .foregroundColor(.secondary) // Testo un po' più tenue
            }
            
            Spacer()
            
            // Piccola freccia a destra per indicare navigazione
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.brown.opacity(0.5))
        }
        .padding(12)
        .background(Color.white.opacity(0.7)) // Effetto Card
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    NavigationStack {
        GenreDetailView(selectedGenre: "fantasy")
            .environmentObject(DatabaseManager())
    }
}
