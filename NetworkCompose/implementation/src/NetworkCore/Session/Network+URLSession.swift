//
//  Network+URLSession.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 11/11/23.
//

import Foundation
import Network
import NetworkCompose

// MARK: - URLSession + NetworkSession

extension URLSession: NetworkSession {
  public func build(_ request: some RequestInterface,
                    withBaseURL baseURL: URL,
                    andHeaders headers: [String: String]) throws
    -> URLRequest
  {
    guard
      var components = URLComponents(
        url: baseURL.appendingPathComponent(request.path),
        resolvingAgainstBaseURL: false) else
    {
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

  public func beginRequest(_ request: URLRequest,
                           completion: @escaping ((Result<ResponseInterface, NetworkError>) -> Void))
    -> NetworkTask
  {
    let task = dataTask(with: request) { data, response, error in
      self.handleResponse(data: data, response: response, error: error, completion: completion)
    }
    task.resume()
    return task
  }
}

// MARK: Helper

private extension URLSession {
  func handleResponse(data: Data?,
                      response: URLResponse?,
                      error: Error?,
                      completion: @escaping (Result<ResponseInterface, NetworkError>) -> Void)
  {
    handleNetworkResponse(
      data: data,
      response: response,
      error: error,
      completion: completion)
  }

  func handleNetworkResponse(data: Data?,
                             response: URLResponse?,
                             error: Error?,
                             completion: @escaping (Result<ResponseInterface, NetworkError>) -> Void)
  {
    if let error {
      completion(.failure(NetworkError.error(nil, error.localizedDescription)))
      return
    }
    guard let httpResponse = response as? HTTPURLResponse, let data else {
      completion(.failure(NetworkError.invalidResponse))
      return
    }
    completion(.success(Response(statusCode: httpResponse.statusCode, data: data)))
  }
}
