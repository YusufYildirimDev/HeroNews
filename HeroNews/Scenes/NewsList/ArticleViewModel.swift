//
//  ArticleViewModel.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import Foundation

struct ArticleViewModel {

    // MARK: - UI Ready Properties
    let title: String
    let summary: String

    /// Explicit creator/author text (required by case)
    let creator: String

    /// Human readable date text (e.g. "3 hours ago")
    let dateText: String?

    /// Combined meta text (creator • date) – still usable if needed
    let meta: String

    let imageURL: URL?
    let isSaved: Bool
    let article: NewsArticle

    // MARK: - Init
    init(article: NewsArticle, isSaved: Bool) {
        self.article = article
        self.isSaved = isSaved
        self.title = article.title
        self.summary = article.summary
        self.imageURL = article.imageURL

        let author = ArticleViewModel.resolveAuthor(article)
        self.creator = author

        if let date = article.publishedAt {
            let relative = date.timeAgoDisplay()
            self.dateText = relative
            self.meta = "\(author) \(Constants.separator) \(relative)"
        } else {
            self.dateText = nil
            self.meta = author
        }
    }
}

// MARK: - Helpers
private extension ArticleViewModel {

    static func resolveAuthor(_ article: NewsArticle) -> String {
        // 1) Authors list → trimmed & non-empty
        if let first = article.authors.first?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !first.isEmpty {
            return first
        }

        // 2) Source → trimmed & non-empty
        let trimmedSource = article.source.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSource.isEmpty {
            return trimmedSource
        }

        // 3) Fallback
        return Constants.unknownAuthor
    }

    enum Constants {
        static let separator = "•"
        static let unknownAuthor = "Unknown Author"
    }
}
