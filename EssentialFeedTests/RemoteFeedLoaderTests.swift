//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Fenominall on 3/8/22.
//

import XCTest
// A better approach, when possible, is to test the module through the public interfaces, so we can test the expected behavior as a client of the module.
// @testable Benefit: we`are free to change the implementation and private implementation details without breaking the tests
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        // Step 4: Swap the HTTPCLient shared instance with the spy subclass during tests.
        let (_, client) = makeSUT()
        // We are asserting that we didn't make a URL request since that should only happen when '.load()' is invoked.
        XCTAssertNil(client.requestedURL)
    }
    
    // Three types of injection can be done
    // Constructor injection
    // Property injection
    // Method injection
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        // When we invoke sut.load()
        sut.load()
        // Then assert that a URL request was initiated in the client
        // The 'url' should match the requestedURL
        XCTAssertEqual(client.requestedURL, url)
    }
    
    
    // MARK: - Helpers
    // factory function to make a generic SUT
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!) -> (sut:
                                                            RemoteFeedLoader, client: HTTClientSpy) {
        let client = HTTClientSpy()
        let sut = RemoteFeedLoader(urL: url, client: client)
        return (sut, client)
    }
    
    // Subclass for testing

    private class HTTClientSpy: HTTPClient {
        // Step 3: Move the test logic to a new subclass of HTTPClient.
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }

}
