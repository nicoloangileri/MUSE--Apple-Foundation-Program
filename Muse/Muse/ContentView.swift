//
//  ContentView.swift
//  Muse
//
//  Created by Samuele Gallo on 18/02/26.
//

import SwiftUI

struct ContentView: View {
    
    @State var selection: Int = 0
    
    var body: some View {
        HStack {
            TabView(selection: $selection){
                
                Tab("Matches", systemImage: "shuffle", value: 0){
                    MainView()}
                Tab("MyLibrary", systemImage: "person", value: 1){
                    MyLibraryView()}
                Tab("Search", systemImage: "magnifyingglass", value: 2, role: .search){
                    SearchView()}
            }
            .tint(.brown) // Colora l'icona attiva di marrone invece del blu di default iOS!
        }
        .padding(.bottom, 0)
    }
}

#Preview {
    ContentView()
        .environmentObject(DatabaseManager())
        .environmentObject(LibraryManager())
}
