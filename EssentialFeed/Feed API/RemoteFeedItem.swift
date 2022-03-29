//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/29/22.
//

import Foundation

// Constructor that receives items and maps them into FeedItem
// The API representation context to hide the knowledge of API from FeedITem
internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
