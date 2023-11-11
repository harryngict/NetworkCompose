# NetworkSwift

**NetworkSwift** is a versatile and lightweight networking library designed for flexibility, supporting various session types, including URLSession. The library follows a defined contract, implementing three core functions:

1. **HTTPS Request**: Facilitates secure HTTP requests, with support for SSL pinning to enhance security.
2. **Upload File**: Supports the secure uploading of files.
3. **Download File**: Enables the downloading of files with security considerations.

## Features

- **Completion Request**: Utilizes completion handlers for efficient response handling.
- **Async Await Request (iOS 15 and above)**: Supports asynchronous programming through Swift's async/await mechanism.

## NetworkSwift/Queue Submodule

NetworkSwift includes a submodule called **NetworkSwift/Queue**, specifically designed to manage auto re-authentication. This feature is crucial in cases where request credentials have expired.

## Testability

For improved testability, NetworkSwift provides mock implementations, empowering developers to write effective unit tests. This ensures robustness in various scenarios and easy validation of the library's behavior.


## Integration

### Integration through CocoaPods

CocoaPods is a dependency manager for Swift projects and makes integration easier.

1. If you don't have CocoaPods installed, you can do it by executing the following line in your terminal.

    ```bash
    sudo gem install cocoapods
    ```

2. If you don't have a Podfile, create a plain text file named Podfile in the Xcode project directory with the following content, making sure to set the platform and version that matches your app.

    2.1. **Application**:
   
    ```ruby
    pod 'NetworkSwift/Core',  '0.0.6'
    pod 'NetworkSwift/Queue', '0.0.6'
    ```

    2.2. **Testing**:

    ```ruby
    pod 'NetworkSwift/CoreMocks',   '0.0.6'
    pod 'NetworkSwift/QueueMocks',  '0.0.6'
    ```

3. Install NetworkSwift by executing the following in the Xcode project directory.

    ```bash
    pod install
    ```

4. Now, open your project workspace and check if NetworkSwift is properly added.

## How to Use

```swift
enum Constant {
    static let baseURL: String = "https://jsonplaceholder.typicode.com"
}
```

### 1. Request async await for iOS-15 above
```swift
let request = NetworkRequestImp<[User]>(path: "/posts", method: .GET)
let service = NetworkKitFacade(baseURL: baseURL)
let result: [User] = try await service.request(request)
completion("\(result)")
```

### 2. Request completion closure

```swift
let request = NetworkRequestImp<[User]>(path: "/comments", method: .GET,
                                        queryParameters: ["postId": "1"])
let service = NetworkKitFacade(baseURL: baseURL)
service.request(request) { (result: Result<[User], NetworkError>) in
    self.handleResult(result)
}
```

### 3. Request and auto re-authentication
```swift
let request = NetworkRequestImp<User>(path: "/posts", method: .POST,
                                      queryParameters: ["title": "foo",
                                                        "body": "bar",
                                                        "userId": 1],
                                      requiresReAuthentication: true)

let reAuthService = ClientReAuthenticationService()

let service = NetworkKitQueueImp(baseURL: baseURL, reAuthService: reAuthService)
service.request(request) { (result: Result<User, NetworkError>) in
    self.handleResult(result)
}
```
### 4. Download File
```swift
let request = NetworkRequestImp<User>(path: "/posts/1", method: .PUT,
                                      queryParameters: ["title": "foo",
                                                        "body": "bar",
                                                        "userId": 1])
let service = NetworkKitFacade(baseURL: baseURL)
service.downloadFile(request) { (result: Result<URL, NetworkError>) in
    self.handleResult(result)
}
```

### 5. Upload File
```swift
let fileURL = URL(fileURLWithPath: "/Users/harrynguyen/Documents/Resources/NetworkSwift/LICENSE")

let request = NetworkRequestImp<User>(path: "/posts", method: .POST)
let service = NetworkKitFacade(baseURL: baseURL)
service.uploadFile(request, fromFile: fileURL) { (result: Result<User, NetworkError>) in
    self.handleResult(result)
}
```

### 6. Request with SSL Pinning
```swift
let request = NetworkRequestImp<User>(path: "/posts/1", method: .PUT,
                                      queryParameters: ["title": "foo",
                                                        "body": "bar",
                                                        "userId": 1])
                                                        
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
let request = NetworkRequestImp<User>(path: "/posts/1", method: .PATCH,
                                      queryParameters: ["title": "foo"])
                                      
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
let request = NetworkRequestImp<[User]>(path: "/users", method: .GET)
let service = NetworkKitFacade<NetworkSessionMock>(baseURL: baseURL, session: session)
service.request(request) { (result: Result<[User], NetworkError>) in
    self.handleResult(result)
}
```

Thats it!! NetworkSwift is successfully integrated and initialized in the project, and ready to use. 

For more detail please go to [Example project](https://github.com/harryngict/NetworkSwift/blob/master/Example/Example/Client/ClientNetworkFactory.swift).

## Support
Feel free to utilize [JSONPlaceholder](https://jsonplaceholder.typicode.com/guide/) for testing API in Networkit examples. If you encounter any issues with NetworkSwift or need assistance with
integration, please reach out to me at harryngict@gmail.com. I'm here to support you.
