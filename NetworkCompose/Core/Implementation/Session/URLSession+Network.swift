//
//  URLSession+Network.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation
import Network

/// A URLSession extension providing conformance to the NetworkSession protocol.
extension URLSession: NetworkSession {
    /// Builds a URLRequest based on the provided network request.
    ///
    /// - Parameters:
    ///   - request: The network request to build the URLRequest from.
    ///   - baseURL: The base URL to append to the request path.
    ///   - headers: Additional headers to include in the request.
    /// - Returns: A URLRequest built from the given parameters.
    /// - Throws: A NetworkError in case of URL or URLComponents creation failure.
    public func build<RequestType>(
        _ request: RequestType,
        withBaseURL baseURL: URL,
        andHeaders headers: [String: String]
    ) throws -> URLRequest where RequestType: NetworkRequestInterface {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(request.path),
                                             resolvingAgainstBaseURL: false)
        else {
            throw NetworkError.badURL(baseURL, request.path)
        }

        components.queryItems = request.queryItems

        guard let url = components.url else {
            throw NetworkError.badURLComponents(components)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.generateRequestHeaders(with: headers)
        urlRequest.timeoutInterval = request.timeoutInterval
        urlRequest.cachePolicy = request.cacheURLRequestPolicy
        urlRequest.httpBody = request.body
        return urlRequest
    }

    /// Initiates an asynchronous network request using async/await.
    ///
    /// - Parameter request: The URLRequest for the network request.
    /// - Returns: A NetworkResponse representing the result of the request.
    /// - Throws: A NetworkError in case of a failed request or invalid response.
    @available(iOS 15.0, *)
    public func beginRequest(
        _ request: URLRequest
    ) async throws -> NetworkResponse {
        let (data, response) = try await self.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        return NetworkResponseImp(statusCode: httpResponse.statusCode, data: data)
    }

    /// Initiates a network request with a completion handler.
    ///
    /// - Parameters:
    ///   - request: The URLRequest for the network request.
    ///   - completion: A closure to be called upon completion with the result.
    /// - Returns: A NetworkTask representing the ongoing network task.
    public func beginRequest(
        _ request: URLRequest,
        completion: @escaping ((Result<NetworkResponse, NetworkError>) -> Void)
    ) -> NetworkTask {
        let task = dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        task.resume()
        return task
    }

    /// Initiates a network upload task with a completion handler.
    ///
    /// Uploads a file using a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` for the network request. It must be an `inout` parameter, allowing modifications.
    ///   - fromFile: The URL of the file to be uploaded.
    ///   - completion: A closure to be called upon completion with the result. The closure takes a `Result` enum with either a `NetworkResponse` on success or a `NetworkError` on failure.
    ///
    /// - Returns: A `NetworkTask` representing the ongoing network task. Use this task to manage or cancel the upload
    public func beginUploadTask(
        _ request: inout URLRequest,
        fromFile: URL,
        completion: @escaping ((Result<NetworkResponse, NetworkError>) -> Void)
    ) throws -> NetworkTask {
        var bodyStreamRequest = request
        bodyStreamRequest.httpBodyStream = createHttpBodyStream(fromFileURL: fromFile)
        let task = dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        task.resume()
        return task
    }

    /// Initiates a network download task with a completion handler.
    ///
    /// - Parameters:
    ///   - request: The URLRequest for the network request.
    ///   - completion: A closure to be called upon completion with the result.
    /// - Returns: A NetworkTask representing the ongoing network task.
    public func beginDownloadTask(
        _ request: URLRequest,
        completion: @escaping ((Result<URL, NetworkError>) -> Void)
    ) -> NetworkTask {
        let task = downloadTask(with: request) { tempURL, response, error in
            self.handleDownloadResponse(tempURL: tempURL, response: response, error: error, completion: completion)
        }
        task.resume()
        return task
    }
}

// MARK: Helper

private extension URLSession {
    /// Handles the response data, converts it into a NetworkResponse, and calls the completion handler.
    ///
    /// - Parameters:
    ///   - data: The response data.
    ///   - response: The URLResponse.
    ///   - error: An optional error if the request fails.
    ///   - completion: A closure to be called upon completion with the result.
    func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) {
        if let error = error {
            completion(.failure(NetworkError.networkError(nil, error.localizedDescription)))
            return
        }
        guard let httpResponse = response as? HTTPURLResponse, let data = data else {
            completion(.failure(NetworkError.invalidResponse))
            return
        }

        let networkResponse = NetworkResponseImp(statusCode: httpResponse.statusCode, data: data)
        completion(.success(networkResponse))
    }

    /// Handles the download response, converts it into a URL, and calls the completion handler.
    ///
    /// - Parameters:
    ///   - tempURL: The temporary URL of the downloaded file.
    ///   - response: The URLResponse.
    ///   - error: An optional error if the request fails.
    ///   - completion: A closure to be called upon completion with the result.
    func handleDownloadResponse(
        tempURL: URL?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        if let error = error {
            completion(.failure(NetworkError.networkError(nil, error.localizedDescription)))
            return
        }
        guard response is HTTPURLResponse else {
            completion(.failure(NetworkError.invalidResponse))
            return
        }

        if let tempURL = tempURL {
            completion(.success(tempURL))
        } else {
            completion(.failure(NetworkError.invalidResponse))
        }
    }
}
