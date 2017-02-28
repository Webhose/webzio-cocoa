
# webhose.io client for Cocoa

A simple way to access the Webhose.io API with Swift on macOS, iOS, tvOS, and watchOS.

```
import WebhoseKit

let API_TOKEN = "VVVVVVVV-WWWW-XXXX-YYYY-ZZZZZZZZZZZZ"

func main() {
    var query = ["q": "github"]

    WebhoseKit.config(token: API_TOKEN)
    WebhoseKit.query(endpoint: "filterWebData", query: &query) { error, json do
        if (error == nil) {
            let posts = json!["posts"] as! [[String: Any]]
            
            if (posts.count > 0) {
                let post = posts[0]

                print(post["text"] as! String)
                print(post["published"] as! String)

            } else {
                print("There were no posts for us this time :(")
            }
        }
    }
}

```

## API Key

To make use of the webhose.io API, you need to obtain a token that would be used
on every request. To obtain an API key create an account at https://webhose.io/auth/signup,
and then go into https://webhose.io/dashboard to see your token.

## Installing as a Git submodule

1. Add this repository as a submodule of your application's repository.

2. Drag and drop WebhoseKit.xcodeproj into your application's Xcode project or workspace.

3. On the "General" tab of your application target's settings add WebhoseKit.framework to
   the "Embedded Binaries" section.

4. If your application's target does not contain any Swift you should also set the
   EMBEDDED_CONTENT_CONTAINS_SWIFT build settings to "Yes".

## Testing

To run the unit tests you will need to add a testing API key to the testing environment.
_Unless you do this the tests will always pass_ and runtime errors may go unnoticed. If
you wish to run tests you should, in Xcode:

1. Open the _Manage Schemes_ dialog.
2. Edit the WebhoseKit Tests scheme.
3. Navigate to the Test stage.
4. Navigate to the Arguments tab within the Test stage.
5. Add an API_TOKEN variable to Environment Variables. Its value should be the testing
   key that you wish to use (e.g. your own API key).

Be careful not to distribute your copy of WebhoseKit with your key in it, and don't
forget that you can reset your key from the Webhose.IO control panel if you ever need to.

## Use the API

To get started, you need to import the framework and set your access token (Replace
YOUR_API_KEY with your actual API key).

```
import WebhoseKit

WebhoseKit.config(token: YOUR_API_KEY)

```

### API Endpoints

The first parameter the query() function accepts is the API endpoint string. Available
endpoints:

* filterWebData - access to the news/blogs/forums/reviews API
* productSearch - access to data about eCommerce products/services
* darkWebAPI    - access to the dark web (coming soon)

Now you can make a request and inspect the results in a block:

```
var query = ["q": "github"]
WebhoseKit.query(endpoint: "filterWebData", query: &query) { error, json do
    if (error == nil) {
        debugPrint(json)
    }
}

```

## Full documentation

* `WebhoseKit.config(token: String) -> Void`

    * token - your API key

* `WebhoseKit.query(endpoint: String, query: [String: String],
       completionHandler: @escaping (Error?, [String: Any]?) -> Void) -> Void`

    * endpoint:
        * filterWebData - access to the news/blogs/forums/reviews API
        * productSearch - access to data about eCommerce products/services
        * darkWebAPI - access to the dark web (coming soon)

    * query: A Dictionary of API query parameters. The most common key is the "q" parameter
             that holds the filters Boolean query.
             [Read about the available filters](https://webhose.io/documentation).

    * completionHandler: a block to asynchronously handle the results of the API request

* `WebhoseKit.get_next(completionHandler: @escaping (Error?, [String: Any]?) -> Void) -> Bool` - a method to fetch the next page of results.

    * completionHandler: a block to asynchronously handle the results of the API request

## Polling

If you want to make repeated searches, performing an action whenever there are new
results, poll the WebhoseKit.next_post() function until it returns false:

```
while (WebhoseKit.next_post() { error, json do
    if (error == nil) {
        debugPrint(json)
    }
}) {}

```
