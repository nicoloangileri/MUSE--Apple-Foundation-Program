//
//  FullDescriptionView.swift
//  Muse
//
//  Created by Riccardo on 19/02/26.
//

import SwiftUI

struct FullDescriptionView: View {
    let text: String
    let title: String
    let cover: String
    let author: String
    
    var body: some View {
        // Aggiungiamo lo ZStack per mantenere la coerenza visiva con la BookDetailView
        ZStack {
            // Sfondo sfocato basato sulla copertina
            AsyncImage(url: URL(string: cover)) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Color(red: 0.918, green: 0.894, blue: 0.863)
                }
            }
            .ignoresSafeArea()
            .blur(radius: 60)
            .opacity(0.4)
            
            // Sfondo crema originale per mantenere la leggibilità
            Color(red: 0.918, green: 0.894, blue: 0.863).opacity(0.85).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) { // Spaziatura leggermente aumentata
                    HStack(alignment: .top) { // Allineamento in alto per non sfasare i testi corti
                        CoverImageView(imageUrl: cover)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(title)
                                .font(.system(.title, design: .serif)).bold() // Font Serif
                            
                            Text(author)
                                .font(.subheadline)
                                .foregroundColor(.secondary) // Scritta 'Autore' leggermente più tenue
                            
                            Spacer()
                        }
                        .padding(.leading, 5) // Piccolo margine extra dalla copertina
                    }
                    
                    Text(text)
                        .font(.system(.body, design: .serif)) // Tipografia da libro
                        .lineSpacing(8) // Rende la lettura più leggera e riposante
                        .foregroundColor(.primary)
                }
                .padding(20)
            }
        }
        .navigationTitle("Full Description")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FullDescriptionView(text: "Esempio di testo molto lungo davvero tanto lungo tanto che potrebbe dover scorrere in più righe per essere completamente letto, sperando che tu possa leggere tutto e non fermarti mai. Esempio di testo molto lungo davvero tanto lungo tanto che potrebbe dover scorrere in più righe per essere completamente letto, sperando che tu possa leggere tutto e non fermarti mai.", title: "Titolo Libro", cover: "", author: "Ciccio")
    }
}
