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
        let items: [Item]
        
        var feed: [FeedItem] {
            return items.map { $0.item }
        }
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
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Results {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
                  return .failure(RemoteFeedLoader.Error.invalidData)
              }
        return .success(root.feed)
    }
}
