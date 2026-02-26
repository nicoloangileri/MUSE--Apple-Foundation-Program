//
//  UsernameEntryView.swift
//  Muse
//
//  Created by Riccardo on 22/02/26.
//

import SwiftUI

struct UsernameEntryView: View {
    @AppStorage("username") var username: String = ""
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
                    .cornerRadius(12) // Angoli leggermente più morbidi
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2) // Ombra più elegante
                    .padding(.horizontal, 40)
                    .submitLabel(.done)
                
                Spacer()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            VStack{
                Spacer()
                NavigationLink(destination: BookSelectionView()) {
                    Text("Next")
                        .font(.headline)
                        .bold()
                        .frame(width: 140, height: 50) // Leggermente più largo
                        // Sostituito il verde base con il marrone
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
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    UsernameEntryView()
}
