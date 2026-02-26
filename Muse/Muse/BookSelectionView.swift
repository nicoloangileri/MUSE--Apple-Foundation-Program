//
//  BookSelectionOnboardingView.swift
//  Muse
//
//  Created by Riccardo on 22/02/26.
//

import SwiftUI

struct BookSelectionView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("username") var username: String = ""
    @EnvironmentObject var dataManager: DatabaseManager
    @EnvironmentObject var library: LibraryManager
    @State private var searchText = ""
    @State private var selectedBooks: [Book] = []
    
    // FocusState per dare priorità nello schermo alla ricerca quando si clicca la searchbar
    @FocusState private var isSearchFocused: Bool
    
    let backgroundColor = Color(red: 242/255, green: 238/255, blue: 232/255)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // (Scompare con focus)
                if !isSearchFocused {
                    VStack(spacing: 8) {
                        hiddenView
                        Text("To improve the recommendations, please choose at least 1 book you enjoyed")
                            .font(.system(.title3, design: .serif)).bold()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .top).combined(with: .opacity)))
                    .padding(.top, 20)
                }

                // Area libri selezionati
                if !selectedBooks.isEmpty {
                    selectedBooksHorizontalSection
                        .padding(.top, isSearchFocused ? 10 : 15) // Abbassato leggermente quando focalizzato
                }

                // Barra di ricerca e lista
                VStack(spacing: 15) {
                    SearchBar(text: $searchText, isFocused: _isSearchFocused)
                        .padding(.horizontal, 20)

                    // La lista ora occupa tutto lo spazio rimanente con la variabile di tipo @FocusState
                    resultsList
                }
                .padding(.top, 10)

                // Tasto completamento (Fisso in basso se la tastiera è chiusa)
                if !isSearchFocused {
                    actionButtons
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isSearchFocused)
        // Chiude la tastiera se si trascina la lista
        .scrollDismissesKeyboard(.interactively)
    }

    // Sottoviste per pulizia

    private var selectedBooksHorizontalSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) { // Più spazio tra un libro e l'altro
                ForEach(selectedBooks) { book in
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 8) {
                            // Dimensioni reali senza scaleEffect per massima nitidezza
                            CoverImageView(imageUrl: book.copertina)
                                .frame(
                                    width: isSearchFocused ? 60 : 80,
                                    height: isSearchFocused ? 90 : 120
                                )
                                .cornerRadius(8)
                                .shadow(radius: 4)

                            if !isSearchFocused {
                                Text(book.titolo)
                                    .font(.system(size: 11, weight: .medium, design: .serif))
                                    .lineLimit(1)
                                    .frame(width: 80)
                            }
                        }
                        // Padding extra per non far tagliare la X
                        .padding(.top, 10)
                        .padding(.trailing, 10)

                        // Bottone X di rimozione
                        Button(action: { toggleBook(book) }) {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .red)
                                .font(.title3)
                        }
                        // Posizionato meglio per non sovrapporsi troppo alla copertina
                        .offset(x: 0, y: 0)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        // Altezza del contenitore aumentata per evitare i tagli
        .frame(height: isSearchFocused ? 110 : 170)
    }

    private var resultsList: some View {
        List {
            let filtered = dataManager.books.filter {
                searchText.isEmpty ? false : $0.titolo.localizedCaseInsensitiveContains(searchText)
            }
            
            ForEach(filtered) { book in
                HStack {
                    CoverImageView(imageUrl: book.copertina)
                        .frame(width: 40, height: 60)
                        .scaleEffect(0.4)
                        .frame(width: 40, height: 60)
                    Text(book.titolo)
                        .font(.system(.body, design: .serif))
                    Spacer()
                    Button(action: { toggleBook(book) }) {
                        Image(systemName: selectedBooks.contains(where: { $0.id == book.id }) ? "checkmark.circle.fill" : "plus.circle")
                            .foregroundColor(selectedBooks.contains(where: { $0.id == book.id }) ? .brown : .secondary)
                            .font(.title3)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var actionButtons: some View {
        VStack(spacing: 15) {
            Button(action: { completeOnboarding() }) {
                Text(selectedBooks.count >= 1 ? "Complete configuration" : "Add at least 1 book")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedBooks.count >= 1 ? Color.brown : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .disabled(selectedBooks.count < 1)

            Button("Skip") { hasCompletedOnboarding = true }
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
    }
    
    func toggleBook(_ book: Book) {
        withAnimation(.spring()) {
            if let index = selectedBooks.firstIndex(where: { $0.id == book.id }) {
                selectedBooks.remove(at: index)
            } else {
                selectedBooks.append(book)
            }
        }
    }
    
    func completeOnboarding() {
        // Serve per aggiungere i libri selezionati alla libreria reale
        for book in selectedBooks {
            library.addToLibrary(book: book)
        }
        // Chiudiamo l'onboarding
        hasCompletedOnboarding = true
    }
    
    private var hiddenView: some View {
        VStack {
            Text("Hi \(username), welcome to Muse!")
                .font(.system(.largeTitle, design: .serif)) // Font Serif
                .bold()
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }
}

struct SearchBar: View {
    @Binding var text: String
    @FocusState var isFocused: Bool // Riceve il focus dalla vista padre

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search a book...", text: $text)
                .textFieldStyle(.plain)
                .focused($isFocused) // Collega il focus al TextField
                .submitLabel(.done)
            
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                    self.isFocused = false // Chiude tastiera se l'utente cancella tutto (opzionale)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}


#Preview {
    BookSelectionView()
        .environmentObject(DatabaseManager())
        .environmentObject(LibraryManager())
}
