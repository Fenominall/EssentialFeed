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
    
    // Naming test_"the method which is tested"_"the name of expected behavior"
    func test_init_doesNotRequestDataFromURL() {
        // Step 4: Swap the HTTPCLient shared instance with the spy subclass during tests.
        let (_, client) = makeSUT()
        // We are asserting that we didn't make a URL request since that should only happen when '.load()' is invoked.
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // Three types of injection can be done
    // Constructor injection
    // Property injection
    // Method injection
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        // When we invoke sut.load()
        sut.load { _ in }
        // Then assert that a URL request was initiated in the client
        // The 'url' should match the requestedURL
        // When testing objects collaborating, asserting the values passed is not enough. We also need to ask "how many times was the method invoked?"
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        // Check that it have only one error in an array.
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)

        // Comparing that capturedErrors is just on error
        XCTAssertEqual(capturedErrors, [.connectivity])
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
        // var requestedURL: URL?
        // Checking if the same URL is loaded twice
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        // The syp`s job is to capture the messages (invocations) in a clear and comprehensive way.
        // For example, how many times the message was invoked, with what parameters and in which order.
        // Message passing = invoking behavior
        // In this case, calling the method
        // '.get(from url:, completion:)'
        //        "is the message"
        private var messages = [(url: URL, completion: (Error) -> Void)]()
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }

}
