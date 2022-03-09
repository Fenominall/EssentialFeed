//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/8/22.
//

import Foundation

struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
