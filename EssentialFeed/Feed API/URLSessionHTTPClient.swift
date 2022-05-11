//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Fenominall on 3/23/22.
//

// using ctrl + shift + | open all windows tab bars
// option + shift + command + T to rename window tab


import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                      let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                // Used for any unexpected Errors
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
