# NetworkCompose

**NetworkCompose** is a versatile and lightweight networking library designed for flexibility, supporting various session types, including URLSession.

## Table of Contents

I. [Features](#i-features)
   
II. [Testability](#ii-testability)

III. [Integration](#iii-integration)
   - 3.1. [Integration through CocoaPods](#31-integration-through-cocoapods)
   
IV. [How to create NetworkRequest](#iv-how-to-create-networkrequest)
   - 4.1. [Using NetworkRequestBuilder](#41-using-networkrequestbuilder)
   - 4.2. [Using NetworkRequest Directly](#42-using-networkrequest-directly)

V. [How to create NetworkSSLPinningPolicy for SSL Pinning](#v-how-to-create-networksslpinningpolicy-for-ssl-pinning)

VI. [How to use NetworkRetryPolicy to send a request](#vi-how-to-use-networkretrypolicy-to-send-a-request)
   - 6.1. [Create a NetworkRetryPolicy instance](#61-create-a-networkretrypolicy-instance)
   
VII. [How to create ReAuthenticationService for automatic Re-authentication](#vii-how-to-create-reauthenticationservice-for-automatic-re-authentication)

VIII. [How NetworkCore and NetworkQueue send a request](#viii-how-networkcore-and-networkqueue-send-a-request)
   - 8.1. [Request async await for iOS-15 above](#81-request-async-await-for-ios-15-above)
   - 8.2. [Request completion closure](#82-request-completion-closure)
   - 8.3. [Request and auto re-authentication](#83-request-and-auto-re-authentication)
   - 8.4. [Request with SSL Pinning](#84-request-with-ssl-pinning)
   - 8.5. [Request with Metric report](#85-request-with-metric-report)
   - 8.6. [Request with retry policy](#86-request-with-retry-policy)
   - 8.7. [Request Mocking support for unit tests](#87-request-mocking-support-for-unit-tests)

IX. [Support](#ix-support)

X. [Contributing](#x-contributing)

XI. [License](#xi-license) 


## I. Features

- **Completion Request**: Utilizes completion handlers for efficient response handling.
  
- **Async Await Request (iOS 15 and above)**: Supports asynchronous programming through Swift's async/await mechanism.

- **Support SSL Pinning**: Enables secure communication by supporting SSL pinning.

- **Support Retry**: Provides support for request retrying to enhance reliability.

- **Dynamic Observer and Receive Request by Any Dispatch Queue**: Offers dynamic observer support and the ability to receive requests on any dispatch queue.

- **Support collect Network Metric**: Facilitates the collection of network metrics, allowing for analysis and monitoring of network behavior.

## II. Testability

For improved testability, `NetworkCompose` provides mock implementations, empowering developers to write effective unit tests. This ensures robustness in various scenarios and easy validation of the library's behavior.


## III. Integration

### 3.1. Integration through CocoaPods

CocoaPods is a dependency manager for Swift projects and makes integration easier.

1. If you don't have CocoaPods installed, you can do it by executing the following line in your terminal.

    ```bash
    sudo gem install cocoapods
    ```

2. If you don't have a Podfile, create a plain text file named Podfile in the Xcode project directory with the following content, making sure to set the platform and version that matches your app.

     **Application**:
   
    ```ruby
    pod 'NetworkCompose/Core',  'latest version'
    pod 'NetworkCompose/Queue', 'latest version'
    ```

    **Testing**:

    ```ruby
    pod 'NetworkCompose/CoreMocks',   'latest version'
    pod 'NetworkCompose/QueueMocks',  'latest version'
    ```
    
Please check latest version [here](https://github.com/harryngict/NetworkCompose/blob/develop/NetworkCompose.podspec)

3. Install NetworkCompose by executing the following in the Xcode project directory.

    ```bash
    pod install
    ```

4. Now, open your project workspace and check if NetworkCompose is properly added.

## IV. How to create NetworkRequest
### 4.1. Using NetworkRequestBuilder

You can create a `NetworkRequest` using the `NetworkRequestBuilder` class, providing a fluent and expressive way to configure your network requests. Below is an example of how to use it:

```swift
let request: NetworkRequest<YourResponseType> = try? NetworkRequestBuilder<YourResponseType>(path: "/your-endpoint", method: .get)
    .setQueryParameters(["param1": "value1", "param2": "value2"])
    .setHeaders(["Authorization": "Bearer YourAccessToken"])
    .setBodyEncoding(.json)
    .setTimeoutInterval(30.0)
    .setCachePolicy(.useProtocolCachePolicy)
    .setRequiresReAuthentication(true)
    .build()
```

### 4.2. Using NetworkRequest Directly

If you prefer a more direct approach, you can create a `NetworkRequest` instance directly. Here's an example:

```swift
let request: NetworkRequest<YourResponseType> = NetworkRequest(
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

## V. How to create NetworkSSLPinningPolicy for SSL Pinning

To implement SSL pinning in your network requests, you can use the `NetworkSSLPinningPolicy` enum along with the concrete implementation of `NetworkSSLPinning`, `NetworkSSLPinningImp`.

### Example Usage:

```swift
// Creating an SSL pinning host
let sslPinningHost = NetworkSSLPinningImp(host: "api.example.com", hashKeys: ["hash1", "hash2"])

// Creating a NetworkSSLPinningPolicy with the SSL pinning host
let sslPinningPolicy = NetworkSSLPinningPolicy.trust([sslPinningHost])
```

Now, you can use this sslPinningPolicy object when setting up SSL pinning in your network requests.

Remember to replace "api.example.com", "hash1", and "hash2" with your actual host and pinning hashes.

Choose the SSL pinning hosts and hashes that match the servers you intend to communicate with securely.

## VI. How to use NetworkRetryPolicy to send a request

### 6.1. Create a NetworkRetryPolicy instance
You can create an instance of `NetworkRetryPolicy` to control the behavior of request retries. Choose between .none for no retries or .retry(count: Int, delay: TimeInterval) to specify the number of retry attempts.

```swift
// Example: Create a retry policy allowing 3 retries with each delay 5.0 seconds
let retryPolicy = NetworkRetryPolicy.retry(count: 2, delay: 5.0)
```

```swift
// Default delay will be 10.0 seconds
let retryPolicy = NetworkRetryPolicy.retry(count: 3)
```

## VII. How to create ReAuthenticationService for automatic Re-authentication

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

## VIII. How NetworkCore and NetworkQueue send a request

```swift
enum Constant {
    static let baseURL: String = "https://jsonplaceholder.typicode.com"
}
```

### 8.1. Request async await for iOS-15 above
```swift
let request = NetworkRequestBuilder<[User]>(path: "/posts", method: .GET)
    .build()
let service = NetworkCoreBuilder(baseURL: baseURL).build()    
let result: [User] = try await service.sendRequest(request)
self.handleResult(result)
```

### 8.2. Request completion closure

```swift
let request = NetworkRequestBuilder<[User]>(path: "/comments", method: .GET)
    .setQueryParameters(["postId": "1"])
    .build()
NetworkCoreBuilder(baseURL: baseURL)
    .build()
    .request(request) { (result: Result<[User], NetworkError>) in
        self.handleResult(result)
    }
```

### 8.3. Request and auto re-authentication
```swift
let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
    .setQueryParameters(["title": "foo",
                         "body": "bar",
                         "userId": 1])
    .setRequiresReAuthentication(true)
    .build()
    NetworkQueueBuilder(baseURL: baseURL)
    .setReAuthService(ClientReAuthenticationService())
    .build()
    .request(request) { (result: Result<User, NetworkError>) in
        self.handleResult(result)
    }
```

### 8.4. Request with SSL Pinning
```swift
let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PUT)
    .setQueryParameters(["title": "foo",
                          "body": "bar",
                          "userId": 1])
    .build()
let sslPinningHost = NetworkSSLPinningImp(host: "jsonplaceholder.typicode.com",
                                          hashKeys: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])
try? NetworkCoreBuilder(baseURL: baseURL)
    .setSSLPinningPolicy(.trust([sslPinningHost]))
    .build()
    .request(request) { (result: Result<User, NetworkError>) in
        self.handleResult(result)
    }
```

### 8.5. Request with Metric report
```swift
let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
    .build()
try? NetworkCoreBuilder(baseURL: baseURL)
    .setMetricInterceptor(LocalNetworkMetricInterceptor())
    .build()
    .request(request) { (result: Result<User, NetworkError>) in
        self.handleResult(result)
    }
```
### 8.6. Request with retry policy
```swift
let request = NetworkRequestBuilder<User>(path: "/posts/1/retry", method: .PUT)
    .setQueryParameters(["title": "foo"])
    .build()
NetworkCoreBuilder(baseURL: baseURL)
    .build()
    .request(request, retryPolicy: .retry(count: 2, delay: 5)) { (result: Result<User, NetworkError>) in
        self.handleResult(result)
    }
```

### 8.7. Request Mocking support for unit tests
```swift
let successResult = NetworkResultMock.requestSuccess(
      NetworkResponseMock(statusCode: 200, response: User(id: 1))
)
let session = NetworkSessionMock<[User]>(expected: successResult)
let request = NetworkRequestBuilder<User>(path: "/posts", method: .GET).build()
let service = NetworkCoreBuilder<NetworkSessionMock>(baseURL: baseURL, session: session).build()
service.sendRequest(request) { (result: Result<[User], NetworkError>) in
    self.handleResult(result)
}
```


Thats it!! `NetworkCompose` is successfully integrated and initialized in the project, and ready to use. 

For more detail please go to [Example project](https://github.com/harryngict/NetworkCompose/blob/master/Example/Example/Client/ClientNetworkFactory.swift).

## IX. Support
Feel free to utilize [JSONPlaceholder](https://jsonplaceholder.typicode.com/guide/) for testing API in `NetworkCompose` examples. If you encounter any issues with `NetworkCompose` or need assistance with
integration, please reach out to me at harryngict@gmail.com. I'm here to support you.

## X. Contributing
If you want to contribute to `NetworkCompose`, please follow these steps:

1. Fork the repository.

2. Create a new branch for your feature or bug fix.

3. Make your changes and submit a pull request.

## XI. License
NetworkCompose is available under the MIT license. See the [LICENSE](https://github.com/harryngict/NetworkCompose/blob/master/LICENSE) file for more information.
