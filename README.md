# NetworkCompose

NetworkCompose simplifies and enhances network-related tasks by providing a flexible and intuitive composition of network components. Reduce development effort and make your networking layer easy to maintain with seamless integration, SSL pinning, mocking, metric reporting, and smart retry mechanisms. It supports dynamic automation, making it a powerful tool for managing network operations in your Swift applications.

**Here is the NetworkCompose archicture:**

![NetworkCompose-Architecure](/Documents/NetworkCompose-Architecture.png)


## I. Features

- **Simple Request API:** Make network requests effortlessly using a straightforward and intuitive API.

- **SSL Pinning:** Enhance security with SSL pinning. Configure trusted hosts and corresponding hash keys to ensure a secure communication channel.

- **Network Metrics Reporting:** Collect and report comprehensive network metrics. Gain insights into your network performance.

- **Retry Mechanism:** Implement retry policies for resilient network operations. Enhance the reliability of your app by intelligently handling network issues.

- **Multiple Calls with Priority:** Execute multiple network calls with priority for efficient handling. The calls will prioritize based on users' rules and creation dates. This feature is particularly useful when dealing with scenarios where certain network requests need to take precedence over others.

- **Re-authentication Support:** Effectively manage situations that necessitate the need for re-authentication.

- **Automation Support:**
  - **Mocking with FileSystem:** Simulate network responses effortlessly during automated testing by mocking responses from a local file system.
  - **Customized Automation with Expectations:** Tailor your automated testing by customizing network response mocking with specific expectations.


## II. Integration

### 2.1. Integration through CocoaPods

To integrate NetworkCompose into your Xcode project using CocoaPods, add the following to your `Podfile`:

```ruby
pod 'NetworkCompose', '~> 0.0.9'
```

then run:
```bash
pod install
```
### 2.2. Integration through Swift Package Manager (SPM)
To integrate NetworkCompose using Swift Package Manager, add the following to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/harryngict/NetworkCompose.git", from: "0.0.9")
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
In the given diagram, there are two distinct classes designed to handle different types of requests: Regular Call (RC) and Multiple with Priority (MCP). The Regular Call functionality is implemented using the NetworkBuilder class, while the Multiple with Priority functionality relies on the NetworkPriorityDispatcher class. It's important to note that since the NetworkPriorityDispatcher class inherits from the NetworkBuilder class, it can also be employed for Regular Call scenarios.

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
### 3.2 Configution options (optional)

### A. [SSLPinningPolicy](/Sources/NetworkCompose/src/Network/SSLPinning/SSLPinningPolicy.swift) configution

- Option 1: Enabled SSL Pinning by provide host and hash_key
```swift
let pinningHost = SSLPinning(host: "your_host", 
                             hashKeys: ["your_key"])
network.sslPinningPolicy(.trust([pinningHost]))
```
- Option 2: Disabled SSL Pinning
```swift
network.sslPinningPolicy(.disabled)
```

### B. [ReportMetricStrategy](/Sources/NetworkCompose/src/Network/Metric/ReportMetricStrategy.swift) configution

- Option 1: Disabled Network Metrics Reporting
```swift
network.reportMetric(.disabled)
```
- Option 2: Enabled with MetricInterceptor
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

### D. [LogStrategy](/Sources/NetworkCompose/src/Network/Logger/LogStrategy.swift) configution

- Option 1: Enabled Log Strategy

```swift
network.log(.enabled)
```
- Option 2: Disabled Log Strategy
```swift
network.log(.disabled)
```
- Option 3: Custom Log Strategy
```swift
network.log(.custom(YourLoggerInterface)). 
```
With option 3, you have the flexibility to customize the logging behavior by conforming to the `LoggerInterface` protocol.
```swift
public protocol LoggerInterface {
    func log(_ type: LoggingType, _ message: String)
}
```

### E. [NetworkReachability](/Sources/NetworkCompose/src/Utility/Reachability/NetworkReachability.swift) configution
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


### F. [SessionConfiguration](/Sources/NetworkCompose/src/Network/Session/SessionConfigurationProvider.swift) configution

- Option 1: Using the ephemeral option ensures that all data is stored in RAM, along with additional optimized configurations for better performance.
```swift
network.sessionConfigurationProvider(.ephemeral)
``````
- Option 2: Using background configuration for Download Tasks
```swift
network.sessionConfigurationProvider(.background)
```
Note: It's important to refrain from setting the background configuration for dataTask.

### G. [RecordResponseMode](/Sources/NetworkCompose/src/NetworkMocker/Storage/RecordResponseMode.swift) configution
This option enables the module to record and save responses in FileManager during actual usage, facilitating reuse for automation testing in subsequent scenarios.

- Opition 1: Enabled Record Response Mode
```swift
network.recordResponseForTesting(.enabled) 
```

- Option 2: Disabled Record Response Mode
```swift
network.recordResponseForTesting(.disabled) 
```

Please be aware that we also offer the clearMockDataInDisk method, allowing you to delete all recorded data if necessary.
```swift
network.clearMockDataInDisk()
```

### H. [AutomationMode](/Sources/NetworkCompose/src/NetworkMocker/AutomationMode.swift) configution
Option 1: Utilize locally stored data saved during the Record Response Mode.

```swift
network.automationMode(.enabled(.local)) 
````

- Option 2: Implement a custom expectation for a specific endpoint, necessitating confirmation through [EndpointExpectationProvider](/Sources/NetworkCompose/src/NetworkMocker/EndpointExpectationProvider.swift)
```swift
network.automationMode(.enabled(.custom(self)))
```

## Note: We will apply a default configuration to all settings if the client does not specify one.
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
Noted that: `priority` is optional and it is `medium` by default.

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


Thats it!! `NetworkCompose` is successfully integrated and initialized in the project, and ready to use. 
For more detail please go to [SingleRequest](/Example/Example/SingleRequest.swift) and [MultipleRequestWithPriority](/Example/Example/MultiplePriorityRequest.swift)

## IV. Support
Feel free to utilize [JSONPlaceholder](https://jsonplaceholder.typicode.com/guide/) for testing API in `NetworkCompose` examples. If you encounter any issues with `NetworkCompose` or need assistance with
integration, please reach out to me at harryngict@gmail.com. I'm here to support you.

## V. License
NetworkCompose is available under the MIT license. See the [LICENSE](https://github.com/harryngict/NetworkCompose/blob/master/LICENSE) file for more information.