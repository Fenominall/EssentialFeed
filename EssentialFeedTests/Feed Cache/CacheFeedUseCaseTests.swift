//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fenominall on 3/28/22.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    
    // MARK: - Properties
    private let store: FeedStore
    private let currentDate: () -> Date
    
    // MARK: - Lifecycle
    init(store: FeedStore,
         // using an option error to notify when it has a value
         // using success when there is no value
         currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    // MARK: - Helpers
    func save(_ items: [FeedItem],
              completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items,
                                  timestamp: self.currentDate(),
                                  completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    func insert(_ items: [FeedItem],
                timestamp: Date,
                completion: @escaping InsertionCompletion)
}


// MARK: - CacheFeedUseCaseTests
class CacheFeedUseCaseTests: XCTestCase {
    // MARK: - Use cases for testing cahging
    
    // ### Data: - Feed items
    
    // ### Primary course (happy path):
    // 1. Execute "Save Feed Items" command with above data.
    // 2. System deletes old cache data.
    // 3. System encodes feed items.
    // 4. System timestaps the new cache.
    // 5. System saves new cache data.
    // 6. System delivers success message.
    
    // ### Deleting error course (sad path):
    // 1. System deliver error.
    
    // ### Saving error course (sad path):
    // 1. System delivers error.
    
    
    // ######################################
    // # Does Not Message Store UpOn Creation
    func test_init_doesNotMessageStoreUpOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    // # Request Cache Deletion
    func test_save_requestCacheDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    // # Does Not Request Cache Insertion On Deletion Error
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    // # Requests New Cache Insertion With Time Stamp On Successful Deletion
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    
    // # FailsOnDeletionError
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    // # Fails On Insertion Error
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    // # Succeeds On Successful Cache Insertion
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
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
    
    private func expect(_ sut: LocalFeedLoader,
                        toCompleteWithError expectedError: NSError?,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any-location", imageURL: anyURL())
    }
    
    private func anyURL() -> URL{
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    // MARK: - FeedStoreSpy
    private class FeedStoreSpy: FeedStore {
        // MARK: - Properties
        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void
        
        // Messeges enum
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([FeedItem], Date)
        }
        
        private(set) var receivedMessages = [ReceivedMessage]()
        
        private var deletionCompletions = [(Error?) -> Void]()
        private var insertionCompletions = [(Error?) -> Void]()
        
        // MARK: - Helpers
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCachedFeed)
        }
        
        func completeDeletion(with error: Error,
                              at index: Int = 0) {
            // when it fails passing an error to completion
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            // when it fails passing nil to deletionCompletions
            deletionCompletions[index](nil)
        }
        
        func insert(_ items: [FeedItem],
                    timestamp: Date,
                    completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(items, timestamp))
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully (at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
}
