# NetworkCompose

NetworkCompose simplifies and enhances network-related tasks by providing a flexible and intuitive composition of network components. Reduce development effort and make your networking layer easy to maintain with seamless integration, SSL pinning, mocking, metric reporting, and smart retry mechanisms. It supports dynamic automation, making it a powerful tool for managing network operations in your Swift applications.

## Table of Contents

I. [Features](#i-features)

II. [Testability](#ii-testability)

III. [Integration](#iii-integration)
   - 3.1. [Integration through CocoaPods](#31-integration-through-cocoapods)
   - 3.2. [Integration through Swift Package Manager (SPM)](#32-integration-through-swift-package-manager-spm)

IV. [Basic Setup](#iv-basic-setup)

V. [Making Requests](#v-making-requests)
   - 5.1. [Async/Await Request](#51-asyncawait-request)
   - 5.2. [Completion Handler Request](#52-completion-handler-request)
   - 5.3. [Re-authentication](#53-re-authentication)
   - 5.4. [SSL Pinning](#54-ssl-pinning)
   - 5.5. [Network Metric](#55-network-metric)
   - 5.6. [Smart Retry](#56-smart-retry)
   - 5.7. [Automation Test](#57-automation-test)
   - 5.8. [setDefaultConfiguration](#58-setdefaultconfiguration)

VI. [Support](#vi-support)

VII. [Contributing](#vii-contributing)

VIII. [License](#viii-license)

## I. Features

- **Seamless URLSession Integration**: Reduce development effort by seamlessly integrating with URLSession, providing a unified and streamlined networking experience.

- **SSL Pinning**: Enhance security effortlessly with built-in support for SSL pinning to establish trust and secure communication.

- **Mocking for Automation Tests**: Easily mock network responses for automation tests, reducing the effort required for testing scenarios and ensuring robust automation.

- **Metric Reporting**: Gain insights into network performance effortlessly with comprehensive metric reporting capabilities, making it easy to identify and optimize bottlenecks.

- **Smart Retry Mechanisms**: Effortlessly handle transient errors with smart retry mechanisms, ensuring a more robust and reliable networking layer.

## II. Testability

`NetworkCompose` is designed with testability in mind, making it easy to write unit tests and ensure the reliability of your networking layer. Effortlessly mock servers for UI and automation tests, streamlining the testing process.

## III. Integration

### 3.1. Integration through CocoaPods

To integrate NetworkCompose into your Xcode project using CocoaPods, add the following to your `Podfile`:

```ruby
pod 'NetworkCompose', '~> 0.0.2'
```
then run:
```bash
pod install
```
### 3.2. Integration through Swift Package Manager (SPM)
To integrate NetworkCompose using Swift Package Manager, add the following to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/harryngict/NetworkCompose.git", from: "0.0.2")
],
targets: [
    .target(
        name: "YourTargetName",
        dependencies: ["NetworkCompose"]
    )
]
```
Replace "YourTargetName" with the name of your target. Then, run:
```bash
swift package update
```

## IV. Basic setup
`NetworkCompose` provides a set of abstractions and components to manage your network requests. Here's a basic setup using `NetworkBuilder` and `NetworkQueueBuilder`.

``` swift
let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
let networkQueue: NetworkQueueBuilder<URLSession> = NetworkQueueBuilder(baseURL: baseURL)
```

## V. Making Requests
Now, let's see how to make various types of network requests using `NetworkBuilder` and `NetworkQueueBuilder`.

### 5.1. Async/Await Request
```swift
let request = NetworkRequestBuilder<[User]>(path: "/posts", method: .GET).build()
let result: [User] = try await network.build().request(request)
// Handler \(result) here
```

### 5.2. Completion Handler Request
```swift
let request = NetworkRequestBuilder<[User]>(path: "/comments", method: .GET)
        .setQueryParameters(["postId": "1"])
        .build()
        
network.build().request(request) { (result: Result<[User], NetworkError>) in
    // Handler result here
}
```

### 5.3. Re-authentication
```swift
 let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
        .setQueryParameters(["title": "foo", "body": "bar", "userId": 1])
        .setRequiresReAuthentication(true)
        .build()

networkQueue.setReAuthService(self) // setReAuthService to enable re-authentication
            build()
            .request(request) { (result: Result<User, NetworkError>) in
                 // Handler result here
             }
```
We have to conforms to the `ReAuthenticationService` protocol, which allows you to handle re-authentication.
``` swift
    public func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void) {
        // For testing now. In fact, this value should get `newtoken` from the real service
        completion(.success(["jwt_token": "newtoken"]))
    }
```

### 5.4. SSL Pinning
```swift
let sslPinningHosts = [NetworkSSLPinningImp(host: "jsonplaceholder.typicode.com",
                                            hashKeys: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]

let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PUT)
            .setQueryParameters(["title": "foo", "body": "bar", "userId": 1])
            .build()

try network.setSSLPinningPolicy(.trust(sslPinningHosts)) // setSSLPinningPolicy to enable SSL Pinning
           .build()
           .request(request) { (result: Result<User, NetworkError>) in
                 // Handler result here
            }
```

### 5.5. Network Metric
```swift
let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST).build()

try? network.setMetricInterceptor(DebugNetworkMetricInterceptor()) // setMetricInterceptor to report metric
            .build()
            .request(request) { (result: Result<User, NetworkError>) in
                // Handler result here
            }
```

Report will show us the information of request, task, session, etc..
```
==============METRIC_REPORT_START==============
🚀 NetworkCompose event name: TaskCreated:
{
  "currentRequest" : {
    "timeout" : 60,
    "rawCachePolicy" : 1,
    "headers" : {
      "Content-Type" : "application\/json; charset=UTF-8"
    },
    "options" : 3,
    "url" : "https:\/\/jsonplaceholder.typicode.com\/posts",
    "httpMethod" : "POST"
  },
  "createdAt" : "2023-11-25T14:41:59Z",
  "originalRequest" : {
    "timeout" : 60,
    "httpMethod" : "POST",
    "headers" : {
      "Content-Type" : "application\/json; charset=UTF-8"
    },
    "options" : 3,
    "url" : "https:\/\/jsonplaceholder.typicode.com\/posts",
    "rawCachePolicy" : 1
  }
}
==============METRIC_REPORT_END==============
```

### 5.6. Smart Retry
```swift
 let request = NetworkRequestBuilder<User>(path: "/posts/1/retry", method: .PUT)
        .setQueryParameters(["title": "foo"])
        .build()

// exponential retry
let retryPolicy: NetworkRetryPolicy = .exponentialRetry(count: 4,
                                                        initialDelay: 1,
                                                        multiplier: 3.0,
                                                        maxDelay: 30.0)
network
    .setDefaultConfiguration() //  reset all configurations
    .build()
    .request(request, retryPolicy: retryPolicy) { (result: Result<User, NetworkError>) in
        // Handler result here
    }
```

### 5.7. Automation Test
```swift
let request = NetworkRequestBuilder<User>(path: "/posts", method: .GET).build()

network.setNetworkStrategy(.mocker(self)) // setNetworkStrategy to mocker
       .build()
       .request(request) { (result: Result<User, NetworkError>) in
          // Handler result here
        }
```
We have conforms to the `NetworkExpectationProvider` protocol, allowing you to provide network expectations for testing purposes.

```swift
public var networkExpectations: [NetworkCompose.NetworkExpectation] {
      let apiExpectation = NetworkExpectation(name: "abc",
                                              path: "/posts",
                                              method: .GET,
                                              response: .successResponse(User(id: 1)))
      return [apiExpectation]
}
```
### 5.8. setDefaultConfiguration
The setDefaultConfiguration function is available to reset all configurations for `NetworkBuilder` and `NetworkQueueBuilder`
```swift
network.setDefaultConfiguration()
networkQueue.setDefaultConfiguration()
```

Thats it!! `NetworkCompose` is successfully integrated and initialized in the project, and ready to use. 

For more detail please go to [Example project](https://github.com/harryngict/NetworkCompose/blob/develop/Example/Example/ClientDemoNetwork.swift).

## VI. Support
Feel free to utilize [JSONPlaceholder](https://jsonplaceholder.typicode.com/guide/) for testing API in `NetworkCompose` examples. If you encounter any issues with `NetworkCompose` or need assistance with
integration, please reach out to me at harryngict@gmail.com. I'm here to support you.

## VII. Contributing
If you want to contribute to `NetworkCompose`, please follow these steps:

1. Fork the repository.

2. Create a new branch for your feature or bug fix.

3. Make your changes and submit a pull request.

## VIII. License
NetworkCompose is available under the MIT license. See the [LICENSE](https://github.com/harryngict/NetworkCompose/blob/master/LICENSE) file for more information.
