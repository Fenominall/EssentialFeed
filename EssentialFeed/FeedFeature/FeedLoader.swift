//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/8/22.
//

import Foundation

typealias LoadFeedResult = ((Result<[FeedItem], Error>) -> Void)

protocol FeedLoader {
    func loadItems(completion: @escaping (LoadFeedResult))
}
