//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Fenominall on 3/8/22.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        // Step 2: Move the test logic from the RemoteFeedLoader to HTTPClient
        client.get(from: URL(string: "https://a-url.com")!)
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

// Protocol for a better control
protocol HTTPClient {
    func get(from url: URL)
}

// Subclass for testing

class HTTClientSpy: HTTPClient {
    // Step 3: Move the test logic to a new subclass of HTTPClient.
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        // Step 4: Swap the HTTPCLient shared instance with the spy subclass during tests.
        let client = HTTClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        // We are asserting that we didn't make a URL request since that should only happen when '.load()' is invoked.
        XCTAssertNil(client.requestedURL)
    }
    
    
    // Three types of injection can be done
    // Constructor injection
    // Property injection
    // Method injection
    func test_load_requestDataFromURL() {
        // Given a client and sut
        let client = HTTClientSpy()
        let sut = RemoteFeedLoader(client: client)
        // When we invoke sut.load()
        sut.load()
        // Then assert that a URL request was initiated in the client
        XCTAssertNotNil(client.requestedURL)
    }
}
