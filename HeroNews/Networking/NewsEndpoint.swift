//
//  NewsEndpoint.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import Foundation

// MARK: - HTTP Method Definitions
enum HTTPMethod: String {
    case get = "GET"
}

// MARK: - Endpoint Definitions
enum NewsEndpoint {
    case headlines(language: String = "en")
}

// MARK: - Endpoint Configuration
extension NewsEndpoint {

    /// Base URL of the News API
    private var baseURL: String {
        "https://newsdata.io/api/1"
    }

    /// API Key loaded from Info.plist (Key: NEWS_API_KEY)
    private var apiKey: String {
        Bundle.main.infoDictionary?["NEWS_API_KEY"] as? String ?? ""
    }

    /// HTTP method used by the endpoint
    var method: HTTPMethod {
        .get
    }

    /// Specific path of the endpoint
    private var path: String {
        switch self {
        case .headlines:
            return "/news"
        }
    }

    /// Query parameters for each endpoint
    private var queryItems: [URLQueryItem] {
        switch self {
        case .headlines(let language):
            return [
                URLQueryItem(name: "apikey", value: apiKey),
                URLQueryItem(name: "language", value: language)
            ]
        }
    }

    // MARK: - URLRequest Builder

    /// Builds and returns a fully configured URLRequest for the endpoint
    func buildRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL(baseURL + path)
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL("Failed to construct final URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}
