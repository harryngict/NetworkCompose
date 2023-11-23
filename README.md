# NetworkSwift

**NetworkSwift** is a versatile and lightweight networking library designed for flexibility, supporting various session types, including URLSession. The library follows a defined contract, implementing three core functions:

1. **HTTPS Request**: Facilitates secure HTTP requests, with support for SSL pinning to enhance security.
2. **Upload File**: Supports the secure uploading of files.
3. **Download File**: Enables the downloading of files with security considerations.

## I. Features

- **Completion Request**: Utilizes completion handlers for efficient response handling.
- **Async Await Request (iOS 15 and above)**: Supports asynchronous programming through Swift's async/await mechanism.

### NetworkSwift/Queue Submodule

NetworkSwift includes a submodule called **NetworkKitQueueImp**, specifically designed to manage auto re-authentication. This feature is crucial in cases where request credentials have expired.

## II. Testability

For improved testability, NetworkSwift provides mock implementations, empowering developers to write effective unit tests. This ensures robustness in various scenarios and easy validation of the library's behavior.


## III. Integration

### Integration through CocoaPods

CocoaPods is a dependency manager for Swift projects and makes integration easier.

1. If you don't have CocoaPods installed, you can do it by executing the following line in your terminal.

    ```bash
    sudo gem install cocoapods
    ```

2. If you don't have a Podfile, create a plain text file named Podfile in the Xcode project directory with the following content, making sure to set the platform and version that matches your app.

    2.1. **Application**:
   
    ```ruby
    pod 'NetworkSwift/Core',  'latest version'
    pod 'NetworkSwift/Queue', 'latest version'
    ```

    2.2. **Testing**:

    ```ruby
    pod 'NetworkSwift/CoreMocks',   'latest version'
    pod 'NetworkSwift/QueueMocks',  'latest version'
    ```
    
