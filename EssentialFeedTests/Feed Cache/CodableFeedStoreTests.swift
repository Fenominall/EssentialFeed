//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Fenominall on 4/8/22.
//


// MARK: - Test Use Cases
/// - Retrieve
///     - Empty cache returns empty
///     - Empty cache twice returns empty (no side-effects)
///     - Non-empty cache return data
///     - Non-empty cache twice return same data (no side-effects)
///     - Error return error(if applicable, e.g., invalid data)
///     - Error twice return same error  (if applicable, e.g., invalid data)



import XCTest
import EssentialFeed


class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }

}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
}
