//
//  MuseApp.swift
//  Muse
//
//  Created by Samuele Gallo on 18/02/26.
//

import SwiftUI

@main
struct MuseApp: App {
    
    @StateObject private var dataManager = DatabaseManager()
    @StateObject var libraryManager = LibraryManager()
    
    var body: some Scene {
        WindowGroup {
            GeneratorView()
                .environmentObject(dataManager)
                .environmentObject(libraryManager)
                .preferredColorScheme(.light) //tema chiaro forzato per evitare bug grafici sul tema scuro
        }
    }
}
