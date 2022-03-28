//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/28/22.
//

import Foundation

public final class LocalFeedLoader {
    
    // MARK: - Properties
    private let store: FeedStore
    private let currentDate: () -> Date
    
    // MARK: - Lifecycle
    public init(store: FeedStore,
         // using an option error to notify when it has a value
         // using success when there is no value
         currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    // MARK: - Helpers
    public func save(_ items: [FeedItem],
              completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        store.insert(items, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}
