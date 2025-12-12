//
//  Mocks.swift
//  HeroNewsTests
//
//  Created by Yusuf Muhammet Yıldırım on 12/12/25.
//

import Foundation
import XCTest
@testable import HeroNews // Proje adın farklıysa burayı düzelt

// MARK: - Mock Services

class MockNewsService: NewsServiceProtocol {
    var mockArticles: [NewsArticle] = []
    var shouldFail = false
    
    func fetchHeadlines() async throws -> [NewsArticle] {
        if shouldFail { throw NetworkError.emptyData }
        return mockArticles
    }
}

class MockReadingManager: ReadingListManagerProtocol {
    var savedArticles: [NewsArticle] = []
    
    func addToReadingList(_ article: NewsArticle) async {
        savedArticles.append(article)
    }
    
    func removeFromReadingList(_ article: NewsArticle) async {
        savedArticles.removeAll { $0.id == article.id }
    }
    
    func isArticleSaved(id: UUID) async -> Bool {
        return savedArticles.contains(where: { $0.id == id })
    }
    
    func getReadingList() async -> [NewsArticle] {
        return savedArticles
    }
}
