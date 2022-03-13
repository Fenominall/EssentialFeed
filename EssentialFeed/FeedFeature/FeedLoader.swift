//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/8/22.
//

import Foundation

public typealias LoadFeedResult<Error: Swift.Error> = ((Result<[FeedItem], Error>))

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
