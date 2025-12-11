//
//  News.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import Foundation

// MARK: - Top-level API Response (DTO)
struct NewsResponseDTO: Decodable {
    let status: String
    let totalResults: Int
    let results: [NewsArticleDTO]
}

// MARK: - News Article DTO (Raw API Model)
struct NewsArticleDTO: Codable {
    let title: String?
    let description: String?
    let content: String?
    let pubDate: String?
    let imageURL: String?
    let sourceID: String?
    let creators: [String]?

    enum CodingKeys: String, CodingKey {
        case title, description, content, pubDate
        case creators = "creator"
        case imageURL = "image_url"
        case sourceID = "source_id"
    }
}

// MARK: - Domain Model (Clean model used by UI & Business Layer)
struct NewsArticle: Identifiable, Equatable {
    let id: UUID = UUID()
    let title: String
    let summary: String
    let content: String
    let publishedAt: Date?
    let imageURL: URL?
    let source: String
    let authors: [String]
}

// MARK: - Mapper (DTO → Domain Model Conversion)
extension NewsArticleDTO {

    func toDomain() -> NewsArticle {

        let dateFormatter = ISO8601DateFormatter()

        return NewsArticle(
            title: title ?? "Untitled",
            summary: description ?? "",
            content: content ?? "",
            publishedAt: pubDate.flatMap { dateFormatter.date(from: $0) },
            imageURL: imageURL.flatMap { URL(string: $0) },
            source: sourceID ?? "Unknown",
            authors: creators ?? []
        )
    }
}

// MARK: - Array Mapper Helper
extension Array where Element == NewsArticleDTO {
    func toDomain() -> [NewsArticle] { map { $0.toDomain() } }
}
