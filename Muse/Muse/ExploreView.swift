//
//  ExploreView.swift
//  Muse
//
//  Created by Riccardo on 18/02/26.
//

import SwiftUI

struct Category: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let icon: String
}

struct ExploreView: View {
    
    @EnvironmentObject var dataManager: DatabaseManager

    let categories = [
         Category(name: "Adventure", color: .green, icon: "mountain.2.fill"),
         Category(name: "Classic", color: .orange, icon: "text.book.closed.fill"),
         Category(name: "Crime", color: .purple, icon: "magnifyingglass"),
         Category(name: "Fantasy", color: .indigo, icon: "sparkles"),
         Category(name: "History", color: .gray, icon: "building.columns.fill"),
         Category(name: "Horror", color: .black, icon: "skull.fill"),
         Category(name: "Psychology", color: .cyan, icon: "brain.fill"),
         Category(name: "Romance", color: .pink, icon: "heart.fill"),
         Category(name: "Satire", color: .mint, icon: "theatermasks.fill"),
         Category(name: "Science", color: .blue, icon: "atom"),
         Category(name: "Sports", color: .orange, icon: "trophy.fill"),
         Category(name: "Thriller", color: .red, icon: "eye.fill"),
         Category(name: "Tragedy", color: Color(red: 0.3, green: 0.3, blue: 0.4), icon: "face.dashed.fill"),
         Category(name: "Travel", color: .teal, icon: "airplane")
     ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(categories) { cat in
                    // 'selectedGenre' deve corrispondere al nome usato nella struct sopra
                    NavigationLink(destination: GenreDetailView(selectedGenre: cat.name)) {
                        CategoryBox(category: cat)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color(red: 0.918, green: 0.894, blue: 0.863))
    }
}

struct CategoryBox: View {
    let category: Category
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Sfondo con gradiente
            RoundedRectangle(cornerRadius: 15)
                .fill(category.color.gradient)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Icona decorativa (il "motivo")
            Image(systemName: category.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80) // Grandezza fissa
                .rotationEffect(.degrees(-15))
                .opacity(0.4)
                .blendMode(.overlay) // Fa fondere l'icona con il gradiente di sfondo
                .offset(x: 20, y: 20) // Spostata per tagliarla col bordo
            
            // Testo
            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ExploreView()
        .environmentObject(DatabaseManager())
}
