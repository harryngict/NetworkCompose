//
//  Network+URLSession.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation
import Network

extension URLSession: NetworkSession {
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

    public func beginDownloadTask(
        _ request: URLRequest,
        completion: @escaping ((Result<NetworkResponse, NetworkError>) -> Void)
    ) -> NetworkTask {
        let task = downloadTask(with: request) { tempURL, response, error in
            self.handleDownloadResponse(tempURL: tempURL, response: response, error: error, completion: completion)
        }
        // TODO: Can set `earliestBeginDate`, `countOfBytesClientExpectsToSend` and `countOfBytesClientExpectsToReceive`
        task.resume()
        return task
    }
}

// MARK: Helper

private extension URLSession {
    func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) {
        if let error = error {
            completion(.failure(NetworkError.error(nil, error.localizedDescription)))
            return
        }
        guard let httpResponse = response as? HTTPURLResponse, let data = data else {
            completion(.failure(NetworkError.invalidResponse))
            return
        }

        let networkResponse = NetworkResponseImp(statusCode: httpResponse.statusCode, data: data)
        completion(.success(networkResponse))
    }

    func handleDownloadResponse(
        tempURL: URL?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) {
        if let error = error {
            completion(.failure(NetworkError.error(nil, error.localizedDescription)))
            return
        }
        guard response is HTTPURLResponse else {
            completion(.failure(NetworkError.invalidResponse))
            return
        }

        if let tempURL = tempURL, let urlData = try? Data(contentsOf: tempURL) {
            let response = NetworkResponseImp(statusCode: 200, data: urlData)
            completion(.success(response))
        } else {
            completion(.failure(NetworkError.downloadResponseTempURLNil))
        }
    }
}
