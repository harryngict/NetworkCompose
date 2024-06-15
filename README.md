
# NetworkCompose
## Table of Contents

1. [The NetworkCompose Architecture](#the-networkcompose-architecture)
2. [Features](#i-features)
3. [Integration](#ii-integration)
   1. [Integration through CocoaPods](#21-integration-through-cocoapods)
   2. [Integration through Swift Package Manager (SPM)](#22-integration-through-swift-package-manager-spm)
4. [Usage](#iii-usage)
5. [Support](#iv-support)
6. [License](#v-license)

## The NetworkCompose architecture:

![NetworkCompose-Architecure](/Documents/NetworkCompose-Architecture.png)


## I. Features
NetworkCompose offers a streamlined and enriched approach to handling network-related tasks, empowering developers with a flexible and intuitive composition of network components. By leveraging NetworkCompose, you can significantly minimize development effort and ensure the simplicity of maintaining networking layers. This robust solution seamlessly integrates various features, including SSL pinning, mocking, metric reporting, and retry mechanisms.

**Key Features:**

1. Effort Reduction: By utilizing NetworkCompose, developers can reduce the overall effort involved in network-related tasks, making development processes more efficient and streamlining.

2. Seamless Integration: Enjoy seamless integration with NetworkCompose, which effortlessly incorporates SSL pinning, mocking, metric reporting, retry exponential back-off mechanisms and circuitBreaker to improve the stability and resilience into network operations.


## II. Integration

### 2.1. Integration through CocoaPods

To integrate NetworkCompose into your Xcode project using CocoaPods, add the following to your `Podfile`:

```ruby
pod 'NetworkCompose', '~> 0.1.6'
```

then run:
```bash
pod install
```
### 2.2. Integration through Swift Package Manager (SPM)
To integrate NetworkCompose using Swift Package Manager, add the following to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/harryngict/NetworkCompose.git", from: "0.1.6")
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

NetworkCompose is successfully integrated and initialized in the project, and ready to use. For more details, please go to [SingleRequest](/Example/Example/SingleRequest.swift) and [MultipleRequestWithPriority](/Example/Example/MultiplePriorityRequest.swift)

## IV. Support
Feel free to utilize [JSONPlaceholder](https://jsonplaceholder.typicode.com/guide/) for testing API in `NetworkCompose` examples. If you encounter any issues with `NetworkCompose` or need assistance with
integration, please reach out to me at harryngict@gmail.com. I'm happy to support you.

## V. License
NetworkCompose is available under the MIT license. See the [LICENSE](https://github.com/harryngict/NetworkCompose/blob/master/LICENSE) file for more information.
