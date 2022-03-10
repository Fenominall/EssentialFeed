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
    
    // MARK: - Testing the
    // Naming test_"the method which is tested"_"the name of expected behavior"
    func test_init_doesNotRequestDataFromURL() {
        // Step 4: Swap the HTTPCLient shared instance with the spy subclass during tests.
        let (_, client) = makeSUT()
        // We are asserting that we didn't make a URL request since that should only happen when '.load()' is invoked.
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: - Checking if the value was captured once
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
    
    // MARK: - Checking how many times the values were chaptured
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    // MARK: - Checking if the client delivers connectivity error when it fails
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        // Check that it have only one error in an array.
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)

        // Comparing that capturedErrors is just on error of connectivity error
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    // MARK: - Checking the Errors on the status code
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
  
        // Checking the response error types
        let samples = [199, 201, 300, 400, 403, 404, 500].enumerated()
        samples.forEach { index, code in
            // Check that it have only one error in an array.
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }
            
            client.complete(withStatusCode: code, at: index)
            // Comparing that capturedErrors is just on error
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
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
        private var messages = [(url: URL, completion: (HTTPClientResult))]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult)) {
            // Capturing the number of calls of get method in the messages array
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        // Response for the status code error
        func complete(withStatusCode code: Int, at index: Int = 0) {
            guard let response = HTTPURLResponse(
                // grabbing the url from the mapped requestedURLs
                url: requestedURLs[index],
                // invoking the passed status code
                statusCode: code,
                httpVersion: nil,
                headerFields: nil) else { return }
            messages[index].completion(.success(response))
        }
    }

}
