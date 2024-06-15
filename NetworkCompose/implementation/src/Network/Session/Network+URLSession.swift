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
  public var cookieStorage: CookieStorage { HTTPCookieStorage.shared }

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

  public func beginUploadTask(_ request: URLRequest,
                              fromFile: URL,
                              completion: @escaping ((Result<ResponseInterface, NetworkError>) -> Void))
    -> NetworkTask
  {
    var bodyStreamRequest = request
    bodyStreamRequest.httpBodyStream = createInputStream(fromFileURL: fromFile)
    let task = dataTask(with: bodyStreamRequest) { data, response, error in
      self.handleResponse(data: data, response: response, error: error, completion: completion)
    }
    task.resume()
    return task
  }

  public func beginDownloadTask(_ request: URLRequest,
                                completion: @escaping ((Result<ResponseInterface, NetworkError>) -> Void))
    -> NetworkTask
  {
    let task = downloadTask(with: request) { tempURL, response, error in
      self.handleDownloadResponse(tempURL: tempURL, response: response, error: error, completion: completion)
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

  func handleDownloadResponse(tempURL: URL?,
                              response: URLResponse?,
                              error: Error?,
                              completion: @escaping (Result<ResponseInterface, NetworkError>) -> Void)
  {
    guard let tempURL else {
      completion(.failure(NetworkError.downloadResponseTempURLNil))
      return
    }
    handleNetworkResponse(
      data: try? Data(contentsOf: tempURL),
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
    cookieStorage.addCookies(from: httpResponse)
    completion(.success(Response(statusCode: httpResponse.statusCode, data: data)))
  }

  func createInputStream(fromFileURL fileURL: URL) -> InputStream? {
    guard let inputStream = InputStream(url: fileURL) else {
      return nil
    }
    inputStream.open()
    var buffer = [UInt8](repeating: 0, count: 1024)
    let data = NSMutableData()

    while inputStream.hasBytesAvailable {
      let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
      if bytesRead > 0 {
        data.append(buffer, length: bytesRead)
      } else {
        break
      }
    }
    inputStream.close()
    return InputStream(data: data as Data)
  }
}
