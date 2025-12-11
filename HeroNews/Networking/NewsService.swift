//
//  NewsService.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import Foundation

// MARK: - News Service Protocol
protocol NewsServiceProtocol {
    func fetchHeadlines() async throws -> [NewsArticle]
}

// MARK: - News Service Implementation
final class NewsService: NewsServiceProtocol {

    // MARK: - Dependencies
    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Initializer
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: - Fetch Headlines
    func fetchHeadlines() async throws -> [NewsArticle] {

        let request = try NewsEndpoint.headlines().buildRequest()

        do {
            // MARK: Perform Network Request
            let (data, response) = try await session.data(for: request)

            // MARK: Validate HTTP Response
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse(statusCode: -1, data: data)
            }

            guard 200..<300 ~= http.statusCode else {
                throw NetworkError.invalidResponse(statusCode: http.statusCode, data: data)
            }

            // MARK: Validate Data
            guard !data.isEmpty else {
                throw NetworkError.emptyData
            }

            // MARK: Decode Response DTO
            let dto = try decoder.decode(NewsResponseDTO.self, from: data)

            // MARK: Convert DTO to Domain Model
            return dto.results.toDomain()

        // MARK: Error Handling
        } catch let urlError as URLError {
            throw NetworkError.transportError(urlError)

        } catch let decodeError as DecodingError {
            throw NetworkError.decoding(decodeError)

        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
