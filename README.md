# NetworkCompose

NetworkCompose simplifies and enhances network-related tasks by providing a flexible and intuitive composition of network components. Reduce development effort and make your networking layer easy to maintain with seamless integration, SSL pinning, mocking, metric reporting, and smart retry mechanisms. It supports dynamic automation, making it a powerful tool for managing network operations in your Swift applications.

Here is the NetworkCompose archicture:

![NetworkCompose-Architecure](/Documents/NetworkCompose-Architecture.png)


## I. Features

- **Simple Request API:** Make network requests effortlessly using a straightforward and intuitive API.

- **Re-authentication Support:** Seamlessly handle scenarios that require re-authentication by implementing the `ReAuthenticationService` protocol.

- **SSL Pinning:** Enhance security with SSL pinning. Configure trusted hosts and corresponding hash keys to ensure a secure communication channel.

- **Network Metrics Reporting:** Collect and report comprehensive network metrics. Gain insights into your network performance.

- **Smart Retry Mechanism:** Implement smart retry policies for resilient network operations. Enhance the reliability of your app by intelligently handling network issues.

- **Automation Support:**
  - **Mocking with FileSystem:** Simulate network responses effortlessly during automated testing by mocking responses from a local file system.
  - **Customized Automation with Expectations:** Tailor your automated testing by customizing network response mocking with specific expectations.

- **Multiple Calls with Priority:** Execute multiple network calls with priority for efficient handling. The calls will prioritize based on users' rules and creation dates. This feature is particularly useful when dealing with scenarios where certain network requests need to take precedence over others.


## II. Testability

`NetworkCompose` is designed with testability in mind, making it easy to write unit tests and ensure the reliability of your networking layer. Effortlessly mock servers for UI and automation tests, streamlining the testing process.

## III. Integration

### 3.1. Integration through CocoaPods

To integrate NetworkCompose into your Xcode project using CocoaPods, add the following to your `Podfile`:

```ruby
pod 'NetworkCompose', '~> 0.0.8'
```

then run:
```bash
pod install
```
### 3.2. Integration through Swift Package Manager (SPM)
To integrate NetworkCompose using Swift Package Manager, add the following to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/harryngict/NetworkCompose.git", from: "0.0.8")
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
Will update soon


Thats it!! `NetworkCompose` is successfully integrated and initialized in the project, and ready to use. 

For more detail please go to [Single request](/Example/Example/SingleRequest.swift) and [Multiple request with priority](/Example/Example/MultiplePriorityRequest.swift)

## V. Support
Feel free to utilize [JSONPlaceholder](https://jsonplaceholder.typicode.com/guide/) for testing API in `NetworkCompose` examples. If you encounter any issues with `NetworkCompose` or need assistance with
integration, please reach out to me at harryngict@gmail.com. I'm here to support you.

## VI. License
NetworkCompose is available under the MIT license. See the [LICENSE](/LICENSE) file for more information.
