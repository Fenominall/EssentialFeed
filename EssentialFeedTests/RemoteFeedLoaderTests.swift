//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Fenominall on 3/8/22.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        // We are asserting that we didn't make a URL request since that should only happen when '.load()' is invoked.
        XCTAssertNil(client.requestedURL)
        
    }

}
