//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Fenominall on 4/5/22.
//

import Foundation

internal final class FeedCachePolicy {
    
    // MARK: - Properties
    private static let calendar = Calendar(identifier: .gregorian)
    
    // MARK: - Lifecycle
    private init() {}
            
    // MARK: - Helpers
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day,
                                              value: maxCacheAgeInDays,
                                              to: timestamp) else { return false }
        return date < maxCacheAge
    }
}
