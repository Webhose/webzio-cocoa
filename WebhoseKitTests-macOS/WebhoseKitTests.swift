//
//  WebhoseKitTests.swift

import WebhoseKit
import XCTest

private func standardQuery(completionHandler: @escaping (Error?, [String: Any]?) -> Void) -> Void {
    var query = ["q": "github"]
    WebhoseKit.query(endpoint: "filterWebData", query: &query, completionHandler: completionHandler)
}

private func loadAPIToken() -> String? {
    let token = getenv("API_TOKEN")
    guard token != nil else {
        return nil
    }
    return String(utf8String: token!)
}

private var configured = false

class WebhoseKitTests_macOS: XCTestCase {
    
    func testExampleCode() {
        standardQuery() { error, json in
            if (error == nil) {
                
                let posts = json!["posts"] as! [[String: Any]]
                
                if (posts.count > 0) {
                    
                    let post = posts[0]
                    
                    XCTAssert(post["text"] != nil)
                    debugPrint(post["text"] as! String)
                    
                    XCTAssert(post["published"] != nil)
                    debugPrint(post["published"] as! String)
                    
                } else {
                    print("There were no posts")
                }
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        
        let token = loadAPIToken()
        if (token != nil) {
            WebhoseKit.config(token: token!)
            configured = true
        }
    }
    
    // Test that pending calls are made successfully.
    
    func testNextCall() {
        if (configured) {
            
            // Make a query to populate nextCall.
        
            standardQuery() { error, json in
                XCTAssert(error == nil)
            }
        
            // Test that one cycle worked as expected.
        
            var maxResultSets = 3
            var resultsPending = true
        
            while (resultsPending && maxResultSets > 0 && WebhoseKit.getNext() { error, json in
                XCTAssert(error == nil)
                resultsPending = (json!["posts"] as! [Any]).count > 0
            }) {
                    maxResultSets = maxResultSets - 1
            }
        } else {
            print("API_TOKEN not configured. Skipping...")
        }
    }

    // Test the completion of a standard query.
    
    func testQuery() {
        if (configured) {
        
            let readyExpectation = expectation(description: "ready")
        
            standardQuery() { error, json in
            
                // Check that the task returned OK.
            
                XCTAssert(error == nil)
            
                // Test the quality of the results received.
            
                XCTAssert((json!["totalResults"] as! Int) > 0)
                XCTAssert((json!["posts"] as! [Any]).count > 0)
            
                readyExpectation.fulfill()
            }
        
            // The timeout here is set quite high because the API was slow to respond.
            // This is very probably due to the size of the result set being received.
            // A smaller standard query would be easier on the API and the test
            // suite.
        
            waitForExpectations(timeout: 15) { error in
                XCTAssertNil(error, "Error")
            }
        } else {
            print("API_TOKEN not configured. Skipping...")
        }
    }
}
