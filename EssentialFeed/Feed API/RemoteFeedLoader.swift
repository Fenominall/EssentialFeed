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
    
    public typealias Results = LoadFeedResult
    
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
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Results {
        do {
            let items = try FeedItemsMapper.mapWithDecoding(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(id: $0.id,
                      description: $0.description,
                      location: $0.location,
                      url: $0.image)
        }
    }
}
