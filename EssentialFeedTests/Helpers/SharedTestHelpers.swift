//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Fenominall on 4/3/22.
//

import Foundation


func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}


func anyURL() -> URL{
    return URL(string: "https://any-url.com")!
}
