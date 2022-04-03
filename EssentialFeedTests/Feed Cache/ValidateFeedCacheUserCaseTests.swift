//
//  ValidateFeedCacheUserCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fenominall on 4/3/22.
//

import XCTest
import EssentialFeed


class ValidateFeedCacheUserCaseTests: XCTestCase {
    
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
