//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fenominall on 3/29/22.
//
//
// Load Feed From Cache USe Case
// Primary course
// 1. Execute "Load Image Feed" command with above data.
// 2. System fetches feed data from cache.
// 3. System validates cache is less than seven days old.
// 4. System creates image feed from cached data.
// 5. System delivers image feed.

// Error course (sad path):
// 1. System delivers error.

// Expired cache course (sad path):
// 1. System deletes cache.
// 2. System delivers no feed images.

// Empty cache course (sad path):
// 1. System delivers no feed images.


import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUpOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
}
