//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/13/22.
//

import Foundation

public typealias HTTPClientResult = ((Result<(Data, HTTPURLResponse), Error>))

// Protocol for a better control
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
