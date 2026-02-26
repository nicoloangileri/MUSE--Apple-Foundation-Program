//
//  UsernameModifyView.swift
//  Muse
//
//  Created by Riccardo on 23/02/26.
//
import SwiftUI

struct UsernameModifyView: View {
    @AppStorage("username") var username: String = ""
    @Environment(\.dismiss) var dismiss // Per tornare indietro dopo la conferma
    @State private var showSuccessAlert = false // Per mostrare l'avviso
    
    let backgroundColor = Color(red: 242/255, green: 238/255, blue: 232/255)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("What name would you like to go by?")
                    .font(.system(.title2, design: .serif)).bold() // Font Serif
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Username...", text: $username)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 40)
                    .submitLabel(.done)
                
                Spacer()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            VStack{
                Spacer()
                
                Button(action: {
                    saveUsername()
                }) {
                    Text("Confirm")
                        .font(.headline)
                        .bold()
                        .frame(width: 140, height: 50)
                        // Gradiente coerente con l'onboarding (marrone)
                        .background(
                            username.trimmingCharacters(in: .whitespaces).isEmpty ?
                            LinearGradient(colors: [Color.gray.opacity(0.5), Color.gray], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color.brown, Color.brown.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(color: username.trimmingCharacters(in: .whitespaces).isEmpty ? .clear : Color.brown.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.bottom, 20)
            }
            .padding(.top, 50)
        }
        // Nasconde la toolbar/tab-bar inferiore
        .toolbar(.hidden, for: .tabBar)
        
        // Avviso di successo
        .alert("Updated!", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss() // Chiude la vista e torna alla MainView
            }
        } message: {
            Text("Your name has been changed successfully.")
        }
    }
    
    // Funzione di salvataggio
    func saveUsername() {
        let cleanName = username.trimmingCharacters(in: .whitespaces)
        if !cleanName.isEmpty {
            username = cleanName
            showSuccessAlert = true
        }
    }
}

#Preview {
    UsernameModifyView()
}
