//
//  Copyright (C) 2017 Webhose.IO
//  Ported from Python on request by Shaun Wheelhouse <shaun@sigio.is>
//
//  WebhoseKit
//
//  API tools for webhose.io.

import Foundation

let API_SCHEME = "http"
let API_FQDN   = "webhose.io"
let API_PREFIX = ""

class Session {
    
    init(token: String = nil) {
        self.token = token
        self.nextCall = []
    }
    
    private func formatURL(path: String, query: Dictionary = nil) -> String {
        return URL(string: API_SCHEME + "://" + API_FQDN + API_PREFIX + path)
    }
    
    func getNext() {
        return self.query(self.nextCall[0])
    }
    
    func query(endpoint: String, parameters: Dictionary = nil) -> Dictionary {
        
        if (parameters != nil) {
            parameters["format"] = "json"
            if (self.token != nil) {
                parameters["token"] = self.token
            }
        }
        
        let url = formatURL("/" + endpoint, parameters)
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            let json = try! JSONSerialization.jsonObject(with: data)
        }
        
        // TODO: Ensure that this task is performed synchronously. If that would be
        //       too expensive then add a callback argument for an anonymous
        //       function signature.
        
        // TODO: Investigate Swift error handling and raise an appropriate error
        //       if the HTTP operation or JSON parse fails.
        
        // TODO: Add subsequent calls from the JSON results to the nextCall stack.
        
        task.resume()
        
        return nil
    }
}

private let session = Session()

func query(endpoint: String, parameters: Dictionary = nil) -> Dictionary {
    return session.query(endpoint, parameters)
}

func getNext() {
    return session.getNext()
}
