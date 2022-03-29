//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/29/22.
//

import Foundation


// Mirror of the FeedItem Model but for a local representation
// "Data transfer representation of the model"
public struct LocalFeedItem: Equatable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID,
                description: String?,
                location: String?,
                imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
