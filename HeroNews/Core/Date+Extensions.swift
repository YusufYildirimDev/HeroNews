//
//  Date+Extensions.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import Foundation

extension Date {
    
    // MARK: - Formatters
    
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale.current
        return formatter
    }()
    
    private static let fixedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        formatter.locale = Locale.current
        return formatter
    }()
    
    // MARK: - Public API
    
    /// Returns relative time string (e.g. "2 hours ago")
    func timeAgoDisplay() -> String {
        return Date.relativeFormatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Returns fixed format string (e.g. "Dec 12, 14:30")
    func formattedDate() -> String {
        return Date.fixedFormatter.string(from: self)
    }
}
