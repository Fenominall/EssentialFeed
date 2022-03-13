//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/9/22.
//

import Foundation

// We don`t need to start by confirming to the <FeedLoader> protocol
// We can take smaller (and safer) steps by test-driving the implementation.
public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Results = LoadFeedResult<Error>
    
    public init(urL: URL, client: HTTPClient) {
        self.url = urL
        self.client = client
    }

    
    public func load(completion: @escaping (Results) -> Void) {
        // Step 2: Move the test logic from the RemoteFeedLoader to HTTPClient
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(FeedItemsMapper.map(data, from: response))
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

