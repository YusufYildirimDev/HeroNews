//
//  NewsModels.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import Foundation

// MARK: - Constants
private enum NewsConstants {
    static let unknownTitle = "No Title"
    static let unknownSummary = "No Summary"
    static let unknownSource = "Unknown Source"
}

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

// MARK: - Domain Model
struct NewsArticle: Identifiable, Equatable, Codable {
    let id: UUID
    let title: String
    let summary: String
    let content: String
    let publishedAt: Date?
    let imageURL: URL?
    let source: String
    let authors: [String]
}

// MARK: - Mapper (DTO → Domain)
extension NewsArticleDTO {

    // Prefer static preconfigured formatters
    private static let primaryDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private func parsedDate() -> Date? {
        guard let dateStr = pubDate else { return nil }

        if let date = Self.primaryDateFormatter.date(from: dateStr) {
            return date
        }
        
        if let iso = Self.isoDateFormatter.date(from: dateStr) {
            return iso
        }

        return nil
    }

    func toDomain() -> NewsArticle {
        return NewsArticle(
            id: UUID(),
            title: title?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
                ?? NewsConstants.unknownTitle,
            summary: description?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
                ?? NewsConstants.unknownSummary,
            content: content?.trimmingCharacters(in: .whitespacesAndNewlines)
                ?? "",
            publishedAt: parsedDate(),
            imageURL: imageURL.flatMap(URL.init),
            source: sourceID?.nonEmpty ?? NewsConstants.unknownSource,
            authors: creators?.compactMap { $0.nonEmpty } ?? []
        )
    }
}

// MARK: - Array Mapper
extension Array where Element == NewsArticleDTO {
    func toDomain() -> [NewsArticle] {
        self.map { $0.toDomain() }
    }
}

// MARK: - String Helper
private extension String {
    var nonEmpty: String? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
