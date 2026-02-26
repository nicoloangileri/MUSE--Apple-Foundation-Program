//
//  Area Personale.swift
//  Muse
//
//  Created by Samuele Gallo on 18/02/26.
//

import SwiftUI

enum SortOption: String, CaseIterable {
    case alphabetical = "A-Z"
    case author = "Author"
    case recent = "Recent"
}

struct MyLibraryView: View {
    @EnvironmentObject var library: LibraryManager
    @State private var selectedSort: SortOption = .recent
    
    // Configurazione della griglia: 3 colonne flessibili
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    let backgroundColor = Color(red: 0.918, green: 0.894, blue: 0.863)
    
    var sortedBooks: [Book] {
            switch selectedSort {
            case .alphabetical:
                return library.myBooks.sorted { $0.titolo < $1.titolo }
            case .author:
                return library.myBooks.sorted { $0.autore < $1.autore }
            case .recent:
                return library.myBooks // L'ordine con cui arrivano dal database
            }
        }

    var body: some View {
        NavigationStack{
            ZStack {
                backgroundColor.ignoresSafeArea()
                VStack(spacing: 0){
                    headView
                    ScrollView {
                        if library.myBooks.isEmpty {
                            ContentUnavailableView("The Library is empty!",
                                                   systemImage: "book.closed",
                                                   description: Text("Books will appear here as you discover them!  \n Go on, start exploring!"))
                            .padding(.top, 100)
                        } else {
                            LazyVGrid(columns: columns, spacing: 25) {
                                ForEach(sortedBooks) { book in
                                    NavigationLink(destination: BookDetailView(book: book)) {
                                        BookGridItem(book: book)
                                            .id(book.id)
                                    }
                                    .buttonStyle(.plain)
                                    // Menu contestuale per eliminare rapidamente (tenendo premuto)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            library.removeFromLibrary(book: book)
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
        }
    }
    
    private var headView: some View {
        VStack{
            HStack {
                Text("My Library")
                    .font(.system(size: 32, weight: .bold, design: .serif)) // Font serif come nei titoli
                Spacer()
                Menu {
                            Picker("Sort by", selection: $selectedSort) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Label(option.rawValue, systemImage: iconFor(option))
                                        .tag(option)
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.black.opacity(0.05))
                                .clipShape(Circle())
                        }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10) // aggiunto top padding per respirare
        }
    }
}

// Il singolo "box" del libro
struct BookGridItem: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Spaziatura aumentata leggermente
            CoverImageView(imageUrl: book.copertina)
            
            // Titolo sotto la box
            Text(book.titolo)
                .lineLimit(2) // Permettiamo 2 righe così non si taglia subito
                .font(.system(.caption, design: .serif)) // Titoli libri in Serif
                .bold()
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
                .padding(.horizontal, 2)
                .frame(height: 35, alignment: .topLeading) // Altezza fissa per allineare bene la griglia
        }
    }
    
    
}

func iconFor(_ option: SortOption) -> String {
    switch option {
    case .alphabetical: return "textformat.abc"
    case .author: return "person.crop.fill"
    case .recent: return "clock.fill"
    }
}

#Preview {
    MyLibraryView()
        .environmentObject(DatabaseManager())
        .environmentObject(LibraryManager())
}
