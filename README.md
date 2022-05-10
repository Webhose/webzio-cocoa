
# webz.io client for Cocoa

A simple way to access the Webz.io API with Swift on macOS, iOS, tvOS, and watchOS.

```swift
import WebzKit

let API_TOKEN = "VVVVVVVV-WWWW-XXXX-YYYY-ZZZZZZZZZZZZ"

func main() {
    var query = ["q": "github"]

    WebzKit.config(token: API_TOKEN)
    WebzKit.query(endpoint: "filterWebContent", query: &query) { error, json do
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

To make use of the webz.io API, you need to obtain a token that would be used
on every request. To obtain an API key create an account at https://webz.io/auth/signup,
and then go into https://webz.io/dashboard to see your token.

## Installing as a Git submodule

1. Add this repository as a submodule of your application's repository.

   ```bash
   $ cd YourApplication/
   $ git submodule add https://github.com/Webhose/webzio-cocoa.git WebzKit

   ```

2. Make sure your submodules are initialized by running `git submodule --init --recursive`.

3. Drag and drop WebzKit.xcodeproj into your application's Xcode project or workspace.

4. On the "General" tab of your application target's settings add WebzKit.framework to
   the "Embedded Binaries" section.

5. If your application's target does not contain any Swift you should also set the
   EMBEDDED_CONTENT_CONTAINS_SWIFT build settings to "Yes".

6. Start using WebzKit!

## Testing

To run the unit tests you will need to add a testing API key to the testing environment.
_Unless you do this the tests will always pass_ and runtime errors may go unnoticed. If
you wish to run tests you should, in Xcode:

1. Open the _Manage Schemes_ dialog.
2. Edit the WebzKit Tests scheme.
3. Navigate to the Test stage.
4. Navigate to the Arguments tab within the Test stage.
5. Add an API_TOKEN variable to Environment Variables. Its value should be the testing
   key that you wish to use (e.g. your own API key).

Be careful not to distribute your copy of WebzKit with your key in it, and don't
forget that you can reset your key from the webz.IO control panel if you ever need to.

## Use the API

To get started, you need to import the framework and set your access token (Replace
YOUR_API_KEY with your actual API key).

```swift
import WebzKit

WebzKit.config(token: YOUR_API_KEY)

```

### API Endpoints

The first parameter the query() function accepts is the API endpoint string. Available
endpoints:

* filterWebContent - access to the news/blogs/forums/reviews API
* productFilter - access to data about eCommerce products/services
* darkFilter    - access to the dark web (coming soon)

Now you can make a request and inspect the results in a block:

```swift
var query = ["q": "github"]
WebzKit.query(endpoint: "filterWebContent", query: &query) { error, json do
    if (error == nil) {
        debugPrint(json)
    }
}

```

## Full documentation

* `WebzKit.config(token: String) -> Void`

    * token - your API key

* `WebzKit.query(endpoint: String, query: [String: String],
       completionHandler: @escaping (Error?, [String: Any]?) -> Void) -> Void`

    * endpoint:
        * filterWebContent - access to the news/blogs/forums/reviews API
        * productFilter - access to data about eCommerce products/services
        * darkFilter - access to the dark web (coming soon)

    * query: A Dictionary of API query parameters. The most common key is the "q" parameter
             that holds the filters Boolean query.
             [Read about the available filters](https://webz.io/documentation).

    * completionHandler: a block to asynchronously handle the results of the API request

* `WebzKit.get_next(completionHandler: @escaping (Error?, [String: Any]?) -> Void) -> Bool` - a method to fetch the next page of results.

    * completionHandler: a block to asynchronously handle the results of the API request

## Polling

If you want to make repeated searches, performing an action whenever there are new
results, poll the WebzKit.next_post() function until it returns false:

```swift
while (WebzKit.next_post() { error, json do
    if (error == nil) {
        debugPrint(json)
    }
}) {}

```
