# NetworkCompose


## Purpose
After several years of experience in iOS application development, I have identified some common pain points across many applications, particularly concerning API usage and network calls. The main issues I aim to address are:

1. Automation Process
2. Lack of Network Metrics
3. Complex Retry Policy Implementation
4. Support for Multiple Calls with Priority
5. Re-Authentication for Seamless User Experience

### Problem 1: Automation Process
- **Challenge:** Dependency on the backend can lead to project delays when deadlines are not met.

- **Solution Stage 1:** Introduce a mechanism for the mobile team to simulate backend responses based on predefined expectations. This allows continued development even when the backend is not ready.

- **Solution Stage 2:** Implement a system to record successful API responses, facilitating automation in subsequent stages when the backend is available.

### Problem 2: Lack of Network Metrics
- **Challenge:** Although there are various tools for measuring network performance, they are not always effective when debugging.

- **Solution:** Develop a system that provides detailed metrics such as task, session, request, response, and errors in real-time during the debugging process.


### Problem 3: Complex Retry Policy Implementation
- **Challenge:** The default URLSession lacks built-in support for a retry policy, resulting in the need for custom implementations or reliance on third-party libraries that can be complex to debug.

- **Solution:** Design a simple and clear retry policy integrated into the network architecture to simplify the implementation process.

### Problem 4: Support for Multiple Calls with Priority
- **Challenge:** Design a library that supports multiple calls with varying priorities can be time-consuming.

- **Solution:** Introduce a straightforward method for executing network calls with different priorities, ensuring clarity and ease of use for developers.

### Problem 5: Re-Authentication for Seamless User Experience
- **Challenge:** Achieving seamless user experiences often requires efficient re-authentication mechanisms.

- **Solution:** Implement robust re-authentication processes to reduce disruptions in user experience and enhance overall application security and reliability.

In summary, this project aims to enhance the efficiency of iOS application development by providing solutions to challenges related to automation, network metrics, retry policies, support for multiple calls with priority, and seamless user re-authentication.

### The NetworkCompose archicture:

![NetworkCompose-Architecure](/Documents/NetworkCompose-Architecture.png)


## I. Features
NetworkCompose offers a streamlined and enriched approach to handling network-related tasks, empowering developers with a flexible and intuitive composition of network components. By leveraging NetworkCompose, you can significantly minimize development effort and ensure the simplicity of maintaining networking layers. This robust solution seamlessly integrates various features, including SSL pinning, mocking, metric reporting, and retry mechanisms.

**Key Features:**

1. Effort Reduction: By utilizing NetworkCompose, developers can reduce the overall effort involved in network-related tasks, making development processes more efficient and streamlining.

2. Seamless Integration: Enjoy seamless integration with NetworkCompose, which effortlessly incorporates SSL pinning, mocking, metric reporting, and retry mechanisms into network operations.

3. Dynamic Automation: With support for dynamic automation, NetworkCompose becomes a powerful tool for efficiently managing network operations in Swift applications, adapting to changing requirements seamlessly.


## II. Integration

### 2.1. Integration through CocoaPods

To integrate NetworkCompose into your Xcode project using CocoaPods, add the following to your `Podfile`:

```ruby
pod 'NetworkCompose', '~> 0.1.0'
```

then run:
```bash
pod install
```
### 2.2. Integration through Swift Package Manager (SPM)
To integrate NetworkCompose using Swift Package Manager, add the following to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/harryngict/NetworkCompose.git", from: "0.1.0")
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

- Option 1: Enable SSL Pinning by providing host and hash_key
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
let concurrent = DispatchQueue(label: "com.NetworkCompose.NetworkComposeDemo",
                               qos: .userInitiated,
                               attributes: .concurrent)
network.execute(on: concurrent)
       .observe(on: DispatchQueue.main)
```

### D. [LoggerStrategy](/Sources/NetworkCompose/src/Network/Logger/LoggerStrategy.swift) configuration

- Option 1: Enable Log Strategy

```swift
network.logger(.enabled)
```
- Option 2: Disable Log Strategy
```swift
network.logger(.disabled)
```
- Option 3: Customize Log Strategy
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


### F. [SessionConfiguration](/Sources/NetworkCompose/src/Network/Session/SessionConfigurationProvider.swift) configuration

- Option 1: Use the ephemeral option to ensure that all data is stored in RAM, along with additional optimized configurations for better performance.
```swift
network.sessionConfigurationProvider(.ephemeral)
``````
- Option 2: Use background configuration for Download Tasks
```swift
network.sessionConfigurationProvider(.background)
```

**Note: It's important to refrain from setting the background configuration for dataTask.**

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

**Please be aware that we also offer the clearMockDataInDisk method, allowing you to delete all recorded data if necessary.**

```swift
network.clearMockDataInDisk()
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

**Note: We will apply a default configuration to all settings if the client does not specify one.**
```swift
network.applyDefaultConfiguration()
```

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
The default behavior for the Re-Authentication operation involves execution on a serial queue. However, we provide the flexibility to customize this by using the following:
```swift
 network.reAuthenOperationQueue(YourOperationQueue)
```
Please ensure that YourOperationQueue conforms to the [OperationQueueManagerInterface](/Sources/NetworkCompose/src/Network/OperationQueue/OperationQueueManagerInterface.swift)


**That's it!! NetworkCompose is successfully integrated and initialized in the project, and ready to use. For more details, please go to [SingleRequest](/Example/Example/SingleRequest.swift) and [MultipleRequestWithPriority](/Example/Example/MultiplePriorityRequest.swift)**

## IV. Support
Feel free to utilize [JSONPlaceholder](https://jsonplaceholder.typicode.com/guide/) for testing API in `NetworkCompose` examples. If you encounter any issues with `NetworkCompose` or need assistance with
integration, please reach out to me at harryngict@gmail.com. I'm happy to support you.

## V. License
NetworkCompose is available under the MIT license. See the [LICENSE](https://github.com/harryngict/NetworkCompose/blob/master/LICENSE) file for more information.
