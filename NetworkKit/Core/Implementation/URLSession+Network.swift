//
//  URLSession+Network.swift
//  Core/Implementation
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

extension URLSession: NetworkSession {
    public func build<RequestType>(
        _ request: RequestType,
        withBaseURL baseURL: URL,
        withAuthHeaders authHeaders: [String: String]
    ) throws -> URLRequest where RequestType: NetworkRequest {
        guard var componenets = URLComponents(url: baseURL.appendingPathComponent(request.path),
                                              resolvingAgainstBaseURL: false)
        else {
            throw NetworkError.badURL(baseURL, request.path)
        }

        var queryItems = [URLQueryItem]()
        for (key, value) in request.queryParameters {
            if !String(describing: value).isEmpty {
                queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
            }
        }
        componenets.queryItems = queryItems

        guard let url = componenets.url else {
            throw NetworkError.badURLComponents(componenets)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers.merging(authHeaders) { $1 }
        urlRequest.timeoutInterval = request.timeoutInterval
        urlRequest.cachePolicy = createCachePolicy(cachePolicy: request.cachePolicy)
        if let body = request.body { urlRequest.httpBody = body }
        return urlRequest
    }

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
        _ request: URLRequest,
        fromFile: URL,
        completion: @escaping ((Result<NetworkResponse, NetworkError>) -> Void)
    ) -> NetworkTask {
        let task = uploadTask(with: request, fromFile: fromFile) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        task.resume()
        return task
    }

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
    func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) {
        if let error = error {
            completion(.failure(NetworkError.serviceError(nil, error.localizedDescription)))
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
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        if let error = error {
            completion(.failure(NetworkError.serviceError(nil, error.localizedDescription)))
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

    func createCachePolicy(cachePolicy: NetworkCachePolicy) -> URLRequest.CachePolicy {
        var urlCachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
        switch cachePolicy {
        case .remoteData: urlCachePolicy = .useProtocolCachePolicy
        case .cacheData: urlCachePolicy = .returnCacheDataElseLoad
        case .ignoreLocalCache: urlCachePolicy = .reloadIgnoringLocalCacheData
        }
        return urlCachePolicy
    }
}
