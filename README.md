
# NetworkCompose
## Table of Contents

1. [The NetworkCompose Architecture](#the-networkcompose-architecture)
2. [Features](#i-features)
3. [Integration](#ii-integration)
   1. [Integration through CocoaPods](#21-integration-through-cocoapods)
   2. [Integration through Swift Package Manager (SPM)](#22-integration-through-swift-package-manager-spm)
4. [Usage](#iii-usage)
   1. [Initialization](#31-initialization)
   2. [Configuration Options (Optional)](#32-configuration-options-optional)
      1. [SSLPinningPolicy Configuration](#a-sslpinningpolicy-configuration)
      2. [ReportMetricStrategy Configuration](#b-reportmetricstrategy-configuration)
      3. [ExecutionQueue and ObservationQueue Configuration](#c-executionqueue-and-observationqueue-configution)
      4. [LoggerStrategy Configuration](#d-loggerstrategy-configuration)
      5. [NetworkReachability Configuration](#e-networkreachability-configuration)
      6. [SessionConfigurationType Configuration](#f-sessionconfigurationtype-configuration)
      7. [RecordResponseMode Configuration](#g-recordresponsemode-configuration)
      8. [AutomationMode Configuration](#h-automationmode-configuration)
      9. [Default Configuration](#i-default-configuration)
   3. [How to Execute Regular Call Using NetworkBuilder](#33-how-to-execute-regular-call-by-using-networkbuilder)
   4. [How to Execute Multiple Calls with Priority Using NetworkPriorityDispatcher](#34-how-to-execute-multple-call-with-priority-by-using-networkprioritydispatcher)
   5. [Retry Policy](#35-retry-policy)
   6. [Re-Authentication](#36-re-authentication)
   7. [Request Cancellation](#37-request-cancellation)
5. [Support](#iv-support)
6. [License](#v-license)

## The NetworkCompose architecture:

![NetworkCompose-Architecure](/Documents/NetworkCompose-Architecture.png)


## I. Features
NetworkCompose offers a streamlined and enriched approach to handling network-related tasks, empowering developers with a flexible and intuitive composition of network components. By leveraging NetworkCompose, you can significantly minimize development effort and ensure the simplicity of maintaining networking layers. This robust solution seamlessly integrates various features, including SSL pinning, mocking, metric reporting, and retry mechanisms.

**Key Features:**

1. Effort Reduction: By utilizing NetworkCompose, developers can reduce the overall effort involved in network-related tasks, making development processes more efficient and streamlining.

2. Seamless Integration: Enjoy seamless integration with NetworkCompose, which effortlessly incorporates SSL pinning, mocking, metric reporting, retry exponential back-off mechanisms and circuitBreaker to improve the stability and resilience into network operations.

3. Dynamic Automation: With support for dynamic automation, NetworkCompose becomes a powerful tool for efficiently managing network operations in Swift applications, adapting to changing requirements seamlessly.


## II. Integration

### 2.1. Integration through CocoaPods

To integrate NetworkCompose into your Xcode project using CocoaPods, add the following to your `Podfile`:

```ruby
pod 'NetworkCompose', '~> 0.1.5'
```

then run:
```bash
pod install
```
### 2.2. Integration through Swift Package Manager (SPM)
To integrate NetworkCompose using Swift Package Manager, add the following to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/harryngict/NetworkCompose.git", from: "0.1.5")
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

## III. Usage
In the given diagram, there are two distinct classes designed to handle two different types of requests: Regular Call (RC) and Multiple with Priority (MCP). The Regular Call functionality is implemented using the NetworkBuilder class, while the Multiple with Priority relies on the NetworkPriorityDispatcher class. 

**It's important to note that since the NetworkPriorityDispatcher class inherits from the NetworkBuilder class, it can also be employed for Regular Call scenarios.**

### 3.1 Initialization
- Option 1: NetworkBuilder Initialization
```swift
let baseURL = URL(string: "your base url string")
let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)

```
- Option 2: NetworkPriorityDispatcher Initialization
```swift
let baseURL = URL(string: "your base url string")
let network: NetworkPriorityDispatcher<URLSession> = NetworkPriorityDispatcher(baseURL: baseURL)
```
### 3.2 Configuration options (optional)

### A. [SSLPinningPolicy](/Sources/NetworkCompose/src/Network/SSLPinning/SSLPinningPolicy.swift) configuration

- Option 1: Enable SSL Pinning by providing host and hashKey
```swift
let pinningHost = SSLPinning(host: "your_host", 
                             hashKeys: ["your_key"])
network.sslPinningPolicy(.trust([pinningHost]))
```
- Option 2: Disable SSL Pinning
```swift
network.sslPinningPolicy(.disabled)
```

### B. [ReportMetricStrategy](/Sources/NetworkCompose/src/Network/Metric/ReportMetricStrategy.swift) configuration

- Option 1: Disable Network Metrics Reporting
```swift
network.reportMetric(.disabled)
```
- Option 2: Enable with MetricInterceptor
```swift
let metricInterceptor = MetricInterceptor { event in
    ///  Handle event here      
}
network.reportMetric(.enabled(metricInterceptor))
``` 

### C. ExecutionQueue and ObservationQueue configution
```swift
let concurrent = DispatchQueue(label: "com.NetworkCompose.Demo",
                               qos: .userInitiated,
                               attributes: .concurrent)
network.execute(on: concurrent)
       .observe(on: DispatchQueue.main)
```

### D. [LoggerStrategy](/Sources/NetworkCompose/src/Network/Logger/LoggerStrategy.swift) configuration

- Option 1: Enable Logger Strategy

```swift
network.logger(.enabled)
```
- Option 2: Disable Logger Strategy
```swift
network.logger(.disabled)
```
- Option 3: Customize Logger Strategy
```swift
network.logger(.custom(YourLoggerInterface)). 
```
With option 3, you have the flexibility to customize the logging behavior by conforming to the `LoggerInterface` protocol.
```swift
public protocol LoggerInterface {
    func log(_ type: LoggingType, _ message: String)
}
```

### E. [NetworkReachability](/Sources/NetworkCompose/src/Utility/Reachability/NetworkReachability.swift) configuration
```swift
network.networkReachability(NetworkReachabilityInterface)
```

You can either utilize the default instance `NetworkReachability.shared` or implement a custom one by conforming to the `NetworkReachabilityInterface`.

```swift
public protocol NetworkReachabilityInterface: AnyObject {
    var isInternetAvailable: Bool { get set }

    func startMonitoring(completion: @escaping (Bool) -> Void)
    func stopMonitoring()
}
```


### F. [SessionConfigurationType](/Sources/NetworkCompose/src/Network/Session/SessionConfigurationType.swift) configuration

- Option 1: Use the ephemeral option to ensure that all data is stored in RAM, along with additional optimized configurations for better performance.
```swift
network.sessionConfigurationType(.ephemeral)
``````
- Option 2: Use `default` configuration 
```swift
network.sessionConfigurationType(.default)
```

### G. [RecordResponseMode](/Sources/NetworkCompose/src/NetworkMocker/Storage/RecordResponseMode.swift) configuration
This option enables the module to record and save responses in FileManager during actual usage, facilitating reuse for automation testing in subsequent scenarios.

- Opition 1: Enable Record Response Mode
```swift
network.recordResponseForTesting(.enabled) 
```

- Option 2: Disable Record Response Mode
```swift
network.recordResponseForTesting(.disabled) 
```

**Please be aware that we also offer the clearStoredMockData method, allowing you to delete all recorded data if necessary.**

```swift
network.clearStoredMockData()
```


### H. [AutomationMode](/Sources/NetworkCompose/src/NetworkMocker/AutomationMode.swift) configuration
- Option 1: Utilize locally stored data saved during the Record Response Mode.

```swift
network.automationMode(.enabled(.local)) 
````

- Option 2: Implement a custom expectation for a specific endpoint, necessitating confirmation through [EndpointExpectationProvider](/Sources/NetworkCompose/src/NetworkMocker/EndpointExpectationProvider.swift)
```swift
network.automationMode(.enabled(.custom(self)))
```

### I. Default Configuration
The network settings are initialized with a basic configuration by default. To apply or reset to the default configuration, use the
`setDefaultConfiguration` method:

```swift
network.setDefaultConfiguration()
```
This method resets the network settings, clearing any custom configurations and applying default values for optimal use.

**Note: If the client doesn't specify a custom configuration, the default settings are automatically applied during initialization.**

### 3.3 How to execute regular call by using NetworkBuilder

```swift
let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
 network.build()
      .request(request) { result in
        // Handle reponse here
      }
```

### 3.4 How to execute multple call with priority by using NetworkPriorityDispatcher
You can define your request using [Priority](/Sources/NetworkCompose/src/Network/Priority.swift). The execution will be determined by both priority and creation date

```swift
let request1 = RequestBuilder<[Comment]>(path: "/posts/1/comments", method: .GET).build()
let request2 = RequestBuilder<[Photo]>(path: "/albums/1/photos", method: .GET).build()
let request3 = RequestBuilder<[Post]>(path: "/users/1/albums", method: .GET).build()
let network: NetworkPriorityDispatcher<URLSession> = NetworkPriorityDispatcher(baseURL: baseURL)

network.addRequest(request1, priority: .medium) { result in
            // handle reponse for request 1       
        }
        .addRequest(request2, priority: .high) { result in
            // handle reponse for request 2
        }
        .addRequest(request3, priority: .low) { result in
            // handle reponse for request 3
        }.execute {
           // Completed all request here
        }
```
Note: `priority` is optional and it is `medium` by default.

### 3.5 Retry policy
We've also introduced a Retry policy to implement retry strategies for robust network operations, thereby improving the overall reliability of your application in handling network issues.

- Option 1: Constant Retry Count and Delay Time
```swift
let retryPolicy: RetryPolicy = .constant(count: 3, delay: 5.0)
```
- Option 2: Exponential Retry
```swift
let retryPolicy: RetryPolicy = .exponentialRetry(count: 3,
                                                 initialDelay: 1,
                                                 multiplier: 3.0,
                                                 maxDelay: 30.0)
```

Integrate the Retry Policy with `NetworkBuilder`:
```swift
let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
 network.build()
        .request(request, retryPolicy: retryPolicy) { result in
            // Handle result here      
        }
```
Or use it with `NetworkPriorityDispatcher`:
```swift
let network: NetworkPriorityDispatcher<URLSession> = NetworkPriorityDispatcher(baseURL: baseURL)
network.addRequest(request1, retryPolicy: retryPolicy, priority: .medium) { result in
            // handle reponse for request 1       
        }
        .addRequest(request2, retryPolicy: retryPolicy, priority: .high) { result in
            // handle reponse for request 2
        }
        .addRequest(request3, retryPolicy: retryPolicy, priority: .low) { result in
            // handle reponse for request 3
        }.execute {
           // Completed all request here
        }
```

### 3.6 Re-Authentication
To handle scenarios requiring seamless re-authentication, we've implemented the `ReAuthenticationService` protocol. This design prompts the client to perform re-authentication and automatically re-executes the expired token once the client successfully re-authenticates.
```swift
extension SingleRequest: ReAuthenticationService {
    public func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void) {
        // For testing now. In fact, this value should get `newtoken` from the real service
        completion(.success(["jwt_token": "newtoken"]))
    }
}
```

### 3.7 Request Cancellation
We offer a function to make canceling requests a straightforward and simple process.

1. NetworkBuilder Cancellation
```swift
let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
network.build().request(request) { result in }
network.build().cancelRequest(request)
```
2. NetworkPriorityDispatcher Cancellation
```swift
let network: NetworkPriorityDispatcher<URLSession> = NetworkPriorityDispatcher(baseURL: baseURL)
network.cancelRequest(request).execute()
```

**Note: Please be aware that the cancellation may not be instantaneous. Handle the result appropriately within the completion block of the original request.**


That's it!! NetworkCompose is successfully integrated and initialized in the project, and ready to use. For more details, please go to [SingleRequest](/Example/Example/SingleRequest.swift) and [MultipleRequestWithPriority](/Example/Example/MultiplePriorityRequest.swift)

## IV. Support
Feel free to utilize [JSONPlaceholder](https://jsonplaceholder.typicode.com/guide/) for testing API in `NetworkCompose` examples. If you encounter any issues with `NetworkCompose` or need assistance with
integration, please reach out to me at harryngict@gmail.com. I'm happy to support you.

## V. License
NetworkCompose is available under the MIT license. See the [LICENSE](https://github.com/harryngict/NetworkCompose/blob/master/LICENSE) file for more information.
