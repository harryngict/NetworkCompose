# NetworkCompose

NetworkCompose simplifies and enhances network-related tasks by providing a flexible and intuitive composition of network components. Reduce development effort and make your networking layer easy to maintain with seamless integration, SSL pinning, mocking, metric reporting, and smart retry mechanisms. It supports dynamic automation, making it a powerful tool for managing network operations in your Swift applications.
 
## I. Features

- **Simple Request API:** Make network requests effortlessly using a straightforward and intuitive API.

- **Re-authentication Support:** Seamlessly handle scenarios that require re-authentication by implementing the `ReAuthenticationService` protocol.

- **SSL Pinning:** Enhance security with SSL pinning. Configure trusted hosts and corresponding hash keys to ensure a secure communication channel.

- **Network Metrics Reporting:** Collect and report comprehensive network metrics. Gain insights into your network performance.

- **Smart Retry Mechanism:** Implement smart retry policies for resilient network operations. Enhance the reliability of your app by intelligently handling network issues.

- **Automation Support:**
  - **Mocking with FileSystem:** Simulate network responses effortlessly during automated testing by mocking responses from a local file system.
  - **Mocking with UserDefaults:** Streamline your automated testing with the ability to mock network responses stored in UserDefaults.
  - **Customized Automation with Expectations:** Tailor your automated testing by customizing network response mocking with specific expectations.

## II. Testability

`NetworkCompose` is designed with testability in mind, making it easy to write unit tests and ensure the reliability of your networking layer. Effortlessly mock servers for UI and automation tests, streamlining the testing process.

## III. Integration

### 3.1. Integration through CocoaPods

To integrate NetworkCompose into your Xcode project using CocoaPods, add the following to your `Podfile`:

```ruby
pod 'NetworkCompose', '~> 0.0.5'
```

then run:
```bash
pod install
```
### 3.2. Integration through Swift Package Manager (SPM)
To integrate NetworkCompose using Swift Package Manager, add the following to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/harryngict/NetworkCompose.git", from: "0.0.5")
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

## IV. Usage
### 4.1. Initialization
```swift
let baseURL = URL(string: "https://your-api-base-url.com")!
let network = NetworkBuilder(baseURL: baseURL)
```
### 4.2. Making a Request
```swift
let request = NetworkRequest<[ArticleResponse]>(path: "/posts", method: .GET)
    .build()

network.request(request) { result in
    switch result {
    case let .success(articles): print("Received articles: \(articles)")
    case let .failure(error): print("Error: \(error)")
    }
}
```
### 4.3. Re-authentication
```swift
let request = NetworkRequest<ArticleResponse>(path: "/secure-endpoint", method: .GET)
    .setRequiresReAuthentication(true)
    .build()

network
    .setReAuthService(yourReAuthService)
    .request(request) { result in
        // Handle the result
    }
```
### 4.4. SSL Pinning
```swift
let sslPinningHosts = [SSLPinning(host: "your-api-host.com",
                                  hashKeys: ["your-public-key-hash"])]

let request = NetworkRequest<ArticleResponse>(path: "/secure-endpoint", method: .GET)
    .build()

try network
    .setSSLPinningPolicy(.trust(sslPinningHosts))
    .request(request) { result in
        // Handle the result
    }
```

### 4.5. Network Metrics Reporting
```swift
let request = NetworkRequest<[ArticleResponse]>(path: "/posts", method: .GET)
    .build()

try? network
    .setMetricInterceptor(DefaultMetricInterceptor { event in
        // Handle the metric event
    })
    .request(request) { result in
        // Handle the result
    }

```
### 4.6. Smart Retry Mechanism
```swift
let request = NetworkRequest<ArticleResponse>(path: "/posts", method: .GET)
    .build()

// Exponential retry policy
let retryPolicy: RetryPolicy = .exponentialRetry(count: 4, initialDelay: 1, multiplier: 3.0, maxDelay: 30.0)

network
    .request(request, retryPolicy: retryPolicy) { result in
        // Handle the result
    }
```

### 4.7. Automation Support
```swift
let request = NetworkRequest<ArticleResponse>(path: "/posts", method: .GET)
    .build()

network
    .setMockerStrategy(yourMockerStrategy)
    .request(request) { result in
        // Handle the result
    }
```
### 4.8. Set default configuration
The `func setDefaultConfiguration` is available to reset all configurations for `NetworkCompose`

```swift
network.setDefaultConfiguration()
```
Thats it!! `NetworkCompose` is successfully integrated and initialized in the project, and ready to use. 

For more detail please go to [Example project](https://github.com/harryngict/NetworkCompose/blob/develop/Example/Example/ClientDemoNetwork.swift).

## V. Support
Feel free to utilize [JSONPlaceholder](https://jsonplaceholder.typicode.com/guide/) for testing API in `NetworkCompose` examples. If you encounter any issues with `NetworkCompose` or need assistance with
integration, please reach out to me at harryngict@gmail.com. I'm here to support you.

## VI. License
NetworkCompose is available under the MIT license. See the [LICENSE](https://github.com/harryngict/NetworkCompose/blob/master/LICENSE) file for more information.
