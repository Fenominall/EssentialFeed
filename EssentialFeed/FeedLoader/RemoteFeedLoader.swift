//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/9/22.
//

import Foundation


// Protocol for a better control
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

// We don`t need to start by confirming to the <FeedLoader> protocol
// We can take smaller (and safer) steps bt test-driving the implementation.
public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(urL: URL, client: HTTPClient) {
        self.url = urL
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        // Step 2: Move the test logic from the RemoteFeedLoader to HTTPClient
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}


//class HTTPClient {
//    // Step 1: Make the shared instance a variable, so the class can be subleased
//    static var shared = HTTPClient()
//
//    // Step 5: Remove HTTPClient private initializer since it`s not a Singleton anymore.
//    // private init() {}
//    // Step 2: Move the test logic from the RemoteFeedLoader to HTTPClient
//    func get(from url: URL) {
//    }
//}

