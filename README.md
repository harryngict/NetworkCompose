# NetworkKit 

NetworkKit is a lightweight and dynamic networking library designed for versatility, supporting various session types, including URLSession. The library adheres to a defined contract, implementing three core functions:

1. HTTPS Request: Facilitates making secure HTTP requests.
2. Upload File: Supports the uploading of files.
3. Download File: Enables the downloading of files.

NetworkKit offers two distinct methods for executing requests:

1. Completion Request: Utilizes completion handlers for handling responses.

2. Async Await Request (iOS 15 above): Supports asynchronous programming through Swift's async/await mechanism.

Additionally, NetworkKit includes a submodule called NetworkKitQueue. This submodule is specifically designed to handle auto re-authentication in cases where request credentials have expired.

To enhance testability, NetworkKit provides mock implementations, allowing developers to write unit tests effectively.


## Integration

### Integration through CocoaPods
CocoaPods is a dependency manager for Swift projects and makes integration easier.

1. If you don't have CocoaPods installed, you can do it by executing the following line in your terminal.

    ```sudo gem install cocoapods```
    
2. If you don't have a Podfile, create a plain text file named Podfile in the Xcode project directory with the following content, making sure to set the platform and version that matches your app.

    2.1. Application:
   
    ```pod 'NetworkKit/Core'```
   
   ```pod 'NetworkKit/NetworkQueue'```
   
   2.2. Testing:

   ```pod 'NetworkKit/CoreMocks'```
   
   ```pod 'NetworkKit/NetworkQueueMocks'```
   
3. Install NetworkKit by executing the following in the Xcode project directory.

    ```pod install```
    
4. Now, open your project workspace and check if NetworkKit is properly added.
    

## How to use

### 1. Request with Completion
```
    let credentialContainer = ClientCredentialContainer()
    let service = NetworkKitImpWrapper(baseURL: baseURL, credentialContainer: credentialContainer)
    let request = ClientRequest()
    service.request(request) { result in
        self.handleResult(result, completion: completion)
    }
```
### 2. Request with async await for iOS-15 above
```
    do {
        let credentialContainer = ClientCredentialContainer()
        let service = NetworkKitImpWrapper(baseURL: baseURL, credentialContainer: credentialContainer)
        let request = ClientRequest()
        let result: ClientResponse = try await service.request(request)
        debugPrint("Request success: \(result)")
    } catch {
        debugPrint((error as? NetworkError)?.localizedDescription ?? error.localizedDescription)
    }
```
### 3. Request with Queue and Re-Authentication
```
    let credentialContainer = ClientCredentialContainer()
    let reAuthService = ClientReAuthenticationService(credentialContainer: credentialContainer)
    let networkKitQueue = NetworkKitQueueImp(baseURL: baseURL,
                                             credentialContainer: credentialContainer,
                                             reAuthService: reAuthService)
    let request = ClientRequest(requiresCredentials: true)
    networkKitQueue.request(request) { result in
        self.handleResult(result, completion: completion)
    }
```
### 4. Download file
```
    let downloadDelegate = ClientDownloadDelegate()
    let session = URLSession(configuration: .default, delegate: downloadDelegate, delegateQueue: nil)
    let downloadService = NetworkKitImpWrapper(baseURL: baseURL, session: session)
    let request = ClientRequest(method: .POST)
    downloadService.downloadFile(request) { result in
        self.handleResult(result, completion: completion)
    }
```
### 5. Upload file
```
   let uploadDelegate = ClientUploadDelegate()
   let session = URLSession(configuration: .default, delegate: uploadDelegate, delegateQueue: nil)
   let uploadService = NetworkKitImpWrapper(baseURL: baseURL, session: session)
   let request = ClientRequest(method: .POST)
   uploadService.uploadFile(request, fromFile: URL(fileURLWithPath: "")) { result in
     self.handleResult(result, completion: completion)
   }
```
### 6. Mocking support unit test
```
  let successResult = NetworkKitResultMock.requestSuccess(
     NetworkResponseMock(statusCode: 200, response: ClientResponse(data: [ClientResponse.Model(id: "4005")]))
   )
  let session = NetworkSessionMock<ClientResponse>(expected: successResult)
  let service = NetworkKitImpWrapper<NetworkSessionMock>(baseURL: baseURL, session: session)
  let request = ClientRequest()
  service.request(request) { result in
    self.handleResult(result, completion: completion)
  }
```

### 7. Handle result
```
  private func handleResult<T>(
    _ result: Result<T, NetworkError>,
    completion: @escaping (String) -> Void
  ) {
    switch result {
      case let .success(model):   completion("Request success: \(model)")
      case let .failure(error):   completion(error.localizedDescription)
    }
  }
```

Thats it!! NetworkKit is successfully integrated and initialized in the project, and ready to use. 

For more detail please go to [Example project](https://github.com/harryngict/NetworkKit/blob/main/Example/Example/Client/ClientNetworkFactory.swift).

## Support
For any issues you face with NetworkKit and for any help with the integration contact us at `harryngict@gmail.com`.
