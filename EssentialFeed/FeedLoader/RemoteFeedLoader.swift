//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/9/22.
//

import Foundation

public typealias HTTPClientResult = ((Result<(Data, HTTPURLResponse), Error>) -> Void)

// Protocol for a better control
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult))
}

// We don`t need to start by confirming to the <FeedLoader> protocol
// We can take smaller (and safer) steps by test-driving the implementation.
public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Results = ((Result<[FeedItem], Error>))
    
    public init(urL: URL, client: HTTPClient) {
        self.url = urL
        self.client = client
    }
    
    public func load(completion: @escaping (Results) -> Void) {
        // Step 2: Move the test logic from the RemoteFeedLoader to HTTPClient
        client.get(from: url) { result in
            switch result {
            case .success(_):
                completion(.failure(.invalidData))
            case .failure(_):
                completion(.failure(.connectivity))
            }
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

