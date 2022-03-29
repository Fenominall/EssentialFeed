//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/13/22.
//

import Foundation

internal final class FeedItemsMapper {
    // MARK: - Properties
    // Because an array inside of item path
    // Creating a container for Feeditems received as json objects to decode them later
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var OK_200: Int { return 200 }
    
    // MARK: - Helpers
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
                  throw RemoteFeedLoader.Error.invalidData
              }
        return root.items
    }
}
