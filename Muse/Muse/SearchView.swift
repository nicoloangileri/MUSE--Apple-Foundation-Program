//
//  SearchView.swift
//  Muse
//
//  Created by Riccardo on 20/02/26.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @EnvironmentObject var dataManager: DatabaseManager
    
    // Logica per filtrare i libri in base a cosa scriviamo nella barra di ricerca
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return []
        } else {
            return dataManager.books.filter { book in
                book.titolo.localizedCaseInsensitiveContains(searchText) ||
                book.autore.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack { // ZStack esterno per assicurarci che lo sfondo copra tutto
                Color(red: 0.918, green: 0.894, blue: 0.863).ignoresSafeArea()
                
                Group {
                    if searchText.isEmpty {
                        // Mostra la tua ExploreView se non stiamo cercando nulla
                        ExploreView()
                    } else {
                        // Mostra la lista dei risultati se stiamo scrivendo
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredBooks) { book in
                                    NavigationLink(destination: BookDetailView(book: book)) {
                                        SearchResultCard(book: book) // Sottovista
                                    }
                                    .buttonStyle(.plain) // Evita che il testo diventi blu di default
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Explore")
            // Aggiunge la barra di ricerca in alto
            .searchable(text: $searchText, prompt: "Find by titles or authors")
        }
    }
}

// Una Card personalizzata per i risultati di ricerca
struct SearchResultCard: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 15) {
            // Riusiamo la CoverImageView, ma la rendiamo visivamente più compatta
            CoverImageView(imageUrl: book.copertina)
                .frame(width: 50, height: 75)
                .scaleEffect(0.7) // Rimpicciolisce il contenuto senza rompere il frame della View originale
                .frame(width: 50, height: 75) // Forza l'ingombro finale
            
            VStack(alignment: .leading, spacing: 6) {
                Text(book.titolo)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(book.autore)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Freccina per indicare la navigazione
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.brown.opacity(0.5))
        }
        .padding(12)
        .background(Color.white.opacity(0.6)) // Leggermente trasparente
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    SearchView()
        .environmentObject(DatabaseManager())
        .environmentObject(LibraryManager())
}
