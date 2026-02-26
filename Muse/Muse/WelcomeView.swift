//
//  WelcomeView.swift
//  Muse
//
//  Created by Riccardo on 22/02/26.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isSkippedForNow: Bool
    @AppStorage("username") var username: String = ""
    let backgroundColor = Color(red: 242/255, green: 238/255, blue: 232/255)

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Welcome!")
                        .font(.system(.largeTitle, design: .serif)).bold() // Tocco elegante
                        .padding(.top, 20)
                    Spacer()
                    
                    // Aggiunto un leggero bagliore all'icona
                    Image(systemName: "sparkles")
                        .font(.system(size: 70, weight: .light))
                        .foregroundColor(.brown) // Cambiato in marrone per matchare il tema
                        .shadow(color: .brown.opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 15) {
                        Text("Personalize your experience")
                            .font(.system(.title, design: .serif)).bold()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                        
                        Text("Set up your profile to receive personalized recommendations or explore the catalog now.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .lineSpacing(4) // Più riposante da leggere
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 15) {
                        // Avanza l'OnBoarding
                        NavigationLink(destination: UsernameEntryView()) {
                            Text("Personalize now")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                // Sostituito il blu base di iOS con un gradiente marrone
                                .background(
                                    LinearGradient(colors: [Color.brown, Color.brown.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.brown.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        // Porta direttamente all'app
                        Button("Remind me later") {
                            // Se salta, imposta 'User' di default se vuoto
                            username = username.trimmingCharacters(in: .whitespaces).isEmpty ? "User" : username
                            isSkippedForNow = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    WelcomeView(isSkippedForNow: .constant(false))
        .environmentObject(DatabaseManager())
        .environmentObject(LibraryManager())
}
