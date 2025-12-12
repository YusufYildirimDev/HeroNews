//
//  NewsDetailViewModel.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/12/25.
//

import Foundation

final class NewsDetailViewModel {

    private let article: NewsArticle

    init(article: NewsArticle) {
        self.article = article
    }

    // MARK: - UI Ready Outputs

    var titleText: String {
        article.title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var authorText: String {
        (article.authors.first ?? article.source)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var dateText: String {
        article.publishedAt?.timeAgoDisplay() ?? ""
    }

    var contentText: String {
        (article.content.isEmpty ? article.summary : article.content)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var imageURL: URL? {
        article.imageURL
    }
}
