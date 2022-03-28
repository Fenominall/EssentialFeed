//
//  XCTTestCase+MemoryLeakTrackingHelper.swift
//  EssentialFeedTests
//
//  Created by Fenominall on 3/18/22.
//

import Foundation
import XCTest

extension XCTestCase {
    // MARK: - Test for checking memory leaks
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line) {
            // When every test finishes running addTeardownBlock is called
            addTeardownBlock { [weak instance] in
                XCTAssertNil(
                    instance,
                    "Instance should have been deallocated. Potential memory leak.",
                    file: file,
                    line: line)
            }
        }
}
