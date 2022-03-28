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
    
    // MARK: - Testing the initialization of RemoteFeedLoader and HTTPClient
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
    
    // MARK: - Checking how many times the values were captured
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    // MARK: - Checking if the client delivers connectivity error when it fails
    // Comparing that capturedErrors is just on error of connectivity error
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    // MARK: - Checking the Errors on the status code
    // Comparing that capturedErrors is just on error
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        // Checking the response error types
        let samples = [199, 201, 300, 400, 500].enumerated()
        samples.forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                // the json is valid but there is nothing to map
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    // MARK: - Success Check for delivering Feeditems with JSON
    func test_load_deliversItemsOn200HTTPResponseWithJSONIItems() {
        let (sut, client) = makeSUT()
        // By default struct initializer is internal and we do not have access to that module
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a test",
            location: "a location",
            imageURL: URL(string: "https://a-another.com")!)
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            let jsonData = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any-string.com")!
        let client = HTTClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(urL: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Results]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    // factory function to make a generic SUT
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut:RemoteFeedLoader, client: HTTClientSpy) {
            
            let client = HTTClientSpy()
            let sut = RemoteFeedLoader(urL: url, client: client)
            trackForMemoryLeaks(sut, file: file, line: line)
            trackForMemoryLeaks(client, file: file, line: line)
            return (sut, client)
        }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Results {
        return .failure(error)
    }
    
    private func makeItem(id: UUID,
                          description: String? = nil,
                          location: String? = nil,
                          imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            
            "location": location,
            "image": imageURL.absoluteString
            // to match the types of objects we need to use 'reduce'
        ].reduce(into: [String: Any]())  { (acc, element) in
            if let value = element.value { acc[element.key] = value }
        }
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: RemoteFeedLoader.Results,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line) {
            
            let expectation = expectation(description: "Wait for load completion")
            
            sut.load { receivedResult in
                switch (receivedResult, expectedResult) {
                    
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(
                        receivedItems, expectedItems, file: file, line: line)
                case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                    XCTAssertEqual(
                        receivedError, expectedError, file: file, line: line)
                default:
                    XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
                }
                expectation.fulfill()
            }
            
            action()
            wait(for: [expectation], timeout: 1.0)
        }
    
    // Subclass for testing
    private class HTTClientSpy: HTTPClient {
        // Step 3: Move the test logic to a new subclass of HTTPClient.
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
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            // Capturing the number of calls of get m ethod in the messages array
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        // Response for the status code error
        func complete(withStatusCode code: Int,
                      data: Data,
                      at index: Int = 0) {
            guard let response = HTTPURLResponse(
                // grabbing the url from the mapped requestedURLs
                url: requestedURLs[index],
                // invoking the passed status code
                statusCode: code,
                httpVersion: nil,
                headerFields: nil) else { return }
            messages[index].completion(.success((data, response)))
        }
    }
    
}
