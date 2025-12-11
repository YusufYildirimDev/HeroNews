//
//  Date+Extensions.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import Foundation

extension Date {
    
    // MARK: - Shared Formatters (Performance Optimized)
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full 
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
    
    private static let fixedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
    
    
    // MARK: - Public API
    
    func timeAgoDisplay() -> String {
        return Date.relativeFormatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formattedDate() -> String {
        return Date.fixedFormatter.string(from: self)
    }
}
