//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/8/22.
//

import Foundation

public typealias LoadFeedResult = ((Result<[FeedItem], Error>))

public protocol FeedLoader {
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
