//
//  MainView.swift
//  Muse
//
//  Created by Riccardo on 18/02/26.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var library: LibraryManager
    @EnvironmentObject var database: DatabaseManager
    @AppStorage("username") var username: String = ""
    
    // Salviamo 3 ID per i tre box
    @AppStorage("lastRecommendationDate") var lastDate: String = ""
    @AppStorage("recID1") var recID1: String = ""
    @AppStorage("recID2") var recID2: String = ""
    @AppStorage("recID3") var recID3: String = ""
    
    @AppStorage("lastLibraryCount") var lastLibraryCount: Int = 0
    
    // Usiamo una lista di libri opzionali (nil = box non disponibile)
    @State private var dailyBooks: [Book?] = [nil, nil, nil]
    
    let backgroundColor = Color(red: 0.918, green: 0.894, blue: 0.863)

    // Logica dei Match
    func calculateMatches() -> [Book?] {
        let allBooks = database.books
        let myBooks = library.myBooks
        
        var results: [Book?] = [nil, nil, nil]
        
        // Box 1: Random dal database
        results[0] = allBooks.shuffled().first
        
        // Box 2: Random dalla libreria
        if !myBooks.isEmpty {
            results[1] = myBooks.shuffled().first
        } else {
            results[1] = nil // Indica libreria vuota
        }
        
        // Box 3: Basato sui gusti dell'utente
        if myBooks.isEmpty {
            results[2] = nil // Libreria vuota
        } else {
            let userGenres = Set(myBooks.map { $0.genere })
            let userAuthors = Set(myBooks.map { $0.autore })
            
            // Cerchiamo libri nel DB che:
            // 1. NON sono già nella libreria dell'utente
            // 2. Hanno lo stesso autore o lo stesso genere
            let potentialMatches = allBooks.filter { dbBook in
                let alreadyOwned = myBooks.contains(where: { $0.id == dbBook.id })
                let matchesGenre = userGenres.contains(dbBook.genere)
                let matchesAuthor = userAuthors.contains(dbBook.autore)
                return !alreadyOwned && (matchesGenre || matchesAuthor)
            }
            
            results[2] = potentialMatches.shuffled().first // Se vuoto, ritorna nil (unico nel genere)
        }
        
        return results
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Box 1: Sempre Random
                            MatchCardView(
                                book: dailyBooks[0],
                                title: "You may not know:",
                                emptyMessage: "")
                            .id(dailyBooks[0]?.id ?? UUID())

                            // Box 2: Dalla Libreria
                            MatchCardView(
                                book: dailyBooks[1],
                                title: "Back to your shelf",
                                emptyMessage: "Add books to your library to unlock this box!"
                            )
                            .id(dailyBooks[1]?.id ?? UUID())

                            // Box 3: Basato sui gusti
                            MatchCardView(
                                book: dailyBooks[2],
                                title: "Based on your taste:",
                                emptyMessage: library.myBooks.isEmpty ?
                                    "Add books to help us understand your taste!" :
                                    "You've read everything in this genre! Add more variety to see new tips."
                            )
                            .id(dailyBooks[2]?.id ?? UUID())
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .onAppear { generateDailyMatches() }
            .onChange(of: library.myBooks) {
                            // Se il numero di libri cambia, proviamo a refreshare
                            generateDailyMatches()
                        }
            .onChange(of: database.books) {generateDailyMatches() }
        }
    }
    
    func generateDailyMatches() {
        let today = Date().formatted(date: .complete, time: .omitted)
        
        // CASO 1: È un nuovo giorno (o prima apertura assoluta)
        if lastDate != today {
            let newMatches = calculateMatches()
            saveAndApply(newMatches, date: today)
            return
        }
        
        // CASO 2: È lo stesso giorno.
        // Controlliamo se i box 2 o 3 sono vuoti (ID vuoti) e se la libreria è cambiata.
        let needsFilling = recID2.isEmpty || recID3.isEmpty
        let libraryChanged = library.myBooks.count != lastLibraryCount
        
        if needsFilling && libraryChanged {
            // Ricalcoliamo i match potenziali
            var updatedMatches = calculateMatches()
            
            // Se il libro 1 era già stato salvato oggi, lo "riprendiamo"
            // invece di usare quello nuovo appena generato casualmente.
            if let existingBook1 = database.books.first(where: { $0.id.uuidString == recID1 }) {
                updatedMatches[0] = existingBook1
            }
            
            saveAndApply(updatedMatches, date: today)
        } else {
            // CASO 3: Tutto è già aggiornato, carichiamo i dati salvati
            loadSavedMatches()
        }
    }

    // Funzione di supporto per pulire il codice: Salva e Applica
    private func saveAndApply(_ matches: [Book?], date: String) {
        self.dailyBooks = matches
        self.recID1 = matches[0]?.id.uuidString ?? ""
        self.recID2 = matches[1]?.id.uuidString ?? ""
        self.recID3 = matches[2]?.id.uuidString ?? ""
        self.lastDate = date
        self.lastLibraryCount = library.myBooks.count
    }

    // Funzione di supporto per caricare i dati salvati
    private func loadSavedMatches() {
        let b1 = database.books.first(where: { $0.id.uuidString == recID1 })
        let b2 = database.books.first(where: { $0.id.uuidString == recID2 })
        let b3 = database.books.first(where: { $0.id.uuidString == recID3 })
        self.dailyBooks = [b1, b2, b3]
    }
    
    private var headerView: some View {
        HStack {
            Text("Hi \(username.isEmpty ? "User" : username)!")
                .font(.system(size: 32, weight: .bold))
            Spacer()
            NavigationLink(destination: UsernameModifyView()) {
                Image(systemName: "pencil")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
                    .padding(12)
                    .background(Color.black.opacity(0.05))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

struct MatchCardView: View {
    let book: Book?
    let title: String
    let emptyMessage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .bold()
                .tracking(1.5)
                .padding(.horizontal, 5)

            if let book = book {
                // Caso: Libro Disponibile
                NavigationLink(destination: BookDetailView(book: book)) {
                    HStack(spacing: 30) {
                        CoverImageView(imageUrl: book.copertina)
                        Image(systemName: "arrow.right")
                            .font(.title2)
                            .foregroundColor(.black.opacity(0.2))
                        VinylPlaceholderView()
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Caso: Messaggio di errore/invito
                HStack {
                    Text(emptyMessage)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(30)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .background(RoundedRectangle(cornerRadius: 25).stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5])))
            }
        }
        .padding(.horizontal, 20)
    }
}

struct CoverImageView: View {
    let imageUrl: String
    @State private var hasTimedOut = false
    @State private var isLoaded = false // Tracciamo se il caricamento è completato
    
    var body: some View {
        ZStack {
            if hasTimedOut && !isLoaded {
                // Mostra l'errore SOLO se è scaduto il tempo E l'immagine non c'è
                errorPlaceholder
            } else {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .onAppear { isLoaded = true } // Fermiamo logicamente il timeout
                            
                    case .failure(_):
                        errorPlaceholder
                        
                    case .empty:
                        ZStack {
                            Rectangle().fill(Color.gray.opacity(0.1))
                            ProgressView()
                        }
                        .onAppear {
                            startTimeoutTimer()
                        }
                        
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .onChange(of: imageUrl) {
            // RESETTA TUTTO QUANDO CAMBIA L'URL
            hasTimedOut = false
            isLoaded = false
        }
        .onAppear {
            // Se l'immagine non è caricata all'apparizione, avvia il timer
            if !isLoaded { startTimeoutTimer() }
        }
        .id(imageUrl)
        .frame(width: 100, height: 140)
        .cornerRadius(12)
        .clipped()
        // Ripristino effetto vetro e ombra 3D
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [.white.opacity(0.35), .clear, .black.opacity(0.15)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .shadow(color: .black.opacity(0.25), radius: 6, x: 4, y: 5)
    }
    
    private func startTimeoutTimer() {
        // Resettiamo lo stato se la cella viene riutilizzata
        hasTimedOut = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            // Se dopo 10 secondi isLoaded è ancora false, allora attiviamo il timeout
            if !isLoaded {
                withAnimation {
                    hasTimedOut = true
                }
            }
        }
    }
    
    private var errorPlaceholder: some View {
        ZStack {
            Rectangle().fill(Color.gray.opacity(0.2))
            VStack(spacing: 4) {
                Image(systemName: "book.closed").foregroundColor(.gray)
                Text("No img").font(.caption2)}
            }
            .foregroundColor(.gray)
        }
}

// Simula il Vinile nero con il punto interrogativo
struct VinylPlaceholderView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ZStack {
                // 1. Base del Disco
                Circle()
                    .fill(Color(white: 0.05))
                    .frame(width: 100, height: 100)
                
                // 2. Riflesso (Shimmer)
                AngularGradient(gradient: Gradient(colors: [
                    .clear, .white.opacity(0.15), .clear,
                    .white.opacity(0.1), .clear, .white.opacity(0.15), .clear
                ]), center: .center)
                .clipShape(Circle())
                
                // 3. Solchi
                ForEach(0..<4) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                        .frame(width: CGFloat(40 + (i * 15)), height: CGFloat(40 + (i * 15)))
                }
                
                // 4. Etichetta e "?"
                Circle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 32, height: 32)
                
                Text("?")
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(.white.opacity(0.9))
            }
            // Applichiamo la rotazione solo quando isAnimating diventa true
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            // L'animazione lineare e infinita
            .animation(
                isAnimating ?
                .linear(duration: 4).repeatForever(autoreverses: false) :
                .default,
                value: isAnimating
            )
            .shadow(color: .black.opacity(0.15), radius: 8, x: 5, y: 10)
        }
        .frame(width: 100, height: 140)
        .onAppear {
            // Scegliamo un ritardo casuale tra 0 e 2 secondi
            let randomDelay = Double.random(in: 0...2.0)
            
            // Aspettiamo il delay prima di far partire l'animazione
            DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                isAnimating = true
            }
        }
        .onDisappear {
            // Resettiamo per sicurezza
            isAnimating = false
        }
    }
}

#Preview {
    MainView()
        .environmentObject(DatabaseManager())
        .environmentObject(LibraryManager())
}
