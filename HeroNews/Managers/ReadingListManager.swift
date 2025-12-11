//
//  ReadingListManager.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import Foundation

// MARK: - Reading List Manager Protocol
protocol ReadingListManagerProtocol {
    func addToReadingList(_ article: NewsArticle) async
    func removeFromReadingList(_ article: NewsArticle) async
    func isArticleSaved(id: UUID) async -> Bool
    func getReadingList() async -> [NewsArticle]
}

// MARK: - Actor Implementation (Thread-safe)
actor ReadingListManager: ReadingListManagerProtocol {

    // Singleton
    static let shared = ReadingListManager()
    
    private let key = "saved_articles"
    private let defaults = UserDefaults.standard
    
    // In-memory cache
    private var cache: [NewsArticle] = []

    // MARK: - Init
    private init() {
        self.cache = Self.loadFromDefaults(defaults, key: key)
    }

    // MARK: - Public API

    func addToReadingList(_ article: NewsArticle) async {
        guard !cache.contains(where: { $0.id == article.id }) else { return }
        cache.append(article)
        saveToDefaults()
    }

    func removeFromReadingList(_ article: NewsArticle) async {
        cache.removeAll { $0.id == article.id }
        saveToDefaults()
    }

    func isArticleSaved(id: UUID) async -> Bool {
        return cache.contains(where: { $0.id == id })
    }

    func getReadingList() async -> [NewsArticle] {
        return cache
    }

    // MARK: - Persistence (Private Helpers)

    private func saveToDefaults() {
        do {
            let encoded = try JSONEncoder().encode(cache)
            defaults.set(encoded, forKey: key)
        } catch {
            print("ReadingList encode error:", error.localizedDescription)
        }
    }

    private static func loadFromDefaults(_ defaults: UserDefaults, key: String) -> [NewsArticle] {
        guard let data = defaults.data(forKey: key) else { return [] }

        do {
            return try JSONDecoder().decode([NewsArticle].self, from: data)
        } catch {
            print("ReadingList decode error:", error.localizedDescription)
            return []
        }
    }
}
