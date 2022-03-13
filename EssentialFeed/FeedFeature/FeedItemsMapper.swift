//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/13/22.
//

import Foundation

internal final class FeedItemsMapper {
    // MARK: - Properties
    // Because an array inside of item kpath
    // Creating a container for Feeditems received as json objects to decode them later
    private struct Root: Decodable {
        let items: [Item]
    }

    // Constructor that receives items and maps them into FeedItem
    // The API representation context to hide the knowledge of API from FeedITem
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image)
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    // MARK: - Helpers
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self,
                                            from: data)
        return root.items.map({ $0.item })
    }
}