Please check latest version [here](https://github.com/harryngict/NetworkSwift/blob/2ed0f4595405ea849b77a9fc39b2ff9aaaf891e6/NetworkSwift.podspec#L3)

3. Install NetworkSwift by executing the following in the Xcode project directory.

    ```bash
    pod install
    ```

4. Now, open your project workspace and check if NetworkSwift is properly added.

## IV. How to create NetworkRequest
### 1. Using NetworkRequestBuilder

You can create a `NetworkRequest` using the `NetworkRequestBuilder` class, providing a fluent and expressive way to configure your network requests. Below is an example of how to use it:

```swift
let request: NetworkRequestImp<YourResponseType> = try? NetworkRequestBuilder<YourResponseType>(path: "/your-endpoint", method: .get)
    .setQueryParameters(["param1": "value1", "param2": "value2"])
    .setHeaders(["Authorization": "Bearer YourAccessToken"])
    .setBodyEncoding(.json)
    .setTimeoutInterval(30.0)
    .setCachePolicy(.useProtocolCachePolicy)
    .setRequiresReAuthentication(true)
    .build()
```

### 2. Using NetworkRequestImp Directly

If you prefer a more direct approach, you can create a NetworkRequestImp instance directly. Here's an example:

```swift
let request: NetworkRequestImp<YourResponseType> = NetworkRequestImp(
    path: "/your-endpoint",
    method: .post,
    queryParameters: ["param1": "value1", "param2": "value2"],
    headers: ["Authorization": "Bearer YourAccessToken"],
    bodyEncoding: .json,
    timeoutInterval: 30.0,
    cachePolicy: .reloadIgnoringLocalCacheData,
    responseDecoder: JSONDecoder(),
    requiresReAuthentication: true
)
```

## V. How to create NetworkKitImp

To execute network requests in your application, you can use the provided `NetworkKitImp` along with either the `NetworkKitFacade`, `NetworkKitBuilder`, or by creating an instance directly.

### 1. Using NetworkKitFacade

`NetworkKitFacade` provides a simplified interface to interact with the underlying `NetworkKitImp`. Here's an example of how to create and use `NetworkKitFacade`:

```swift
let baseURL = URL(string: "https://api.example.com")!
let networkKitFacade = NetworkKitFacade(baseURL: baseURL)

// Now you can use networkKitFacade to make requests
networkKitFacade.request(yourRequest) { result in
    switch result {
    case let .success(response):
        // Handle successful response
    case let .failure(error):
        // Handle error
    }
}
```

### 2. Using NetworkKitBuilder
`NetworkKitBuilder` allows you to configure and build a `NetworkKitImp` instance with specific settings. Here's an example:

```swift
let baseURL = URL(string: "https://api.example.com")!
let networkKit = try? NetworkKitBuilder(baseURL: baseURL)
    .setSecurityTrust(yourSecurityTrust)
    .build()

// Now you can use networkKit to make requests
networkKit?.request(yourRequest) { result in
    switch result {
    case let .success(response):
        // Handle successful response
    case let .failure(error):
        // Handle error
    }
}
```

### 3. Using NetworkKitImp Directly
If you prefer a more direct approach, you can create a NetworkKitImp instance directly and use it to make requests:
```swift
let baseURL = URL(string: "https://api.example.com")!
let networkKit = NetworkKitImp(baseURL: baseURL)

// Now you can use networkKit to make requests
networkKit.request(yourRequest) { result in
    switch result {
    case let .success(response):
        // Handle successful response
    case let .failure(error):
        // Handle error
    }
}
```

## VI. How to create NetworkKitQueueImp 

To execute network requests with automatic re-authentication, you can use the provided `NetworkKitQueueImp` along with either the `NetworkKitQueueFacade`, `NetworkKitQueueBuilder`, or by creating an instance directly.

### 1. Using NetworkKitQueueFacade

`NetworkKitQueueFacade` provides a high-level interface to interact with the underlying `NetworkKitQueueImp`. Here's an example of how to create and use `NetworkKitQueueFacade`:

```swift
let baseURL = URL(string: "https://api.example.com")!
let networkKitQueueFacade = NetworkKitQueueFacade(baseURL: baseURL, reAuthService: yourReAuthService)

// Now you can use networkKitQueueFacade to make requests with automatic re-authentication
networkKitQueueFacade.request(yourRequest) { result in
    switch result {
    case let .success(response):
        // Handle successful response
    case let .failure(error):
        // Handle error, including potential re-authentication failures
    }
}
```
### 2. Using NetworkKitQueueBuilder

`NetworkKitQueueBuilder` allows you to configure and build a NetworkKitQueueImp instance with specific settings. Here's an example:

```swift
let baseURL = URL(string: "https://api.example.com")!
let networkKitQueue = try? NetworkKitQueueBuilder(baseURL: baseURL)
    .setReAuthService(yourReAuthService)
    .setSerialOperationQueue(yourSerialOperationQueue)
    .build()

// Now you can use networkKitQueue to make requests with automatic re-authentication
networkKitQueue?.request(yourRequest) { result in
    switch result {
    case let .success(response):
        // Handle successful response
    case let .failure(error):
        // Handle error, including potential re-authentication failures
    }
}
```

### 3. Using NetworkKitQueueImp Directly
If you prefer a more direct approach, you can create a NetworkKitQueueImp instance directly and use it to make requests:

``` swift
let baseURL = URL(string: "https://api.example.com")!
let networkKitQueue = NetworkKitQueueImp(baseURL: baseURL, reAuthService: yourReAuthService, serialOperationQueue: yourSerialOperationQueue)

// Now you can use networkKitQueue to make requests with automatic re-authentication
networkKitQueue.request(yourRequest) { result in
    switch result {
    case let .success(response):
        // Handle successful response
    case let .failure(error):
        // Handle error, including potential re-authentication failures
    }
}
```

## VII. How to create NetworkSecurityTrustImp for SSL Pinning

To implement SSL pinning in your network requests, you can use the `NetworkSecurityTrustImp` class along with the concrete implementation of `NetworkSSLPinningHost`, `NetworkSSLPinningHostImp`.

### Example Usage:

```swift
// Creating an SSL pinning host
let sslPinningHost = NetworkSSLPinningHostImp(host: "api.example.com", pinningHash: ["hash1", "hash2"])

// Creating a NetworkSecurityTrustImp with the SSL pinning host
let securityTrust = NetworkSecurityTrustImp(sslPinningHosts: [sslPinningHost])
```
In this example, sslPinningHosts is an array that can contain multiple instances of NetworkSSLPinningHostImp, each representing a host with its associated pinning hashes. You can customize the host names and pinning hashes based on your SSL pinning requirements.

Now, you can use this securityTrust object when setting up SSL pinning in your network requests.

Remember to replace "api.example.com", "hash1", and "hash2" with your actual host and pinning hashes.

Choose the SSL pinning hosts and hashes that match the servers you intend to communicate with securely.

## VIII. How to create ReAuthenticationService for Auto Re-authentication

To implement auto re-authentication, you need to create a class or object conforming to the `ReAuthenticationService` protocol. This service will handle the automatic re-authentication process.

### Example Implementation:

```swift
import Foundation

class YourAutoReAuthenticationService: ReAuthenticationService {
    // Customize this class based on your authentication requirements

    // MARK: - Re-authentication

    func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void) {
        // Implement your auto re-authentication logic here
        // This could involve refreshing tokens or obtaining new credentials

        // For example, you might refresh an access token and provide the new headers
        let newHeaders: [String: String] = ["Authorization": "Bearer newAccessToken"]

        // Call the completion handler with the result of re-authentication
        // In case of success, provide the new headers; otherwise, provide an error
        let result: Result<[String: String], NetworkError> = .success(newHeaders)
        completion(result)
    }
}
```

## IX. How to use NetworkKit and NetworkKitQueue

```swift
enum Constant {
    static let baseURL: String = "https://jsonplaceholder.typicode.com"
}
```

### 1. Request async await for iOS-15 above
```swift
let request = NetworkRequestBuilder<[User]>(path: "/posts", method: .GET)
    .build()
let service = NetworkKitFacade(baseURL: baseURL)
let result: [User] = try await service.request(request)
completion("\(result)")
```

### 2. Request completion closure

```swift
let request = NetworkRequestBuilder<[User]>(path: "/comments", method: .GET)
    .setQueryParameters(["postId": "1"])
    .build()
let service = NetworkKitFacade(baseURL: baseURL)
service.request(request) { (result: Result<[User], NetworkError>) in
    self.handleResult(result)
}
```

### 3. Request and auto re-authentication
```swift
let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
    .setQueryParameters(["title": "foo",
                         "body": "bar",
                         "userId": 1])
    .setRequiresReAuthentication(true)
    .build()
let reAuthService = ClientReAuthenticationService()

let service = NetworkKitQueueImp(baseURL: baseURL, reAuthService: reAuthService)
service.request(request) { (result: Result<User, NetworkError>) in
    self.handleResult(result)
}
```
### 4. Download File
```swift
let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PUT)
    .setQueryParameters(["title": "foo",
                          "body": "bar",
                          "userId": 1])
    .build()
let service = NetworkKitFacade(baseURL: baseURL)
service.downloadFile(request) { (result: Result<URL, NetworkError>) in
    self.handleResult(result)
}
```

### 5. Upload File
```swift
let fileURL = URL(fileURLWithPath: "/Users/harrynguyen/Documents/Resources/NetworkSwift/LICENSE")

let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
    .build()
let service = NetworkKitFacade(baseURL: baseURL)
service.uploadFile(request, fromFile: fileURL) { (result: Result<User, NetworkError>) in
    self.handleResult(result)
}
```

### 6. Request with SSL Pinning
```swift
let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PUT)
    .setQueryParameters(["title": "foo",
                          "body": "bar",
                          "userId": 1])
    .build()
                                                        
let sslPinningHosts = [NetworkSSLPinningHostImp(host: "jsonplaceholder.typicode.com",
                                                pinningHash: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]
let securityTrust = NetworkSecurityTrustImp(sslPinningHosts: sslPinningHosts)

let service = try NetworkKitFacade<URLSession>(baseURL: baseURL, securityTrust: securityTrust)
service.request(request) { (result: Result<User, NetworkError>) in
    self.handleResult(result)
}
```

### 7. Request and auto re-authentication with SSL Pinning
```swift
let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PATCH)
    .setQueryParameters(["title": "foo"])
    .build()
                                      
let reAuthService = ClientReAuthenticationService()

let sslPinningHosts = [NetworkSSLPinningHostImp(host: "jsonplaceholder.typicode.com",
                                                pinningHash: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]
let securityTrust = NetworkSecurityTrustImp(sslPinningHosts: sslPinningHosts)

let service = try NetworkKitQueueImp<URLSession>(baseURL: baseURL,
                                                 reAuthService: reAuthService,
                                                 securityTrust: securityTrust)
service.request(request) { (result: Result<User, NetworkError>) in
    self.handleResult(result)
}
```

### 8. Mocking support for unit tests
```swift
let successResult = NetworkKitResultMock.requestSuccess(
      NetworkResponseMock(statusCode: 200, response: User(id: 1))
)
let session = NetworkSessionMock<[User]>(expected: successResult)
let request = NetworkRequestBuilder<User>(path: "/posts", method: .GET)
    .build()
let service = NetworkKitFacade<NetworkSessionMock>(baseURL: baseURL, session: session)
service.request(request) { (result: Result<[User], NetworkError>) in
    self.handleResult(result)
}
```

## X. How to use NetworkRetryPolicy to send a request

### 1. Create a NetworkRetryPolicy instance
You can create an instance of NetworkRetryPolicy to control the behavior of request retries. Choose between .none for no retries or .retry(count: Int) to specify the number of retry attempts.

```swift
// Example: Create a retry policy allowing 3 retries
let retryPolicy = NetworkRetryPolicy.retry(count: 3)
```
### 2. Use NetworkRetryPolicy when sending a request

#### 2.1. Using `NetworkKit`

```swift
// Example: Make a request with retry policy using NetworkKit
networkKit.request(yourRequest, andHeaders: yourHeaders, retryPolicy: retryPolicy) { result in
    switch result {
    case let .success(data):
        // Handle successful response
    case let .failure(error):
        // Handle error, which may include errors after retries
    }
}
```

#### 2.2. Using NetworkKitQueue

```swift
// Example: Make a request with retry policy using NetworkKitQueue
networkKitQueue.request(yourRequest, andHeaders: yourHeaders, retryPolicy: retryPolicy) { result in
    switch result {
    case let .success(data):
        // Handle successful response
    case let .failure(error):
        // Handle error, which may include errors after retries
    }
}
```

Thats it!! NetworkSwift is successfully integrated and initialized in the project, and ready to use. 

For more detail please go to [Example project](https://github.com/harryngict/NetworkSwift/blob/master/Example/Example/Client/ClientNetworkFactory.swift).

## XI. Support
Feel free to utilize [JSONPlaceholder](https://jsonplaceholder.typicode.com/guide/) for testing API in Networkit examples. If you encounter any issues with NetworkSwift or need assistance with
integration, please reach out to me at harryngict@gmail.com. I'm here to support you.

## XII. Contributing
If you want to contribute to NetworkSwift, please follow these steps:

1. Fork the repository.

2. Create a new branch for your feature or bug fix.

3. Make your changes and submit a pull request.

## XIII. License
NetworkSwift is available under the MIT license. See the [LICENSE](https://github.com/harryngict/NetworkSwift/blob/master/LICENSE) file for more information.
