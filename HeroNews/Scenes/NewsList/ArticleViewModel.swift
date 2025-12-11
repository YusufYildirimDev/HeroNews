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
    let meta: String
    let imageURL: URL?
    let isSaved: Bool
    let article: NewsArticle

    init(article: NewsArticle, isSaved: Bool) {
        self.article = article
        self.isSaved = isSaved
        self.title = article.title
        self.summary = article.summary
        self.imageURL = article.imageURL
        self.meta = ArticleViewModel.buildMeta(from: article)
    }
}

private extension ArticleViewModel {

    static func buildMeta(from article: NewsArticle) -> String {
        let author = resolveAuthor(article)

        if let date = article.publishedAt {
            let relative = date.timeAgoDisplay()
            return "\(author) \(Constants.separator) \(relative)"
        }

        return author
    }

    static func resolveAuthor(_ article: NewsArticle) -> String {
        // 1) Authors list → trimmed & non-empty
        if let first = article.authors.first?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !first.isEmpty {
            return first
        }

        // 2) Source → trimmed & non-empty (source zaten String!)
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
