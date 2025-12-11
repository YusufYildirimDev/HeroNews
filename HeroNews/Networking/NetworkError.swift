//
//  NetworkError.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import Foundation

// MARK: - Network Error Definitions
enum NetworkError: Error {
    case invalidURL(String)
    case transportError(URLError)
    case invalidResponse(statusCode: Int, data: Data?)
    case emptyData
    case decoding(Error)
    case unknown(Error)
}

// MARK: - Localized Error Descriptions
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"

        case .transportError(let err):
            if err.code == .notConnectedToInternet {
                return "No internet connection. Please check your network."
            }
            if err.code == .timedOut {
                return "The request timed out. Please try again."
            }
            return "Network error: \(err.localizedDescription)"

        case .invalidResponse(let status, _):
            return "Invalid server response. HTTP \(status)"

        case .emptyData:
            return "The server returned no data."

        case .decoding:
            return "Failed to decode response. API format may have changed."

        case .unknown(let err):
            return "An unexpected error occurred: \(err.localizedDescription)"
        }
    }
}
