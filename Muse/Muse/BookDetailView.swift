//
//  BookDetailView.swift
//  Muse
//
//  Created by Riccardo on 19/02/26.
//

import SwiftUI
import UIKit // Aggiunto per il feedback tattile

struct BookDetailView: View {
    
    @EnvironmentObject var library: LibraryManager
    
    let book: Book
    
    // Accesso al DataManager per prendere le informazioni che servono (es. preferiti)
    @EnvironmentObject var dataManager: DatabaseManager

    var body: some View {
        ZStack {
            // Sfondo sfocato basato sulla copertina
            AsyncImage(url: URL(string: book.copertina)) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Color(red: 0.918, green: 0.894, blue: 0.863)
                }
            }
            .ignoresSafeArea()
            .blur(radius: 60) // Sfocatura estrema
            .opacity(0.4) // Leggera trasparenza per non disturbare il testo
            
            // Sfondo crema originale per mantenere la leggibilità
            Color(red: 0.918, green: 0.894, blue: 0.863).opacity(0.85).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 20) {
                        CoverImageView(imageUrl: book.copertina)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(book.titolo)
                                .font(.system(.title, design: .serif)).bold() // Font Serif
                            
                            Text(book.autore)
                                .font(.subheadline)
                            
                            Text(book.genere.capitalized)
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.brown.opacity(0.1))
                                .cornerRadius(8)
                            
                            Text(book.descrizione)
                                .font(.system(.body, design: .serif)) // Font Serif
                                .lineLimit(4)
                            
                            NavigationLink(destination: FullDescriptionView(text: book.descrizione, title: book.titolo, cover: book.copertina, author: book.autore)) {
                                        Text("Show more")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .padding(.leading, 140)
                                            .lineLimit(1)
                                }
                            
                        }
                    }
                    .padding()

                    Divider().padding(.horizontal)  // Crea la linea che divide i dettagli del libro dalle recommendend songs
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recommended Songs")
                            .font(.title3).bold()
                            .padding(.horizontal)
                            .padding(.top, 10)

                        // Lista delle canzoni
                        VStack(spacing: 12) {
                            ForEach(book.songs) { song in
                                SongCard(song: song)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .toolbar {
                    // Posiziona l'elemento in alto a destra
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            triggerHapticFeedback(style: .rigid) // Aggiunta vibrazione
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { // Animazione più bella
                                if library.myBooks.contains(where: { $0.id == book.id }) {
                                    library.removeFromLibrary(book: book)
                                } else {
                                    library.addToLibrary(book: book)
                                }
                            }
                        }) {
                            let isSaved = library.myBooks.contains(where: { $0.id == book.id })
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .foregroundColor(isSaved ? .brown : .primary) // Cambia colore se salvato
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                }
    }
}

struct SongCard: View {
    let song: Song
    
    var body: some View {
        HStack(spacing: 15) {
            // Icona o Placeholder per il disco
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.brown.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "music.note")
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(song.titolo)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(song.artista)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Tasto Play/Link
            if let url = URL(string: song.link) {
                Link(destination: url) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 34)) // Leggermente più grande
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .brown) // Effetto bicolore
                }
            }
        }
        .padding()
        // SOSTITUITO IL BACKGROUND CON L'ULTRA THIN MATERIAL
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
}

// Funzione globale per la vibrazione haptic
func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    let impactMed = UIImpactFeedbackGenerator(style: style)
    impactMed.impactOccurred()
}

// Libro "finto" per mostrare l'anteprima.
#Preview {
    NavigationStack {
        BookDetailView(book: Book(
            id: UUID(),
            isbn: "978-3-16-148410-0",
            titolo: "Esempio Libro",
            autore: "Autore Test",
            copertina: "https://via.placeholder.com/150",
            genere: "Fantasy",
            descrizione: "Descrizione del libro",
            songs: [Song(id: UUID(), titolo: "Canzone Test", artista: "Artista Test", link: "")]
        ))
        .environmentObject(DatabaseManager())
        .environmentObject(LibraryManager())
    }
}
