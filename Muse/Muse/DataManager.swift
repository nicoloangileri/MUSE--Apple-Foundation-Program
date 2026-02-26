//
//  DataImporter.swift
//  Muse
//
//  Created by Riccardo on 19/02/26.
//

import Foundation
import Combine
import SwiftUI

struct BookMatch: Codable, Identifiable {
    let id: String
    let isbn: String
    let book_title: String
    let book_author: String
    let book_cover_url: String
    let book_genre: String
    let book_desc: String
    let book_vibe: String
    let themes: [String]
    let sentiment: SentimentData
    let recommendations: RecommendationContainer
    
    struct SentimentData: Codable {
        let model: String
        let raw_score: Double
        let normalized_score: Double
        let label: String
        let confidence: Double
    }

    struct RecommendationContainer: Codable {
        let songs: [SongMatch]
    }

    struct SongMatch: Codable, Identifiable {
        let id: String
        let title: String
        let artist: String
        let sentiment_score: Double
        let link: String
        let fallback_link: String
    }
}

struct Book: Identifiable, Hashable, Codable{
    let id: UUID
    let isbn: String
    let titolo: String
    let autore: String
    let copertina: String
    let genere: String
    let descrizione: String
    var songs: [Song] = []
}

struct Song: Identifiable, Hashable, Codable{
    let id: UUID
    let titolo: String
    let artista: String
    let link: String
}

class DatabaseManager: ObservableObject {
    @Published var books: [Book] = []
    
    let standardGenres = [
            "fantasy", "science", "crime", "history", "horror", "thriller",
            "psychology", "romance", "sports", "travel",
            "classic", "satire", "tragedy"
        ]
    
    init() {
        loadAndConnectData()
    }
    
    func loadAndConnectData() {
        let rawData = loadDatabase()
        
        DispatchQueue.main.async {
            self.books = rawData.map { item in
                let cleanDesc = item.book_desc.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Converte l'ID stringa del JSON in un oggetto UUID
                let bookUUID = UUID(uuidString: item.id) ?? UUID()
                
                let standardizedGenre = self.mapToStandardGenre(item.book_genre)
                
                // Passiamo l'ID fisso
                var b = Book(id: bookUUID,
                             isbn: item.isbn,
                             titolo: item.book_title,
                             autore: item.book_author,
                             copertina: item.book_cover_url,
                             genere: standardizedGenre,
                             descrizione: cleanDesc)
                
                b.songs = item.recommendations.songs.map { s in
                    let songUUID = UUID(uuidString: s.id) ?? UUID()
                    return Song(id: songUUID, titolo: s.title, artista: s.artist, link: s.link)
                }
                return b
            }
        }
    }
    
    private func mapToStandardGenre(_ rawGenre: String) -> String {
            let g = rawGenre.lowercased()
            
            // Logica di raggruppamento intelligente (col nuovo database non necessario ma per evitare errori o libri fuori posto lo teniamo)
            if g.contains("fant") { return "Fantasy" }
            if g.contains("adve") { return "Adventure" }
            if g.contains("scien") { return "Science" }
            if g.contains("crim") || g.contains("myster") || g.contains("detect") { return "Crime" }
            if g.contains("hist") || g.contains("biogr") { return "History" }
            if g.contains("horr") { return "Horror" }
            if g.contains("thrill") || g.contains("susp") { return "Thriller" }
            if g.contains("psych") { return "Psychology" }
            if g.contains("roman") || g.contains("love") { return "Romance" }
            if g.contains("sport") { return "Sports" }
            if g.contains("trav") { return "Travel" }
            if g.contains("satir") || g.contains("humor") { return "Satire" }
            if g.contains("trag") { return "Tragedy" }
            if g.contains("classic") || g.contains("lit") { return "Classic" }
            
            // Se non trova match particolari, restituisce "Classic" come default
            return "Classic"
        }
}

func loadDatabase() -> [BookMatch] {
    guard let url = Bundle.main.url(forResource: "app_database_final-2", withExtension: "json") else {
        print("File non trovato")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([BookMatch].self, from: data)
    } catch {
        print("ERRORE DECODIFICA: \(error)")
        return []
    }
}
