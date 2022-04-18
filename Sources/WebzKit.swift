//
//  Copyright (C) 2017 Webz.IO
//  Ported from the Python by Ran Geva
//
//  WebzKit
//
//  API tools for webz.io.

import Foundation

// Make this public if you ever want to allow consumers to instantiate this class themselves.

let URL_ROOT = "https://api.webz.io"

struct APIError: Error {
    enum ErrorKind {
        case invalidStatusCode
    }
    
    let statusCode: Int
    let type: ErrorKind
}

private class Session {
    
    var token: String?
    
    var nextCall: URL?
    
    init(token: String? = nil) {
        self.token = token
        self.nextCall = nil
    }
    
    private func formatURL(endpoint: String, query: [String: String]) -> URL {
        var urlComponents = URLComponents(string: URL_ROOT)!
        urlComponents.queryItems = packQuery(query: query)
        urlComponents.path = "/" + endpoint
        return urlComponents.url!
    }
    
    // Process the next pending API call if there is one. Returns true if a call was processed
    // and false otherwise.
    
    func getNext(completionHandler: @escaping (Error?, [String: Any]?) -> Void) -> Bool {
        if (nextCall != nil) {
            self.queryURL(url: nextCall!, completionHandler: completionHandler)
            return true
        } else {
            return false
        }
    }
    
    // Pack a query dictionary to a list of URLQueryItems.
    
    private func packQuery(query: [String: String]) -> [URLQueryItem] {
        var urlQueryItems = [URLQueryItem]()
        for (name, value) in query {
            urlQueryItems.append(URLQueryItem(name: name, value: value))
        }
        return urlQueryItems
    }
    
    // Parse the response["next"] JSON parameter to produce a maybe URL.
    
    private func parseNext(path: String) -> URL? {
        return URL(string: URL_ROOT + path)
    }
    
    // Query an API endpoint using a query dictionary.
    
    func query(endpoint: String, query: inout [String: String],
               completionHandler: @escaping (Error?, [String: Any]?) -> Void) -> Void {
        
        query["format"] = "json"
        if (token != nil) {
            query["token"] = token
        }
        queryURL(url: formatURL(endpoint: endpoint, query: query), completionHandler: completionHandler)
    }
    
    // Query an API endpoint using a complete URL with query parameters.
    
    private func queryURL(url: URL,
                          completionHandler: @escaping (Error?, [String: Any]?) -> Void) -> Void {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            var handlerError: Error? = error
            var json: [String: Any]? = nil
            
            if (error == nil) {
                
                let statusCode = (response! as! HTTPURLResponse).statusCode
                
                if (statusCode == 200) {
            
                    json = ((try? JSONSerialization.jsonObject(with: data!)) as! [String: Any]?)
            
                    if (json != nil) {
                        let nextCallPath = json!["next"] as! String?
                        if (nextCallPath != nil) {
                            self.nextCall = self.parseNext(path: nextCallPath!)
                        }
                    }
                
                } else {
                    
                    handlerError = APIError(statusCode: statusCode, type: .invalidStatusCode)
                }
            }
            
            completionHandler(handlerError, json)
        }
        
        task.resume()
    }
}

// Session singleton for module-level functions.

private let session = Session()

public func config(token: String) -> Void {
    session.token = token
}

public func getNext(completionHandler: @escaping (Error?, [String: Any]?) -> Void) -> Bool {
    return session.getNext(completionHandler: completionHandler)
}

public func query(endpoint: String, query: inout [String: String],
           completionHandler: @escaping (Error?, [String: Any]?) -> Void) -> Void {
    return session.query(endpoint: endpoint, query: &query, completionHandler: completionHandler)
}
