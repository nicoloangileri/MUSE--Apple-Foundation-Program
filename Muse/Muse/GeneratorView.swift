//
//  GeneratorView.swift
//  Muse
//
//  Created by Riccardo on 21/02/26.
//

import SwiftUI

struct GeneratorView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    @State private var isSkippedForNow: Bool = false
        
        var body: some View {
            if hasCompletedOnboarding || isSkippedForNow{
                ContentView() // L'app normale
            } else {
                WelcomeView(isSkippedForNow: $isSkippedForNow) // La schermata iniziale di 'login'
            }
        }
}

#Preview {
    GeneratorView()
        .environmentObject(DatabaseManager())
        .environmentObject(LibraryManager())
}
