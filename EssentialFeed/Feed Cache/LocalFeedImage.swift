//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/29/22.
//

import Foundation


// Mirror of the FeedImage Model but for a local representation
// "Data transfer representation of the model"
public struct LocalFeedImage: Equatable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID,
                description: String?,
                location: String?,
                url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
